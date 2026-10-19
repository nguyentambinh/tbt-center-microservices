/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'package:audit_service/src/event_relay.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

class _MemoryStore implements RelayStore {
  _MemoryStore(this.rows);

  final List<Map<String, dynamic>> rows;
  int last = 0;

  @override
  Future<int> cursor() async => last;

  @override
  Future<List<Map<String, dynamic>>> after(int id, {int limit = 200}) async =>
      rows.where((r) => (r['id'] as int) > id).take(limit).toList();

  @override
  Future<void> advance(int id) async => last = id;
}

class _FakeBus implements EventBus {
  final sent = <BusMessage>[];
  bool failNext = false;

  @override
  Future<void> publishAll(List<BusMessage> messages) async {
    if (failNext) {
      failNext = false;
      throw const FormatException('mất kết nối');
    }
    sent.addAll(messages);
  }

  @override
  void subscribe(String queue, List<String> bindings, EventHandler onEvent) {}

  @override
  Future<void> close() async {}
}

Map<String, dynamic> _event(int id, String type) => {
  'id': id,
  'event_id': 'e$id',
  'region': 'vn',
  'source_service': 'attendance',
  'event_type': type,
  'aggregate_id': 'L$id',
  'occurred_at': DateTime.utc(2026, 10, 17, 3),
  'hash': 'h$id',
};

void main() {
  test(
    'phát sự kiện mới theo khóa khu vực.service.loại, không kèm payload',
    () async {
      final store = _MemoryStore([
        _event(1, 'LeaveApproved'),
        _event(2, 'OvertimeApproved'),
      ]);
      final bus = _FakeBus();
      expect(await EventRelay(store, bus).kick(), 2);
      expect(bus.sent.map((m) => m.routingKey), [
        'vn.attendance.LeaveApproved',
        'vn.attendance.OvertimeApproved',
      ]);
      expect(bus.sent.first.body.containsKey('payload'), isFalse);
      expect(bus.sent.first.body['eventId'], 'e1');
      expect(store.last, 2);
    },
  );

  test(
    'RabbitMQ lỗi thì không dời điểm đánh dấu, lần sau gửi lại đủ',
    () async {
      final store = _MemoryStore([_event(1, 'LeaveApproved')]);
      final bus = _FakeBus()..failNext = true;
      final relay = EventRelay(store, bus);
      expect(await relay.kick(), 0);
      expect(store.last, 0);
      expect(await relay.kick(), 1);
      expect(bus.sent.single.body['id'], 1);
    },
  );
}
