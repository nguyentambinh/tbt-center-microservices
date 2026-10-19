/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:tbt_common/tbt_common.dart';

/// Vai trò xem được lương của người khác.
const payrollViewerRoles = {'finance', 'hr', 'admin', 'executive'};

abstract interface class PayrollRepository {
  /// Phiếu lương các kỳ, mới nhất trước.
  Future<List<Map<String, dynamic>>> payslips(String employeeId);

  Future<Map<String, dynamic>?> salary(String employeeId);

  Future<List<Map<String, dynamic>>> bonusesPenalties(String employeeId);
}

class PostgresPayrollRepository implements PayrollRepository {
  PostgresPayrollRepository(this._db);

  final Database _db;

  @override
  Future<List<Map<String, dynamic>>> payslips(String employeeId) async {
    final rows = await _db.query(
      'select id::text, period, gross_original::text, net_original::text, '
      'currency_original, rate_applied::text, rate_date, amount_base::text, '
      'paid_on from payslips where employee_id = @id order by period desc',
      params: {'id': employeeId},
    );
    return [
      for (final r in rows)
        {
          'id': r['id'],
          'period': r['period'],
          'gross': r['gross_original'],
          'net': r['net_original'],
          'currency': r['currency_original'],
          'rateApplied': r['rate_applied'],
          'rateDate': _date(r['rate_date']),
          'netUsd': r['amount_base'],
          'paidOn': _date(r['paid_on']),
        },
    ];
  }

  @override
  Future<Map<String, dynamic>?> salary(String employeeId) async {
    final rows = await _db.query(
      'select employment_type, base_salary::text, currency from salaries '
      'where employee_id = @id',
      params: {'id': employeeId},
    );
    if (rows.isEmpty) return null;
    return {
      'employmentType': rows.first['employment_type'],
      'baseSalary': rows.first['base_salary'],
      'currency': rows.first['currency'],
    };
  }

  @override
  Future<List<Map<String, dynamic>>> bonusesPenalties(String employeeId) async {
    final rows = await _db.query(
      'select occurred_on, kind, amount_original::text, coefficient::text, '
      'total_original::text, currency_original from bonuses_penalties '
      'where employee_id = @id order by occurred_on desc',
      params: {'id': employeeId},
    );
    return [
      for (final r in rows)
        {
          'date': _date(r['occurred_on']),
          'kind': r['kind'],
          'amount': r['amount_original'],
          'coefficient': r['coefficient'],
          'total': r['total_original'],
          'currency': r['currency_original'],
        },
    ];
  }

  String? _date(Object? value) =>
      value is DateTime ? value.toIso8601String().substring(0, 10) : null;
}
