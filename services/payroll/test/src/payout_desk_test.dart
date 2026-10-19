/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-19
 */

import 'package:payroll_service/src/payout_desk.dart';
import 'package:payroll_service/src/saga/payroll_saga.dart';
import 'package:test/test.dart';

class FakePayoutStore implements PayoutStore {
  FakePayoutStore(this.items);

  final Map<String, PayoutLine> items;
  final log = <PayoutLogEntry>[];
  String? status = 'completed';

  @override
  Future<String?> runStatus(String period) async => status;

  @override
  Future<List<PayoutLine>> lines(String period) async => items.values.toList();

  @override
  Future<void> record(
    String period,
    String actor,
    List<PayoutLogEntry> entries,
  ) async {
    log.addAll(entries);
    for (final e in entries) {
      final line = items[e.employeeId]!;
      if (e.action == 'paid' || e.action == 'resent') {
        items[e.employeeId] = PayoutLine(
          employeeId: line.employeeId,
          status: 'paid',
          net: line.net,
          currency: line.currency,
          resent: line.resent + (e.action == 'resent' ? 1 : 0),
        );
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> history(
    String period, {
    String? employeeId,
  }) async => const [];
}

/// Chờ phần chuyển ở nền xong
Future<PayoutDone> _finish(PayoutOutcome outcome) async => switch (outcome) {
  PayoutAccepted(:final done) => done,
  PayoutDone() => outcome,
  _ => throw StateError('$outcome'),
};

PayoutLine _line(String id, String status) =>
    PayoutLine(employeeId: id, status: status, net: 1000, currency: 'VND');

void main() {
  late FakePayoutStore store;
  late List<String> sent;
  late PayoutDesk desk;
  Object? failWith;
  var doubts = 0;

  setUp(() {
    store = FakePayoutStore({
      'E1': _line('E1', 'paid'),
      'E2': _line('E2', 'draft'),
    });
    sent = [];
    failWith = null;
    doubts = 0;
    desk = PayoutDesk(
      store: store,
      payout: (items) async {
        if (doubts > 0) {
          doubts--;
          // Kênh chi đã nhận lệnh nhưng trả lời quá hạn
          sent.add(items.first.reference);
          throw const PayoutInDoubt('quá hạn');
        }
        final paid = <String, String>{};
        for (final i in items) {
          if (failWith != null && sent.isNotEmpty) {
            throw PayoutFailed('$failWith', paid);
          }
          sent.add(i.reference);
          paid[i.reference] = 'BANK-${i.reference}';
        }
        return paid;
      },
    );
  });

  test('có người đã nhận thì cảnh báo, chưa chuyển cho ai', () async {
    final outcome = await desk.transfer(period: '2026-10', actor: 'fin');
    expect(outcome, isA<DuplicatesFound>());
    final found = outcome as DuplicatesFound;
    expect([for (final d in found.duplicates) d.employeeId], ['E1']);
    expect(found.pending, 1);
    expect(sent, isEmpty);
    expect(store.log.single.action, 'duplicate_warning');
  });

  test('bỏ qua người đã nhận, chỉ chuyển người chưa nhận', () async {
    final outcome = await _finish(
      await desk.transfer(
        period: '2026-10',
        actor: 'fin',
        mode: DuplicateMode.skip,
      ),
    );
    expect((outcome.paid, outcome.skipped), (1, 1));
    expect(sent, ['PAY-2026-10-E2']);
    expect([for (final e in store.log) e.action], ['skipped', 'paid']);
  });

  test('chuyển lại dùng mã mới mỗi lần', () async {
    for (var i = 0; i < 2; i++) {
      await _finish(
        await desk.transfer(
          period: '2026-10',
          actor: 'fin',
          employeeIds: ['E1'],
          mode: DuplicateMode.resend,
        ),
      );
    }
    expect(sent, ['PAY-2026-10-E1-R1', 'PAY-2026-10-E1-R2']);
    expect(store.items['E1']!.transfers, 3);
  });

  test('chọn người không có phiếu lương thì báo thiếu', () async {
    final outcome = await _finish(
      await desk.transfer(
        period: '2026-10',
        actor: 'fin',
        employeeIds: ['E2', 'E9'],
      ),
    );
    expect(outcome.paid, 1);
    expect(outcome.missing, ['E9']);
  });

  test('kỳ đang chốt hoặc chưa có phiếu thì không chuyển', () async {
    store.status = 'running';
    expect(
      await desk.transfer(period: '2026-10', actor: 'fin'),
      isA<RunInProgress>(),
    );
    store
      ..status = null
      ..items.clear();
    expect(
      await desk.transfer(period: '2026-10', actor: 'fin'),
      isA<NotCalculated>(),
    );
  });

  test('kênh chi lỗi giữa chừng: ghi khoản đã chuyển và khoản lỗi', () async {
    store.items['E3'] = _line('E3', 'draft');
    failWith = 'Bank 503';
    final outcome = await _finish(
      await desk.transfer(
        period: '2026-10',
        actor: 'fin',
        mode: DuplicateMode.skip,
      ),
    );
    expect((outcome.paid, outcome.failed), (1, 1));
    expect(outcome.failure, 'Bank 503');
    expect(store.log.last.action, 'failed');
  });

  test('quá hạn thì gửi lại đúng mã để đối soát', () async {
    doubts = 1;
    final outcome = await _finish(
      await desk.transfer(
        period: '2026-10',
        actor: 'fin',
        employeeIds: ['E2'],
      ),
    );
    expect(outcome.paid, 1);
    expect(sent, ['PAY-2026-10-E2', 'PAY-2026-10-E2']);
  });

  test('đối soát hết lượt vẫn không rõ thì ghi in_doubt', () async {
    doubts = 3;
    final outcome = await _finish(
      await desk.transfer(
        period: '2026-10',
        actor: 'fin',
        employeeIds: ['E2'],
      ),
    );
    expect(outcome.failed, 1);
    expect(store.log.last.action, 'in_doubt');
    expect(outcome.failure, startsWith('chưa rõ kết quả'));
  });
}
