/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:payroll_service/src/saga/payroll_saga.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Vai trò xem được lương của người khác.
const payrollViewerRoles = {'finance', 'hr', 'executive'};

abstract interface class PayrollRepository {
  /// Phiếu lương các kỳ, mới nhất trước.
  Future<List<Map<String, dynamic>>> payslips(String employeeId);

  Future<Map<String, dynamic>?> salary(String employeeId);

  Future<List<Map<String, dynamic>>> bonusesPenalties(String employeeId);

  /// Tăng lương cơ bản theo phần trăm (thăng chức); `null` nếu chưa có lương.
  Future<Map<String, dynamic>?> raiseSalary(
    String employeeId, {
    required double percent,
    required String reason,
  });

  /// Văn phòng quản lý đổi lương cơ bản có hiệu lực ngay; `null` nếu chưa có
  /// bảng lương
  Future<Map<String, dynamic>?> setBaseSalary(
    String employeeId, {
    required double amount,
    required String by,
    String? reason,
  });

  /// Ghi một khoản thưởng hoặc phạt vào kỳ lương của ngày [occurredOn]
  Future<Map<String, dynamic>> addBonusPenalty({
    required String employeeId,
    required String kind,
    required double amount,
    required String currency,
    required DateTime occurredOn,
    required ({String rate, DateTime date}) rate,
    required String by,
    String? reason,
  });

  /// Tiền tệ của bảng lương nhân viên; `null` nếu chưa có
  Future<String?> currencyOf(String employeeId);

  /// Lương thỏa thuận lúc nhận việc; đã có lương thì giữ nguyên bản cũ
  Future<Map<String, dynamic>> setInitialSalary(
    String employeeId, {
    required double baseSalary,
    required String currency,
    required String employmentType,
  });

  /// Lương cơ bản của nhiều người (tham khảo mức lương theo chức vụ)
  Future<List<Map<String, dynamic>>> salariesOf(List<String> employeeIds);
}

class PostgresPayrollRepository implements PayrollRepository {
  PostgresPayrollRepository(this._db, {this.countryCode = 'VN'});

  final Database _db;
  final String countryCode;

