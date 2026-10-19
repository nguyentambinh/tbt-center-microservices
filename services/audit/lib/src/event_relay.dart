/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:async';
import 'dart:io';

import 'package:tbt_common/tbt_common.dart';

abstract interface class RelayStore {
  Future<int> cursor();

  /// Sự kiện sau [id], cũ trước mới sau
  Future<List<Map<String, dynamic>>> after(int id, {int limit = 200});

  Future<void> advance(int id);
}

class PostgresRelayStore implements RelayStore {
  PostgresRelayStore(this._db);

  final Database _db;

  @override
  Future<int> cursor() async {
    final rows = await _db.query(
      "select last_id from relay_state where name = 'rabbitmq'",
      fromPrimary: true,
    );
    return rows.isEmpty ? 0 : rows.first['last_id'] as int;
  }

  @override
  Future<List<Map<String, dynamic>>> after(int id, {int limit = 200}) =>
      _db.query(
        'select id, event_id::text, region, source_service, event_type, '
        'aggregate_id, occurred_at, hash from events '
        'where id > @id order by id limit @limit',
        params: {'id': id, 'limit': limit},
        fromPrimary: true,
      );

  @override
  Future<void> advance(int id) => _db.execute(
    'insert into relay_state (name, last_id) values (@n, @id) '
    'on conflict (name) do update set last_id = excluded.last_id',
    params: {'n': 'rabbitmq', 'id': id},
  );
}

/// Phát sự kiện vừa ghi vào sổ audit lên RabbitMQ (outbox ở Hub).
/// Chỉ gửi phần nhận diện, không gửi payload có dữ liệu cá nhân; bên nhận
/// đọc chi tiết từ sổ audit. RabbitMQ xác nhận cả lô mới dời điểm đánh dấu,
/// nên mất kết nối giữa chừng thì gửi lại (ít nhất một lần).
class EventRelay {
  EventRelay(this._store, this._bus);

  final RelayStore _store;
  final EventBus _bus;
  var _running = false;
  var _again = false;

  void start({Duration every = const Duration(seconds: 3)}) {
    Timer.periodic(every, (_) => unawaited(kick()));
    unawaited(kick());
  }

  /// Có sự kiện mới thì gọi để phát ngay, không đợi lượt định kỳ
  Future<int> kick() async {
    if (_running) {
      _again = true;
      return 0;
    }
    _running = true;
    var total = 0;
    try {
      do {
        _again = false;
        var sent = 0;
        do {
          sent = await _publishBatch();
          total += sent;
        } while (sent > 0);
      } while (_again);
    } on Object catch (e) {
      stderr.writeln('Phát sự kiện lên RabbitMQ lỗi, thử lại sau: $e');
    } finally {
      _running = false;
    }
    return total;
  }

  Future<int> _publishBatch() async {
    final rows = await _store.after(await _store.cursor());
    if (rows.isEmpty) return 0;
    await _bus.publishAll([
      for (final r in rows)
        (
          routingKey: routingKeyFor(
            r['region'] as String,
            r['source_service'] as String,
            r['event_type'] as String,
          ),
          body: {
            'id': r['id'],
            'eventId': r['event_id'],
            'region': r['region'],
            'sourceService': r['source_service'],
            'eventType': r['event_type'],
            'aggregateId': r['aggregate_id'],
            'occurredAt': (r['occurred_at'] as DateTime)
                .toUtc()
                .toIso8601String(),
            'hash': r['hash'],
          },
        ),
    ]);
    await _store.advance(rows.last['id'] as int);
    return rows.length;
  }
}
