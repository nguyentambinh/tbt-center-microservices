/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

class DraftPayslip {
  const DraftPayslip({
    required this.employeeId,
    required this.gross,
    required this.net,
    required this.currency,
    required this.rate,
    required this.rateDate,
    required this.netUsd,
    this.base,
    this.overtime,
    this.bonus,
    this.insurance,
    this.tax,
  });

  final String employeeId;
  final double gross;
  final double net;
  final String currency;
  final String rate;
  final DateTime rateDate;
  final double netUsd;

  /// Từng khoản của phiếu lương (tiền tệ gốc)
  final double? base;
  final double? overtime;
  final double? bonus;
  final double? insurance;
  final double? tax;
}

class UnpaidPayslip {
  const UnpaidPayslip(this.employeeId, this.net, this.currency);

  final String employeeId;
  final double net;
  final String currency;
}

class SalaryRow {
  const SalaryRow(this.employeeId, this.baseSalary, this.currency);

  final String employeeId;
  final double baseSalary;
  final String currency;
}

/// Lưu trạng thái Saga chốt lương ở database của payroll.
abstract interface class PayrollRunRepository {
  /// Tạo đợt cho kỳ; trả đợt đã có nếu kỳ này từng được chốt.
  Future<({String id, String status, bool created})> createRun(
    String period,
    String startedBy,
  );

  Future<Map<String, dynamic>?> run(String id);

  Future<List<Map<String, dynamic>>> runs();

  Future<List<String>> runningRunIds();

  Future<void> logStep(
    String runId,
    String step,
    String status, [
    String? detail,
  ]);

  Future<void> markRunning(String runId);

  Future<List<SalaryRow>> salaries();

  /// Ghi phiếu nháp; người đã được trả lương ở lần chạy trước thì giữ nguyên.
  Future<void> saveDrafts(
    String runId,
    String period,
    List<DraftPayslip> drafts,
  );

  /// Tổng thưởng (dương), phạt (âm) của từng người trong kỳ, tiền tệ gốc
  Future<Map<String, double>> bonuses(String period);

  Future<List<UnpaidPayslip>> unpaid(String runId);

  Future<void> markPaid(String runId, String employeeId, String bankReference);

  /// Bù trừ cục bộ: xóa phiếu nháp chưa chi, đánh dấu đợt lỗi, phát sự kiện.
  Future<void> compensate(String runId, String reason);

  /// Các bước đã xong của đợt (chạy lại thì bỏ qua)
  Future<Set<String>> doneSteps(String runId);

  /// Tổng tiền đã chi và số người đã nhận lương của đợt
  Future<({String amount, int count})> paidTotal(String runId);

  /// Phát phiếu lương cho từng người đã nhận (Outbox → notification)
  Future<int> issuePayslips(String runId, String period);

  /// Không tự xử lý được: chờ người xử lý tay, phát sự kiện báo
  Future<void> markNeedsAttention(String runId, String reason);

  /// Đợt đang chạy mà lâu không có bước mới (bị treo)
  Future<List<String>> stalledRunIds(Duration idle);

  /// Tăng số lần chạy lại, trả số lần sau khi tăng
  Future<int> countAttempt(String runId);

  /// Kết thúc: đánh dấu hoàn tất, phát sự kiện tổng hợp cho Hub.
  Future<void> complete(String runId, {required String region});
}

class PostgresPayrollRunRepository implements PayrollRunRepository {
  PostgresPayrollRunRepository(this._db);

  final Database _db;

  @override
  Future<({String id, String status, bool created})> createRun(
    String period,
    String startedBy,
  ) async {
    final inserted = await _db.execute(
      'insert into payroll_runs (period, started_by) values (@period, @by) '
      'on conflict (period) do nothing returning id::text',
      params: {'period': period, 'by': startedBy},
    );
    if (inserted.isNotEmpty) {
      return (
        id: inserted.first['id'] as String,
        status: 'running',
        created: true,
      );
    }
    final existing = await _db.query(
      'select id::text, status from payroll_runs where period = @period',
      params: {'period': period},
      fromPrimary: true,
    );
    return (
      id: existing.first['id'] as String,
      status: existing.first['status'] as String,
      created: false,
    );
  }

