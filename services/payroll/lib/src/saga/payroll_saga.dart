/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:async';
import 'dart:io';

import 'package:payroll_service/src/saga/payroll_run_repository.dart';

/// Lấy giờ công từ service attendance: employeeId → giờ tăng ca.
typedef HoursSource = Future<Map<String, double>> Function(String period);

/// Lấy tỷ giá từ service currency: (tỷ giá dạng chuỗi, ngày tỷ giá).
typedef RateSource = Future<({String rate, DateTime date})> Function(
  String currency,
  DateTime date,
);

/// Chi lương qua integration; dừng giữa chừng thì ném [PayoutFailed]
typedef PayoutSink = Future<Map<String, String>> Function(
  List<({String reference, String account, double amount, String currency})>
  items,
);

/// Khóa, mở kỳ ở attendance (semantic lock)
typedef PeriodLock = Future<void> Function(String period, String runId);

/// Giữ ngân sách lương của kỳ ở finance
typedef BudgetReserve = Future<void> Function(
  String period,
  String runId,
  String amount,
);

/// Nhả ngân sách đã giữ (bù trừ)
typedef BudgetRelease = Future<void> Function(String period, String runId);

/// Ghi chi phí lương sang finance sau khi ngân hàng đã chuyển
typedef ExpenseRecord = Future<void> Function(
  String period,
  String runId,
  String amount,
  int count,
);

class PayoutFailed implements Exception {
  const PayoutFailed(this.reason, this.paid);

  final String reason;

  /// Các khoản ngân hàng đã chuyển trước khi lỗi, vẫn phải ghi nhận.
  final Map<String, String> paid;

  @override
  String toString() => reason;
}

/// Không biết ngân hàng đã chuyển chưa (quá hạn, mất kết nối)
class PayoutInDoubt implements Exception {
  const PayoutInDoubt(this.reason);

  final String reason;

  @override
  String toString() => 'Không rõ kết quả chi: $reason';
}

/// Thử lại hết lượt mà vẫn lỗi
class RetryExhausted implements Exception {
  const RetryExhausted(this.step, this.last);

  final String step;
  final Object last;

  @override
  String toString() => '$step thử lại hết lượt: $last';
}

/// Thuế, khấu trừ ước tính theo nước (mô phỏng, chưa phải biểu thuế thật).
const deductionRateByCountry = {
  'VN': 0.105,
  'DE': 0.38,
  'US': 0.25,
  'BR': 0.27,
  'ZA': 0.26,
  'AU': 0.28,
};

/// Giờ chuẩn một tháng để quy lương tháng ra lương giờ.
const standardHours = 176;