  @override
  Future<List<Map<String, dynamic>>> payslips(String employeeId) async {
    final rows = await _db.query(
      'select id::text, period, gross_original::text, net_original::text, '
      'currency_original, rate_applied::text, rate_date, amount_base::text, '
      'paid_on, base_original::float8 as base, '
      'overtime_original::float8 as overtime, bonus_original::float8 as bonus, '
      'insurance_original::float8 as insurance, tax_original::float8 as tax '
      'from payslips where employee_id = @id order by period desc',
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
          ..._lines(r),
        },
    ];
  }

  /// Từng khoản của phiếu; phiếu cũ chưa lưu thì tách khoản trừ theo tỷ lệ
  /// bảo hiểm của nước, phần còn lại là thuế
  Map<String, Object?> _lines(Map<String, dynamic> r) {
    if (r['insurance'] != null) {
      return {
        'base': r['base'],
        'overtime': r['overtime'],
        'bonus': r['bonus'],
        'insurance': r['insurance'],
        'tax': r['tax'],
      };
    }
    final gross = double.parse(r['gross_original'] as String);
    final net = double.parse(r['net_original'] as String);
    final insurance =
        (gross * (insuranceRateByCountry[countryCode] ?? 0.08) * 100)
            .roundToDouble() /
        100;
    return {
      'insurance': insurance,
      'tax': ((gross - net - insurance) * 100).roundToDouble() / 100,
    };
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
      'total_original::text, currency_original, reason from bonuses_penalties '
      'where employee_id = @id order by occurred_on desc, id desc',
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
          'reason': r['reason'],
        },
    ];
  }

  String? _date(Object? value) =>
      value is DateTime ? value.toIso8601String().substring(0, 10) : null;

  @override
  Future<Map<String, dynamic>?> raiseSalary(
    String employeeId, {
    required double percent,
    required String reason,
  }) => _db.transaction((tx) async {
    final rows = await tx.execute(
      Sql.named(
        'update salaries set base_salary = round(base_salary * '
        '(1 + @percent / 100.0), 2) where employee_id = @id '
        'returning base_salary::text, currency',
      ),
      parameters: {'id': employeeId, 'percent': percent},
    );
    if (rows.isEmpty) return null;
    final result = {
      'employeeId': employeeId,
      'baseSalary': rows.first[0],
      'currency': rows.first[1],
      'percent': percent,
    };
    await addOutboxEvent(
      tx,
      aggregate: 'salary',
      aggregateId: employeeId,
      eventType: 'SalaryRaised',
      payload: {...result, 'reason': reason},
    );
    return result;
  });

  @override
  Future<Map<String, dynamic>?> setBaseSalary(
    String employeeId, {
    required double amount,
    required String by,
    String? reason,
  }) => _db.transaction((tx) async {
    final before = await tx.execute(
      Sql.named(
        'select base_salary::text from salaries where employee_id = @id '
        'for update',
      ),
      parameters: {'id': employeeId},
    );
    if (before.isEmpty) return null;
    final rows = await tx.execute(
      Sql.named(
        'update salaries set base_salary = @amount where employee_id = @id '
        'returning base_salary::text, currency',
      ),
      parameters: {'id': employeeId, 'amount': amount},
    );
    final result = {
      'employeeId': employeeId,
      'previous': before.first[0],
      'baseSalary': rows.first[0],
      'currency': rows.first[1],
    };
    await addOutboxEvent(
      tx,
      aggregate: 'salary',
      aggregateId: employeeId,
      eventType: 'SalaryChanged',
      payload: {...result, 'changedBy': by, 'reason': reason},
    );
    return result;
  });

  @override
  Future<String?> currencyOf(String employeeId) async {
    final rows = await _db.query(
      'select currency from salaries where employee_id = @id',
      params: {'id': employeeId},
      fromPrimary: true,
    );
    return rows.isEmpty ? null : rows.first['currency'] as String;
  }

  @override
  Future<Map<String, dynamic>> addBonusPenalty({
    required String employeeId,
    required String kind,
    required double amount,
    required String currency,
    required DateTime occurredOn,
    required ({String rate, DateTime date}) rate,
    required String by,
    String? reason,
  }) => _db.transaction((tx) async {
    final rows = await tx.execute(
      Sql.named(
        'insert into bonuses_penalties (employee_id, occurred_on, kind, '
        'amount_original, currency_original, coefficient, total_original, '
        'rate_applied, rate_date, amount_base, reason, created_by) values '
        '(@id, @on, @kind, @amount, @currency, 1, @amount, @rate::numeric, '
        '@rateDate, round(@amount / @rate::numeric, 2), @reason, @by) '
        'returning id',
      ),
      parameters: {
        'id': employeeId,
        'on': occurredOn,
        'kind': kind,
        'amount': amount,
        'currency': currency,
        'rate': rate.rate,
        'rateDate': rate.date,
        'reason': reason,
        'by': by,
      },
    );
    final result = {
      'id': rows.first[0],
      'employeeId': employeeId,
      'kind': kind,
      'amount': amount,
      'currency': currency,
      'date': _date(occurredOn),
      'reason': reason,
      'createdBy': by,
    };
    await addOutboxEvent(
      tx,
      aggregate: 'salary',
      aggregateId: employeeId,
      eventType: kind == 'bonus' ? 'BonusGranted' : 'PenaltyApplied',
      payload: result,
    );
    return result;
  });

  @override
  Future<Map<String, dynamic>> setInitialSalary(
    String employeeId, {
    required double baseSalary,
    required String currency,
    required String employmentType,
  }) => _db.transaction((tx) async {
    final inserted = await tx.execute(
      Sql.named(
        'insert into salaries (employee_id, employment_type, base_salary, '
        'currency) values (@id, @type, @salary, @currency) '
        'on conflict (employee_id) do nothing returning employee_id',
      ),
      parameters: {
        'id': employeeId,
        'type': employmentType,
        'salary': baseSalary,
        'currency': currency,
      },
    );
    final rows = await tx.execute(
      Sql.named(
        'select employment_type, base_salary::text, currency from salaries '
        'where employee_id = @id',
      ),
      parameters: {'id': employeeId},
    );
    final result = {
      'employeeId': employeeId,
      'employmentType': rows.first[0],
      'baseSalary': rows.first[1],
      'currency': rows.first[2],
    };
    if (inserted.isNotEmpty) {
      await addOutboxEvent(
        tx,
        aggregate: 'salary',
        aggregateId: employeeId,
        eventType: 'SalaryAgreed',
        payload: result,
      );
    }
    return result;
  });

  @override
  Future<List<Map<String, dynamic>>> salariesOf(
    List<String> employeeIds,
  ) async {
    if (employeeIds.isEmpty) return const [];
    final rows = await _db.query(
      'select employee_id, employment_type, base_salary::text, currency '
      'from salaries where employee_id = any(@ids)',
      params: {'ids': TypedValue(Type.textArray, employeeIds)},
    );
    return [
      for (final r in rows)
        {
          'employeeId': r['employee_id'],
          'employmentType': r['employment_type'],
          'baseSalary': r['base_salary'],
          'currency': r['currency'],
        },
    ];
  }
}