  @override
  Future<Map<String, dynamic>?> run(String id) async {
    final rows = await _db.query(
      'select id::text, period, status, started_by, error, created_at, '
      'updated_at from payroll_runs where id::text = @id',
      params: {'id': id},
      fromPrimary: true,
    );
    if (rows.isEmpty) return null;
    final steps = await _db.query(
      'select step, status, detail, at from payroll_run_steps '
      'where run_id::text = @id order by id',
      params: {'id': id},
      fromPrimary: true,
    );
    final totals = await _db.query(
      'select status, count(*)::int as n, coalesce(sum(net_original), 0)::text '
      'as net, coalesce(sum(amount_base), 0)::text as usd from payslips '
      'where run_id::text = @id group by status',
      params: {'id': id},
      fromPrimary: true,
    );
    return {
      ..._runJson(rows.first),
      'steps': [
        for (final s in steps)
          {
            'step': s['step'],
            'status': s['status'],
            'detail': s['detail'],
            'at': (s['at'] as DateTime).toIso8601String(),
          },
      ],
      'payslips': {
        for (final t in totals)
          t['status'] as String: {
            'count': t['n'],
            'totalNet': t['net'],
            'totalUsd': t['usd'],
          },
      },
    };
  }

  @override
  Future<List<Map<String, dynamic>>> runs() async {
    final rows = await _db.query(
      'select id::text, period, status, started_by, error, created_at, '
      'updated_at from payroll_runs order by period desc limit 24',
      fromPrimary: true,
    );
    return rows.map(_runJson).toList();
  }

  @override
  Future<List<String>> runningRunIds() async {
    final rows = await _db.query(
      "select id::text from payroll_runs where status = 'running'",
      fromPrimary: true,
    );
    return [for (final r in rows) r['id'] as String];
  }

  @override
  Future<void> logStep(
    String runId,
    String step,
    String status, [
    String? detail,
  ]) => _db.transaction((tx) async {
    await tx.execute(
      Sql.named(
        'insert into payroll_run_steps (run_id, step, status, detail) '
        'values (@id::uuid, @step, @status, @detail)',
      ),
      parameters: {
        'id': runId,
        'step': step,
        'status': status,
        'detail': detail,
      },
    );
    // Watchdog dựa vào updated_at để biết đợt có bị treo không
    await tx.execute(
      Sql.named(
        'update payroll_runs set updated_at = now() where id::text = @id',
      ),
      parameters: {'id': runId},
    );
  });

  @override
  Future<Set<String>> doneSteps(String runId) async {
    final rows = await _db.query(
      // Chỉ tính từ lần bấm chạy lại gần nhất: sau bù trừ phải làm lại từ đầu
      'select step from payroll_run_steps where run_id::text = @id '
      "and status = 'done' and id > coalesce((select max(id) from "
      "payroll_run_steps where run_id::text = @id and step = 'retry'), 0)",
      params: {'id': runId},
      fromPrimary: true,
    );
    return {for (final r in rows) r['step'] as String};
  }

  @override
  Future<({String amount, int count})> paidTotal(String runId) async {
    final rows = await _db.query(
      'select coalesce(sum(net_original), 0)::text as amount, '
      'count(*)::int as n from payslips where run_id::text = @id '
      "and status = 'paid'",
      params: {'id': runId},
      fromPrimary: true,
    );
    return (
      amount: rows.first['amount'] as String,
      count: rows.first['n'] as int,
    );
  }

  @override
  Future<int> issuePayslips(String runId, String period) {
    return _db.transaction((tx) async {
      final paid = await tx.execute(
        Sql.named(
          'select employee_id from payslips where run_id::text = @id '
          "and status = 'paid'",
        ),
        parameters: {'id': runId},
      );
      // Sự kiện lên sổ audit ở Hub: không mang số lương từng người
      for (final row in paid) {
        await addOutboxEvent(
          tx,
          aggregate: 'payslip',
          aggregateId: '$period-${row[0]}',
          eventType: 'PayslipIssued',
          payload: {'period': period, 'employeeId': row[0]},
        );
      }
      return paid.length;
    });
  }