/// Saga chốt lương: bước bù trừ được → pivot (pay) → bước thử lại được
class PayrollSaga {
  PayrollSaga({
    required this.repository,
    required this.hours,
    required this.rate,
    required this.payout,
    required this.lockPeriod,
    required this.unlockPeriod,
    required this.reserveBudget,
    required this.releaseBudget,
    required this.recordExpense,
    required this.countryCode,
    required this.region,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
      Duration(seconds: 8),
      Duration(seconds: 16),
    ],
    this.stepTimeout = const Duration(seconds: 30),
    this.payTimeout = const Duration(minutes: 20),
  });

  final PayrollRunRepository repository;
  final HoursSource hours;
  final RateSource rate;
  final PayoutSink payout;
  final PeriodLock lockPeriod;
  final PeriodLock unlockPeriod;
  final BudgetReserve reserveBudget;
  final BudgetRelease releaseBudget;
  final ExpenseRecord recordExpense;
  final String countryCode;
  final String region;

  /// Khoảng chờ giữa các lần thử lại (giãn dần)
  final List<Duration> retryDelays;

  /// Hạn chót mỗi bước; quá hạn tính là lỗi
  final Duration stepTimeout;
  final Duration payTimeout;

  /// Đợt đang chạy trong tiến trình này, watchdog không đụng vào
  final active = <String>{};

  static String referenceFor(String period, String employeeId) =>
      'PAY-$period-$employeeId';

  Future<void> execute(String runId, String period) async {
    if (!active.add(runId)) return;
    try {
      await _execute(runId, period);
    } finally {
      active.remove(runId);
    }
  }

  Future<void> _execute(String runId, String period) async {
    final done = await repository.doneSteps(runId);
    var step = 'lock_period';

    Future<void> run(
      String name,
      Future<String> Function() body, {
      Duration? timeout,
    }) async {
      step = name;
      if (done.contains(name)) return;
      final detail = await body().timeout(timeout ?? stepTimeout);
      await repository.logStep(runId, name, 'done', detail);
      done.add(name);
    }

    // Trước pivot: lỗi thì bù trừ
    try {
      await run('lock_period', () async {
        await lockPeriod(period, runId);
        return 'attendance khóa kỳ $period, không duyệt thêm đơn';
      });

      if (!done.contains('calculate')) {
        step = 'collect_hours';
        final overtime = await hours(period).timeout(stepTimeout);
        await repository.logStep(
          runId,
          step,
          'done',
          '${overtime.length} nhân viên có chấm công',
        );

        step = 'fetch_rate';
        final salaries = await repository.salaries();
        final currency = salaries.isEmpty ? 'USD' : salaries.first.currency;
        final month = DateTime.parse('$period-01');
        final payDay = DateTime(month.year, month.month + 1, 5);
        final fx = await rate(currency, payDay).timeout(stepTimeout);
        await repository.logStep(
          runId,
          step,
          'done',
          '1 USD = ${fx.rate} $currency',
        );

        await run('calculate', () async {
          final deduction = deductionRateByCountry[countryCode] ?? 0.25;
          final usdRate = double.parse(fx.rate);
          final drafts = [
            for (final s in salaries)
              _draft(s, overtime[s.employeeId] ?? 0, deduction, fx, usdRate),
          ];
          await repository.saveDrafts(runId, period, drafts);
          return '${drafts.length} phiếu lương';
        });
      }

      await run('reserve_budget', () async {
        final unpaid = await repository.unpaid(runId);
        final paid = await repository.paidTotal(runId);
        final total =
            unpaid.fold<double>(0, (sum, p) => sum + p.net) +
            double.parse(paid.amount);
        final amount = total.toStringAsFixed(2);
        await reserveBudget(period, runId, amount);
        return 'finance giữ $amount cho kỳ $period';
      });

      step = 'pay';
      if (!done.contains('pay')) {
        try {
          await _pay(runId, period);
        } on TimeoutException catch (e) {
          await _resolveInDoubt(runId, period, e);
          return;
        } on PayoutInDoubt catch (e) {
          await _resolveInDoubt(runId, period, e);
          return;
        }
      }
      done.add('pay');
    } on Exception catch (e) {
      stderr.writeln('Saga chốt lương $period lỗi ở bước $step: $e');
      await repository.logStep(runId, step, 'failed', e.toString());
      final partial = e is PayoutFailed && e.paid.isNotEmpty;
      await _compensate(runId, period, 'Lỗi ở bước $step: $e', done, partial);
      return;
    }

    // Sau pivot: chỉ được tiến, thử lại tới khi xong
    try {
      await _forward(runId, 'record_expense', done, () async {
        final paid = await repository.paidTotal(runId);
        await recordExpense(period, runId, paid.amount, paid.count);
        return 'finance ghi chi ${paid.amount} cho ${paid.count} người';
      });
      await _forward(runId, 'issue_payslips', done, () async {
        final n = await repository.issuePayslips(runId, period);
        return 'gửi phiếu lương cho $n nhân viên';
      });
      await _forward(runId, 'unlock_period', done, () async {
        await unlockPeriod(period, runId);
        return 'mở khóa kỳ $period';
      });
      await repository.complete(runId, region: region);
    } on RetryExhausted catch (e) {
      // Tiền đã chuyển nên không bù trừ được, phải có người xử lý
      await repository.markNeedsAttention(runId, e.toString());
    }
  }

  Future<void> _pay(String runId, String period) async {
    final unpaid = await repository.unpaid(runId);
    final byReference = {
      for (final p in unpaid) referenceFor(period, p.employeeId): p,
    };
    Map<String, String> paid;
    try {
      paid = await payout([
        for (final entry in byReference.entries)
          (
            reference: entry.key,
            account: 'ACC-${entry.value.employeeId}',
            amount: entry.value.net,
            currency: entry.value.currency,
          ),
      ]).timeout(payTimeout);
    } on PayoutFailed catch (e) {
      await _recordPaid(runId, byReference, e.paid);
      rethrow;
    }
    await _recordPaid(runId, byReference, paid);
    await repository.logStep(runId, 'pay', 'done', '${paid.length} khoản');
  }

  /// Pivot không rõ kết quả: không bù trừ, chi lại cùng mã để đối soát
  Future<void> _resolveInDoubt(String runId, String period, Object e) async {
    await repository.logStep(runId, 'pay', 'in_doubt', e.toString());
    try {
      await _retry(runId, 'pay', () async {
        try {
          await _pay(runId, period);
        } on TimeoutException catch (e) {
          throw PayoutInDoubt('$e');
        }
        return 'đối soát xong';
      });
    } on RetryExhausted catch (e) {
      await repository.markNeedsAttention(
        runId,
        'Không rõ ngân hàng đã chuyển chưa, cần đối soát tay: $e',
      );
      return;
    }
    // Đối soát xong thì chạy tiếp các bước sau pivot
    await _execute(runId, period);
  }

  /// Bước sau pivot: thử lại giãn cách, hết lượt thì ném [RetryExhausted]
  Future<void> _forward(
    String runId,
    String step,
    Set<String> done,
    Future<String> Function() body,
  ) async {
    if (done.contains(step)) return;
    final detail = await _retry(runId, step, body);
    await repository.logStep(runId, step, 'done', detail);
    done.add(step);
  }

  Future<String> _retry(
    String runId,
    String step,
    Future<String> Function() body,
  ) async {
    Object last = 'chưa chạy';
    for (var i = 0; i <= retryDelays.length; i++) {
      try {
        return await body().timeout(stepTimeout);
      } on Exception catch (e) {
        last = e;
        if (i == retryDelays.length) break;
        await repository.logStep(runId, step, 'retry', 'lần ${i + 1}: $e');
        await Future<void>.delayed(retryDelays[i]);
      }
    }
    throw RetryExhausted(step, last);
  }

  /// Bù trừ ngược thứ tự; đã chi một phần thì giữ ngân sách và khóa kỳ
  Future<void> _compensate(
    String runId,
    String period,
    String reason,
    Set<String> done,
    bool partial,
  ) async {
    try {
      if (!partial && done.contains('reserve_budget')) {
        await _retry(runId, 'release_budget', () async {
          await releaseBudget(period, runId);
          return 'đã nhả ngân sách';
        });
        await repository.logStep(
          runId,
          'release_budget',
          'done',
          'nhả ngân sách',
        );
      }
      if (!partial && done.contains('lock_period')) {
        await _retry(runId, 'unlock_period', () async {
          await unlockPeriod(period, runId);
          return 'đã mở khóa kỳ';
        });
        await repository.logStep(runId, 'unlock_period', 'done', 'mở khóa kỳ');
      }
      await repository.compensate(
        runId,
        partial ? '$reason (đã chi một phần, chạy lại để chi nốt)' : reason,
      );
    } on RetryExhausted catch (e) {
      // Bù trừ cũng lỗi: không im lặng bỏ qua, chờ người xử lý
      await repository.markNeedsAttention(runId, 'Bù trừ lỗi: $e. $reason');
    }
  }

  Future<void> _recordPaid(
    String runId,
    Map<String, UnpaidPayslip> byReference,
    Map<String, String> paid,
  ) async {
    for (final entry in paid.entries) {
      final slip = byReference[entry.key];
      if (slip != null) {
        await repository.markPaid(runId, slip.employeeId, entry.value);
      }
    }
  }

  DraftPayslip _draft(
    SalaryRow salary,
    double overtimeHours,
    double deduction,
    ({String rate, DateTime date}) fx,
    double usdRate,
  ) {
    final hourly = salary.baseSalary / standardHours;
    final gross = _round(salary.baseSalary + overtimeHours * hourly * 1.5);
    final net = _round(gross * (1 - deduction));
    return DraftPayslip(
      employeeId: salary.employeeId,
      gross: gross,
      net: net,
      currency: salary.currency,
      rate: fx.rate,
      rateDate: fx.date,
      netUsd: _round(net / usdRate),
    );
  }

  static double _round(double v) => (v * 100).roundToDouble() / 100;
}
