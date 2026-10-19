/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:notification_service/src/domain/notification_rules.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

abstract interface class NotificationRepository {
  /// Đã đọc sổ sự kiện ở Hub tới id nào (0 nếu chưa đọc).
  Future<int> checkpoint();

  /// Ghi thông báo của một lô sự kiện và dời mốc đã đọc, trong một giao dịch.
  /// Trả các thông báo mới thật sự được thêm (bỏ qua bản trùng).
  Future<List<NewNotification>> saveBatch(
    List<({String eventId, DateTime? at, NewNotification notification})>
    items, {
    required int lastEventId,
  });

  /// Hộp thông báo của một người: mọi thông báo gửi cho [recipients] của họ.
  Future<({List<Map<String, dynamic>> items, int unread})> inbox(
    List<String> recipients, {
    required String userSub,
    int limit = 50,
  });

  /// Đánh dấu đã đọc; [ids] rỗng nghĩa là đọc hết.
  Future<void> markRead(
    List<String> recipients, {
    required String userSub,
    List<String> ids = const [],
  });

  /// Lưu mã FCM của máy kèm địa chỉ nhận và ngôn ngữ
  Future<void> registerDevice(
    String token, {
    required String userSub,
    List<String> recipients = const [],
    String language = 'en',
  });

  Future<void> removeDevice(String token);

  /// Các máy nhận thông báo gửi tới [recipient]
  Future<List<({String token, String language})>> devicesFor(String recipient);
}

class PostgresNotificationRepository implements NotificationRepository {
  PostgresNotificationRepository(this._db);

  final Database _db;
  static const _consumer = 'hub_audit';

  @override
  Future<int> checkpoint() async {
    final rows = await _db.query(
      'select last_event_id from consumer_checkpoint where name = @name',
      params: {'name': _consumer},
      fromPrimary: true,
    );
    return rows.isEmpty ? 0 : rows.first['last_event_id'] as int;
  }

  @override
  Future<List<NewNotification>> saveBatch(
    List<({String eventId, DateTime? at, NewNotification notification})>
    items, {
    required int lastEventId,
  }) {
    return _db.transaction((tx) async {
      final added = <NewNotification>[];
      for (final item in items) {
        final n = item.notification;
        final rows = await tx.execute(
          Sql.named(
            'insert into notifications (event_id, recipient, kind, params, '
            'created_at) values (@event::uuid, @recipient, @kind, '
            '@params::jsonb, coalesce(@at::timestamptz, now())) '
            'on conflict (event_id, recipient) do nothing returning id',
          ),
          parameters: {
            'event': item.eventId,
            'recipient': n.recipient,
            'kind': n.kind,
            'params': jsonEncode(n.params),
            'at': item.at,
          },
        );
        if (rows.isNotEmpty) added.add(n);
      }
      await tx.execute(
        Sql.named(
          'insert into consumer_checkpoint (name, last_event_id) '
          'values (@name, @last) on conflict (name) do update '
          'set last_event_id = excluded.last_event_id',
        ),
        parameters: {'name': _consumer, 'last': lastEventId},
      );
      return added;
    });
  }

  @override
  Future<({List<Map<String, dynamic>> items, int unread})> inbox(
    List<String> recipients, {
    required String userSub,
    int limit = 50,
  }) async {
    final params = {
      'recipients': TypedValue(Type.textArray, recipients),
      'sub': userSub,
      'limit': limit,
    };
    // Vừa đánh dấu đọc xong mở lại phải thấy ngay, nên đọc primary.
    final rows = await _db.query(
      'select n.id::text, n.kind, n.params, n.created_at, '
      '(r.user_sub is not null) as read from notifications n '
      'left join notification_reads r on r.notification_id = n.id '
      'and r.user_sub = @sub where n.recipient = any(@recipients) '
      'order by n.created_at desc limit @limit',
      params: params,
      fromPrimary: true,
    );
    final unread = await _db.query(
      'select count(*)::int as n from notifications n '
      'where n.recipient = any(@recipients) and not exists ( '
      'select 1 from notification_reads r where r.notification_id = n.id '
      'and r.user_sub = @sub)',
      params: {'recipients': params['recipients'], 'sub': userSub},
      fromPrimary: true,
    );
    return (
      items: [
        for (final r in rows)
          {
            'id': r['id'],
            'kind': r['kind'],
            'params': r['params'],
            'createdAt': (r['created_at'] as DateTime).toIso8601String(),
            'read': r['read'],
          },
      ],
      unread: unread.first['n'] as int,
    );
  }

  @override
  Future<void> markRead(
    List<String> recipients, {
    required String userSub,
    List<String> ids = const [],
  }) async {
    // Chỉ đánh dấu được thông báo của chính mình.
    await _db.execute(
      'insert into notification_reads (notification_id, user_sub) '
      'select id, @sub from notifications '
      'where recipient = any(@recipients) '
      'and (cardinality(@ids::text[]) = 0 or id::text = any(@ids::text[])) '
      'on conflict do nothing',
      params: {
        'sub': userSub,
        'recipients': TypedValue(Type.textArray, recipients),
        'ids': TypedValue(Type.textArray, ids),
      },
    );
  }

  @override
  Future<void> registerDevice(
    String token, {
    required String userSub,
    List<String> recipients = const [],
    String language = 'en',
  }) async {
    await _db.execute(
      'insert into device_tokens (token, user_sub, recipients, language) '
      'values (@token, @sub, @recipients, @language) '
      'on conflict (token) do update set user_sub = excluded.user_sub, '
      'recipients = excluded.recipients, language = excluded.language, '
      'updated_at = now()',
      params: {
        'token': token,
        'sub': userSub,
        'recipients': TypedValue(Type.textArray, recipients),
        'language': language,
      },
    );
  }

  @override
  Future<void> removeDevice(String token) async {
    await _db.execute(
      'delete from device_tokens where token = @token',
      params: {'token': token},
    );
  }

  @override
  Future<List<({String token, String language})>> devicesFor(
    String recipient,
  ) async {
    final rows = await _db.query(
      'select token, language from device_tokens '
      'where @recipient = any(recipients)',
      params: {'recipient': recipient},
      fromPrimary: true,
    );
    return [
      for (final r in rows)
        (token: r['token'] as String, language: r['language'] as String),
    ];
  }
}