  @override
  Future<void> markNeedsAttention(String runId, String reason) {
    return _db.transaction((tx) async {
      final rows = await tx.execute(
        Sql.named(
          "update payroll_runs set status = 'needs_attention', "
          'error = @reason, updated_at = now() where id::text = @id '
          'returning period',
        ),
        parameters: {'id': runId, 'reason': reason},
      );
      await tx.execute(
        Sql.named(
          'insert into payroll_run_steps (run_id, step, status, detail) '
          "values (@id::uuid, 'needs_attention', 'failed', @reason)",
        ),
        parameters: {'id': runId, 'reason': reason},
      );
      await addOutboxEvent(
        tx,
        aggregate: 'payroll_run',
        aggregateId: runId,
        eventType: 'PayrollRunNeedsAttention',
        payload: {
          'runId': runId,
          'period': rows.isEmpty ? null : rows.first[0],
          'reason': reason,
        },
      );
    });
  }

  @override
  Future<List<String>> stalledRunIds(Duration idle) async {
    final rows = await _db.query(
      "select id::text from payroll_runs where status = 'running' "
      'and updated_at < now() - make_interval(secs => @secs)',
      params: {'secs': idle.inSeconds},
      fromPrimary: true,
    );
    return [for (final r in rows) r['id'] as String];
  }

  @override
  Future<int> countAttempt(String runId) async {
    final rows = await _db.execute(
      'update payroll_runs set attempts = attempts + 1 where id::text = @id '
      'returning attempts',
      params: {'id': runId},
    );
    return rows.first['attempts'] as int;
  }

  @override
  Future<void> markRunning(String runId) => _db.execute(
    "update payroll_runs set status = 'running', error = null, "
    'attempts = 0, updated_at = now() where id::text = @id',
    params: {'id': runId},
  );

  @override
  Future<List<SalaryRow>> salaries() async {
    final rows = await _db.query(
      'select employee_id, base_salary::float8 as base, currency '
      'from salaries order by employee_id',
      fromPrimary: true,
    );
    return [
      for (final r in rows)
        SalaryRow(
          r['employee_id'] as String,
          r['base'] as double,
          r['currency'] as String,
        ),
    ];
  }

  @override
  Future<void> saveDrafts(
    String runId,
    String period,
    List<DraftPayslip> drafts,
  ) {
    return _db.transaction((tx) async {
      for (final d in drafts) {
        await tx.execute(
          Sql.named(
            'insert into payslips (employee_id, period, gross_original, '
            'net_original, currency_original, rate_applied, rate_date, '
            'amount_base, status, run_id, base_original, overtime_original, '
            'bonus_original, insurance_original, tax_original) values '
            '(@employee, @period, @gross, @net, @currency, @rate::numeric, '
            "@rateDate, @usd, 'draft', @run::uuid, @base, @overtime, @bonus, "
            '@insurance, @tax) on conflict (employee_id, period) do nothing',
          ),
          parameters: {
            'employee': d.employeeId,
            'period': period,
            'gross': d.gross,
            'net': d.net,
            'currency': d.currency,
            'rate': d.rate,
            'rateDate': d.rateDate,
            'usd': d.netUsd,
            'run': runId,
            'base': d.base,
            'overtime': d.overtime,
            'bonus': d.bonus,
            'insurance': d.insurance,
            'tax': d.tax,
          },
        );
      }
    });
  }

  @override
  Future<Map<String, double>> bonuses(String period) async {
    final rows = await _db.query(
      "select employee_id, coalesce(sum(case when kind = 'penalty' "
      'then -total_original else total_original end), 0)::float8 as total '
      "from bonuses_penalties where to_char(occurred_on, 'YYYY-MM') = @period "
      'group by employee_id',
      params: {'period': period},
      fromPrimary: true,
    );
    return {
      for (final r in rows) r['employee_id'] as String: r['total'] as double,
    };
  }

