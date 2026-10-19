/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';

/// Gửi một lô sự kiện lên Hub; trả `true` nếu Hub đã nhận.
typedef HubSender = Future<bool> Function(List<Map<String, dynamic>> events);

/// Hub không nhận lô sự kiện; sự kiện vẫn nằm trong outbox, lượt sau gửi lại.
class HubUnavailable implements Exception {
  const HubUnavailable();

  @override
  String toString() => 'Hub chưa nhận được sự kiện, sẽ gửi lại';
}

/// Đọc outbox của một database service, gửi lên Hub, đánh dấu đã gửi.
/// Hub bỏ qua sự kiện trùng, nên gửi lại sau khi lỗi giữa chừng vẫn an toàn.
class OutboxRelay {
  OutboxRelay({
    required this.region,
    required this.service,
    required Session db,
    required HubSender send,
    this.batchSize = 100,
  }) : _db = db,
       _send = send;

  final String region;
  final String service;
  final int batchSize;
  final Session _db;
  final HubSender _send;

  /// Chạy một lượt; trả số sự kiện đã đẩy lên Hub.
  Future<int> relayOnce() async {
    final rows = await _db.execute(
      Sql.named(
        'select id, aggregate, aggregate_id, event_type, payload::text, '
        'created_at, event_id::text from outbox where published_at is null '
        'order by id limit @limit',
      ),
      parameters: {'limit': batchSize},
    );
    if (rows.isEmpty) return 0;

    final events = [
      for (final row in rows)
        {
          'region': region,
          'sourceService': service,
          'outboxId': row[0],
          'aggregate': row[1],
          'aggregateId': row[2],
          'eventType': row[3],
          'payload': jsonDecode(row[4]! as String),
          'occurredAt': (row[5]! as DateTime).toUtc().toIso8601String(),
          'eventId': row[6],
        },
    ];
    if (!await _send(events)) throw const HubUnavailable();

    await _db.execute(
      Sql.named('update outbox set published_at = now() where id = any(@ids)'),
      parameters: {
        'ids': TypedValue(Type.bigIntegerArray, [
          for (final e in events) e['outboxId'],
        ]),
      },
    );
    return events.length;
  }
}

/// Gửi HTTP tới service audit ở Hub kèm `X-Sync-Token`.
HubSender httpHubSender(Uri endpoint, String token) {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  return (events) async {
    try {
      final request = await client.postUrl(endpoint)
        ..headers.contentType = ContentType.json
        ..headers.set('x-sync-token', token)
        ..write(jsonEncode({'events': events}));
      final response = await request.close();
      await response.drain<void>();
      return response.statusCode == 200;
    } on Exception catch (e) {
      stderr.writeln('Không gửi được lên Hub: $e');
      return false;
    }
  };
}
