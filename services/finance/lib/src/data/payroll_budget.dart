/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:finance_service/src/domain/finance_rules.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Ngân sách lương mỗi kỳ cho Saga chốt lương: giữ chỗ, nhả, ghi chi
abstract interface class PayrollBudgets {
  /// Giữ ngân sách (bước bù trừ được); gọi lại cùng đợt thì giữ nguyên
  Future<String> reserve({
    required String period,
    required String runId,
    required String amount,
    required String currency,
    String? limit,
  });

  /// Bù trừ: nhả ngân sách đã giữ; chưa giữ thì thôi
  Future<String> release(String period, String runId);

  /// Sau khi ngân hàng chuyển (sau pivot): ghi chi phí lương thật
  Future<String> spend({
    required String period,
    required String runId,
    required String amount,
    required int paidCount,
  });
}

class PostgresPayrollBudgets implements PayrollBudgets {
  PostgresPayrollBudgets(this._db);

  final Database _db;

  @override
  Future<String> reserve({
    required String period,
    required String runId,
    required String amount,
    required String currency,
    String? limit,
  }) {
    return _db.transaction((tx) async {
      final closed = await tx.execute(
        Sql.named('select 1 from period_closings where period = @period'),
        parameters: {'period': period},
      );
      if (closed.isNotEmpty) {
        throw FinanceRuleViolation(
          'period_closed',
          'Finance period $period is closed',
        );
      }
      if (limit != null && double.parse(amount) > double.parse(limit)) {
        throw FinanceRuleViolation(
          'budget_exceeded',
          'Payroll $amount exceeds budget $limit $currency',
        );
      }
      final rows = await tx.execute(
        Sql.named(
          'insert into payroll_budgets (period, run_id, amount, currency) '
          'values (@period, @run, @amount::numeric, @currency) '
          'on conflict (period) do update set run_id = excluded.run_id, '
          "amount = excluded.amount, status = 'reserved', updated_at = now() "
          "where payroll_budgets.status <> 'spent' returning status",
        ),
        parameters: {
          'period': period,
          'run': runId,
          'amount': amount,
          'currency': currency,
        },
      );
      return rows.isEmpty ? 'spent' : 'reserved';
    });
  }

  @override
  Future<String> release(String period, String runId) async {
    final current = await _db.query(
      'select status from payroll_budgets where period = @period '
      'and run_id = @run',
      params: {'period': period, 'run': runId},
      fromPrimary: true,
    );
    if (current.isEmpty) return 'none';
    if (current.first['status'] == 'spent') {
      throw FinanceRuleViolation(
        'already_spent',
        'Payroll budget $period was already spent',
      );
    }
    await _db.execute(
      "update payroll_budgets set status = 'released', updated_at = now() "
      'where period = @period and run_id = @run',
      params: {'period': period, 'run': runId},
    );
    return 'released';
  }

  @override
  Future<String> spend({
    required String period,
    required String runId,
    required String amount,
    required int paidCount,
  }) {
    return _db.transaction((tx) async {
      final rows = await tx.execute(
        Sql.named(
          "update payroll_budgets set status = 'spent', "
          'spent_amount = @amount::numeric, paid_count = @count, '
          'updated_at = now() where period = @period and run_id = @run '
          "and status <> 'spent' returning currency",
        ),
        parameters: {
          'period': period,
          'run': runId,
          'amount': amount,
          'count': paidCount,
        },
      );
      // Ghi rồi thì gọi lại vẫn trả thành công (bước thử lại được)
      if (rows.isEmpty) return 'spent';
      await addOutboxEvent(
        tx,
        aggregate: 'payroll_budget',
        aggregateId: period,
        eventType: 'PayrollExpenseRecorded',
        payload: {
          'period': period,
          'runId': runId,
          'amount': amount,
          'currency': rows.first[0],
          'paidCount': paidCount,
        },
      );
      return 'spent';
    });
  }
}