  @override
  Future<List<UnpaidPayslip>> unpaid(String runId) async {
    final rows = await _db.query(
      'select employee_id, net_original::float8 as net, currency_original '
      "from payslips where run_id::text = @id and status = 'draft' "
      'order by employee_id',
      params: {'id': runId},
      fromPrimary: true,
    );
    return [
      for (final r in rows)
        UnpaidPayslip(
          r['employee_id'] as String,
          r['net'] as double,
          r['currency_original'] as String,
        ),
    ];
  }

  @override
  Future<void> markPaid(
    String runId,
    String employeeId,
    String bankReference,
  ) => _db.transaction((tx) async {
    final params = {
      'ref': bankReference,
      'run': runId,
      'employee': employeeId,
    };
    await tx.execute(
      Sql.named(
        "update payslips set status = 'paid', paid_on = current_date, "
        'bank_reference = @ref where run_id::text = @run '
        'and employee_id = @employee',
      ),
      parameters: params,
    );
    await tx.execute(
      Sql.named(
        'insert into payout_log (period, employee_id, action, source, '
        'reference, bank_reference, amount, currency, actor) '
        "select period, employee_id, 'paid', 'saga', "
        "'PAY-' || period || '-' || employee_id, @ref, net_original, "
        "currency_original, 'saga' from payslips "
        'where run_id::text = @run and employee_id = @employee',
      ),
      parameters: params,
    );
  });

  @override
  Future<void> compensate(String runId, String reason) {
    return _db.transaction((tx) async {
      final removed = await tx.execute(
        Sql.named(
          'delete from payslips where run_id::text = @id '
          "and status = 'draft'",
        ),
        parameters: {'id': runId},
      );
      final failed = await tx.execute(
        Sql.named(
          "update payroll_runs set status = 'failed', error = @reason, "
          'updated_at = now() where id::text = @id returning period',
        ),
        parameters: {'id': runId, 'reason': reason},
      );
      await tx.execute(
        Sql.named(
          'insert into payroll_run_steps (run_id, step, status, detail) '
          "values (@id::uuid, 'compensate', 'done', @detail)",
        ),
        parameters: {
          'id': runId,
          'detail': 'Đã hủy ${removed.affectedRows} phiếu lương chưa chi',
        },
      );
      await addOutboxEvent(
        tx,
        aggregate: 'payroll_run',
        aggregateId: runId,
        eventType: 'PayrollRunFailed',
        payload: {
          'runId': runId,
          'period': failed.isEmpty ? null : failed.first[0],
          'reason': reason,
        },
      );
    });
  }

  @override
  Future<void> complete(String runId, {required String region}) {
    return _db.transaction((tx) async {
      final totals = await tx.execute(
        Sql.named(
          'select r.period, count(p.*)::int, '
          'coalesce(sum(p.net_original), 0)::text, '
          'coalesce(sum(p.amount_base), 0)::text, '
          'max(p.currency_original) from payroll_runs r '
          "left join payslips p on p.run_id = r.id and p.status = 'paid' "
          'where r.id::text = @id group by r.period',
        ),
        parameters: {'id': runId},
      );
      final row = totals.first;
      await tx.execute(
        Sql.named(
          "update payroll_runs set status = 'completed', updated_at = now() "
          'where id::text = @id',
        ),
        parameters: {'id': runId},
      );
      await tx.execute(
        Sql.named(
          'insert into payroll_run_steps (run_id, step, status) '
          "values (@id::uuid, 'complete', 'done')",
        ),
        parameters: {'id': runId},
      );
      // Sự kiện tổng hợp cho báo cáo ở Hub: không có lương từng người.
      await addOutboxEvent(
        tx,
        aggregate: 'payroll_run',
        aggregateId: runId,
        eventType: 'PayrollRunCompleted',
        payload: {
          'runId': runId,
          'region': region,
          'period': row[0],
          'employees': row[1],
          'totalNet': row[2],
          'totalNetUsd': row[3],
          'currency': row[4],
        },
      );
    });
  }

  Map<String, dynamic> _runJson(Map<String, dynamic> r) => {
    'id': r['id'],
    'period': r['period'],
    'status': r['status'],
    'startedBy': r['started_by'],
    'error': r['error'],
    'createdAt': (r['created_at'] as DateTime).toIso8601String(),
    'updatedAt': (r['updated_at'] as DateTime).toIso8601String(),
  };
}
