/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:payroll_service/src/saga/payroll_run_repository.dart';
import 'package:payroll_service/src/saga/payroll_saga.dart';
import 'package:test/test.dart';

/// Repository giả trong bộ nhớ, ghi lại các bước để kiểm tra Saga.
class FakeRunRepository implements PayrollRunRepository {
  final steps = <String>[];
  final done = <String>{};
  final drafts = <String, DraftPayslip>{};
  final paid = <String, String>{};
  final issued = <String>[];
  String status = 'running';
  String? error;

  @override
  Future<void> logStep(
    String runId,
    String step,
    String status, [
    String? detail,
  ]) async {
    steps.add('$step:$status');
    if (status == 'done') done.add(step);
  }

  @override
  Future<Set<String>> doneSteps(String runId) async => {...done};

  @override
  Future<List<SalaryRow>> salaries() async => const [
    SalaryRow('E1', 17600000, 'VND'),
    SalaryRow('E2', 8800000, 'VND'),
  ];

  @override
  Future<void> saveDrafts(
    String runId,
    String period,
    List<DraftPayslip> list,
  ) async {
    for (final d in list) {
      if (!paid.containsKey(d.employeeId)) drafts[d.employeeId] = d;
    }
  }

  @override
  Future<List<UnpaidPayslip>> unpaid(String runId) async => [
    for (final d in drafts.values)
      if (!paid.containsKey(d.employeeId))
        UnpaidPayslip(d.employeeId, d.net, d.currency),
  ];

  @override
  Future<({String amount, int count})> paidTotal(String runId) async {
    final total = paid.keys.fold<double>(0, (s, e) => s + drafts[e]!.net);
    return (amount: total.toStringAsFixed(2), count: paid.length);
  }

  @override
  Future<int> issuePayslips(String runId, String period) async {
    issued.addAll(paid.keys);
    return paid.length;
  }

  @override
  Future<void> markPaid(String runId, String employeeId, String ref) async =>
      paid[employeeId] = ref;

  @override
  Future<void> compensate(String runId, String reason) async {
    drafts.removeWhere((employee, _) => !paid.containsKey(employee));
    status = 'failed';
    error = reason;
    steps.add('compensate:done');
  }

  @override
  Future<void> markNeedsAttention(String runId, String reason) async {
    status = 'needs_attention';
    error = reason;
    steps.add('needs_attention:failed');
  }

  @override
  Future<void> complete(String runId, {required String region}) async {
    status = 'completed';
    steps.add('complete:done');
  }

  /// Bấm chạy lại: các bước cũ không còn tính là xong
  void retry() {
    done.clear();
    status = 'running';
  }

  @override
  Future<({String id, String status, bool created})> createRun(
    String period,
    String startedBy,
  ) => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>?> run(String id) => throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> runs() => throw UnimplementedError();

  @override
  Future<List<String>> runningRunIds() => throw UnimplementedError();

  @override
  Future<List<String>> stalledRunIds(Duration idle) =>
      throw UnimplementedError();

  @override
  Future<int> countAttempt(String runId) => throw UnimplementedError();

  @override
  Future<void> markRunning(String runId) async => status = 'running';
}

void main() {
  late FakeRunRepository repository;
  late List<String> bankCalls;
  late List<String> calls;
  late int bankDownAfter;
  late bool attendanceDown;
  late bool attendanceHangs;
  late int expenseFailures;
  late bool releaseBroken;
  late bool overBudget;
  late int inDoubt;
  late Map<String, String> bankLedger;

  PayrollSaga saga() => PayrollSaga(
    repository: repository,
    countryCode: 'VN',
    region: 'vn',
    retryDelays: const [Duration.zero, Duration.zero, Duration.zero],
    stepTimeout: const Duration(milliseconds: 200),
    hours: (period) async {
      if (attendanceDown) throw Exception('attendance lỗi');
      if (attendanceHangs) await Future<void>.delayed(const Duration(hours: 1));
      return {'E1': 8};
    },
    rate: (currency, date) async => (rate: '26000', date: date),
    payout: (items) async {
      final done = <String, String>{};
      // Ngân hàng chuyển xong nhưng trả lời quá hạn: không biết kết quả
      if (inDoubt > 0) {
        inDoubt--;
        for (final item in items) {
          bankLedger[item.reference] = 'BNK-${item.reference}';
        }
        throw const PayoutInDoubt('integration timeout');
      }
      for (final item in items) {
        // Ngân hàng chống chuyển trùng theo mã tham chiếu
        if (bankLedger.containsKey(item.reference)) {
          done[item.reference] = bankLedger[item.reference]!;
          continue;
        }
        if (bankDownAfter >= 0 && bankCalls.length >= bankDownAfter) {
          throw PayoutFailed('bank down', done);
        }
        bankCalls.add(item.reference);
        bankLedger[item.reference] = 'BNK-${item.reference}';
        done[item.reference] = 'BNK-${item.reference}';
      }
      return done;
    },
    lockPeriod: (period, runId) async => calls.add('lock $period'),
    unlockPeriod: (period, runId) async => calls.add('unlock $period'),
    reserveBudget: (period, runId, amount) async {
      if (overBudget) throw Exception('budget_exceeded');
      calls.add('reserve $amount');
    },
    releaseBudget: (period, runId) async {
      if (releaseBroken) throw Exception('finance lỗi');
      calls.add('release');
    },
    recordExpense: (period, runId, amount, count) async {
      if (expenseFailures > 0) {
        expenseFailures--;
        throw Exception('finance lỗi');
      }
      calls.add('expense $amount x$count');
    },
  );

  setUp(() {
    repository = FakeRunRepository();
    bankCalls = [];
    calls = [];
    bankDownAfter = -1;
    attendanceDown = false;
    attendanceHangs = false;
    expenseFailures = 0;
    releaseBroken = false;
    overBudget = false;
    inDoubt = 0;
    bankLedger = {};
  });

  test('chạy trơn tru: đủ ba loại bước, khóa rồi mở kỳ, ghi chi', () async {
    await saga().execute('R1', '2026-10');

    expect(repository.status, 'completed');
    expect(repository.steps, [
      'lock_period:done',
      'collect_hours:done',
      'fetch_rate:done',
      'calculate:done',
      'reserve_budget:done',
      'pay:done',
      'record_expense:done',
      'issue_payslips:done',
      'unlock_period:done',
      'complete:done',
    ]);
    // E1: 17.600.000 + 8 giờ × 100.000 × 1,5 = 18.800.000, trừ 10,5%.
    final e1 = repository.drafts['E1']!;
    expect(e1.net, 16826000);
    expect(calls, [
      'lock 2026-10',
      'reserve 24702000.00',
      'expense 24702000.00 x2',
      'unlock 2026-10',
    ]);
    expect(repository.issued, containsAll(['E1', 'E2']));
  });

  test('ngân hàng lỗi ngay: nhả ngân sách, mở khóa, hủy phiếu nháp', () async {
    bankDownAfter = 0;
    await saga().execute('R1', '2026-10');

    expect(repository.status, 'failed');
    expect(calls, [
      'lock 2026-10',
      'reserve 24702000.00',
      'release',
      'unlock 2026-10',
    ]);
    expect(repository.drafts, isEmpty);
    expect(
      repository.steps,
      containsAllInOrder([
        'pay:failed',
        'release_budget:done',
        'unlock_period:done',
        'compensate:done',
      ]),
    );
  });

  test(
    'chi được một phần: giữ ngân sách và khóa kỳ, chạy lại chi nốt',
    () async {
      bankDownAfter = 1;
      await saga().execute('R1', '2026-10');

      expect(repository.status, 'failed');
      expect(repository.paid.keys, ['E1']);
      expect(
        calls,
        isNot(contains('release')),
        reason: 'tiền đã chuyển một phần',
      );
      expect(calls, isNot(contains('unlock 2026-10')));

      bankDownAfter = -1;
      repository.retry();
      await saga().execute('R1', '2026-10');
      expect(repository.status, 'completed');
      expect(bankCalls, [
        'PAY-2026-10-E1',
        'PAY-2026-10-E2',
      ], reason: 'không chi lại cho E1');
    },
  );

  test('attendance lỗi: chỉ mở khóa kỳ, chưa giữ ngân sách', () async {
    attendanceDown = true;
    await saga().execute('R1', '2026-10');

    expect(repository.status, 'failed');
    expect(calls, ['lock 2026-10', 'unlock 2026-10']);
    expect(repository.error, contains('collect_hours'));
  });

  test('vượt ngân sách: không chi tiền, bù trừ phiếu nháp và khóa', () async {
    overBudget = true;
    await saga().execute('R1', '2026-10');

    expect(repository.status, 'failed');
    expect(bankCalls, isEmpty);
    expect(repository.drafts, isEmpty);
    expect(calls, ['lock 2026-10', 'unlock 2026-10']);
  });

  test('sau pivot lỗi tạm thời: thử lại rồi hoàn tất', () async {
    expenseFailures = 2;
    await saga().execute('R1', '2026-10');

    expect(repository.status, 'completed');
    expect(
      repository.steps.where((s) => s == 'record_expense:retry'),
      hasLength(2),
    );
  });

  test('sau pivot lỗi mãi: không bù trừ tiền, chờ xử lý tay', () async {
    expenseFailures = 99;
    await saga().execute('R1', '2026-10');

    expect(repository.status, 'needs_attention');
    expect(repository.paid, hasLength(2), reason: 'tiền đã chi giữ nguyên');
    expect(calls, isNot(contains('release')));
    expect(repository.error, contains('record_expense'));
  });

  test('bù trừ cũng lỗi: không im lặng bỏ qua, chờ xử lý tay', () async {
    bankDownAfter = 0;
    releaseBroken = true;
    await saga().execute('R1', '2026-10');

    expect(repository.status, 'needs_attention');
    expect(repository.error, contains('Bù trừ lỗi'));
    expect(
      repository.steps.where((s) => s == 'release_budget:retry'),
      hasLength(3),
    );
  });

  test('bước quá hạn tính là lỗi và được bù trừ', () async {
    attendanceHangs = true;
    await saga().execute('R1', '2026-10');

    expect(repository.status, 'failed');
    expect(repository.error, contains('TimeoutException'));
    expect(calls, ['lock 2026-10', 'unlock 2026-10']);
  });

  test('chạy tiếp sau khi đã chi: chỉ làm các bước sau pivot', () async {
    repository.done.addAll({
      'lock_period',
      'calculate',
      'reserve_budget',
      'pay',
    });
    repository.drafts['E1'] = DraftPayslip(
      employeeId: 'E1',
      gross: 1,
      net: 100,
      currency: 'VND',
      rate: '1',
      rateDate: DateTime(2026, 11, 5),
      netUsd: 1,
    );
    repository.paid['E1'] = 'BNK-1';
    await saga().execute('R1', '2026-10');

    expect(bankCalls, isEmpty, reason: 'không chi lại');
    expect(calls, ['expense 100.00 x1', 'unlock 2026-10']);
    expect(repository.status, 'completed');
  });
  test(
    'pivot không rõ: đối soát lại, không nhả ngân sách, không chi trùng',
    () async {
      inDoubt = 1;
      await saga().execute('R1', '2026-10');

      expect(repository.status, 'completed');
      expect(repository.paid, hasLength(2));
      expect(bankCalls, isEmpty, reason: 'ngân hàng đã chuyển ở lần đầu');
      expect(calls, isNot(contains('release')));
      expect(repository.steps, contains('pay:in_doubt'));
    },
  );

  test('pivot không bao giờ rõ: chờ đối soát tay, giữ ngân sách', () async {
    inDoubt = 99;
    await saga().execute('R1', '2026-10');

    expect(repository.status, 'needs_attention');
    expect(repository.error, contains('đối soát tay'));
    expect(calls, isNot(contains('release')));
  });
}
