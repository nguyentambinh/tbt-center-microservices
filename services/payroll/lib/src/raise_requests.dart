/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Chỉ Ban lãnh đạo duyệt tăng lương; HR chỉ chuyển lên
const raiseApproverRoles = {'executive'};

enum RaiseSide { employee, hr, approver }

class RaiseRuleViolation implements Exception {
  const RaiseRuleViolation(this.code, this.message);

  final String code;
  final String message;
}

/// Trạng thái kế tiếp khi [side] làm [action]:
/// nhân viên gửi → HR chuyển lên (giữ hoặc tăng mức) → bên duyệt đồng ý, từ
/// chối, hoặc trả lại HR; nhân viên rút được khi đề xuất còn mở.
/// [skipHr]: đề xuất của nhân viên HR, đi thẳng lên bên duyệt, trả lại thì về
/// người đề xuất
String nextRaiseStatus(
  String status,
  RaiseSide side,
  String action, {
  bool skipHr = false,
}) {
  final open = {'awaiting_hr', 'awaiting_approver', 'awaiting_employee'};
  final next = switch ((side, status, action)) {
    (RaiseSide.hr, _, _) when skipHr => null,
    (RaiseSide.employee, 'awaiting_hr' || 'awaiting_employee', 'edit') =>
      skipHr ? 'awaiting_approver' : 'awaiting_hr',
    (RaiseSide.employee, _, 'withdraw') when open.contains(status) =>
      'withdrawn',
    (RaiseSide.hr, 'awaiting_hr', 'forward') => 'awaiting_approver',
    (RaiseSide.hr, 'awaiting_hr', 'return') => 'awaiting_employee',
    (RaiseSide.hr, 'awaiting_hr', 'reject') => 'rejected',
    (RaiseSide.approver, 'awaiting_approver' || 'awaiting_hr', 'approve') =>
      'approved',
    (RaiseSide.approver, 'awaiting_approver', 'return') =>
      skipHr ? 'awaiting_employee' : 'awaiting_hr',
    (RaiseSide.approver, 'awaiting_approver' || 'awaiting_hr', 'reject') =>
      'rejected',
    _ => null,
  };
  if (next == null) {
    throw RaiseRuleViolation(
      'invalid_raise_action',
      'Cannot $action while request is $status',
    );
  }
  return next;
}

/// Sửa qua lại chỉ được giữ hoặc tăng mức đề xuất, không hạ
void checkAmount(double? amount, double current) {
  if (amount != null && amount < current) {
    throw const RaiseRuleViolation(
      'amount_lowered',
      'The proposed salary can only stay or go up',
    );
  }
}

abstract interface class RaiseRequestRepository {
  Future<List<Map<String, dynamic>>> list({String? employeeId, String? status});

  /// Ném `pending_exists` nếu đã có đề xuất đang mở, `no_salary`, `not_higher`.
  /// [skipHr]: người đề xuất là HR, gửi thẳng Ban lãnh đạo
  Future<Map<String, dynamic>> create(
    String employeeId, {
    required double requested,
    required String reason,
    bool skipHr = false,
  });

  /// Duyệt thì tăng lương cơ bản ngay trong cùng giao dịch
  Future<Map<String, dynamic>?> respond(
    int id, {
    required RaiseSide side,
    required String action,
    required String by,
    String? employeeId,
    double? amount,
    String? note,
  });
}

class PostgresRaiseRequestRepository implements RaiseRequestRepository {
  PostgresRaiseRequestRepository(this._db);

  final Database _db;

  static const _columns =
      'id, employee_id, current_salary::float8 as current_salary, currency, '
      'requested::float8 as requested, proposed::float8 as proposed, reason, '
      'status, decided_by, skip_hr, created_at, updated_at';

  @override
  Future<List<Map<String, dynamic>>> list({
    String? employeeId,
    String? status,
  }) async {
    final rows = await _db.query(
      'select $_columns from raise_requests '
      'where (@employee::text is null or employee_id = @employee) '
      'and (@status::text is null or status = @status) '
      'order by updated_at desc limit 200',
      params: {'employee': employeeId, 'status': status},
      fromPrimary: true,
    );
    final result = <Map<String, dynamic>>[];
    for (final r in rows) {
      final events = await _db.query(
        'select action, actor, amount::float8 as amount, note, at '
        'from raise_request_events where request_id = @id order by at, id',
        params: {'id': r['id']},
        fromPrimary: true,
      );
      result.add({
        ..._json(r),
        'events': [
          for (final e in events)
            {
              'action': e['action'],
              'actor': e['actor'],
              'amount': e['amount'],
              'note': e['note'],
              'at': (e['at'] as DateTime).toUtc().toIso8601String(),
            },
        ],
        'bonusesPenalties': await _bonuses(
          r['employee_id'] as String,
          r['created_at'] as DateTime,
        ),
      });
    }
    return result;
  }

  /// Thưởng phạt 12 tháng trước khi gửi đề xuất, kèm cho bên duyệt xem
  Future<List<Map<String, dynamic>>> _bonuses(
    String employeeId,
    DateTime until,
  ) async {
    final rows = await _db.query(
      'select occurred_on, kind, total_original::float8 as total, '
      'currency_original from bonuses_penalties where employee_id = @id '
      "and occurred_on > @until::date - interval '12 months' "
      'and occurred_on <= @until::date order by occurred_on desc limit 20',
      params: {'id': employeeId, 'until': until},
    );
    return [
      for (final r in rows)
        {
          'date': (r['occurred_on'] as DateTime).toIso8601String().substring(
            0,
            10,
          ),
          'kind': r['kind'],
          'total': r['total'],
          'currency': r['currency_original'],
        },
    ];
  }

  @override
  Future<Map<String, dynamic>> create(
    String employeeId, {
    required double requested,
    required String reason,
    bool skipHr = false,
  }) => _db.transaction((tx) async {
    final salary = await tx.execute(
      Sql.named(
        'select base_salary::float8, currency from salaries '
        'where employee_id = @id',
      ),
      parameters: {'id': employeeId},
    );
    if (salary.isEmpty) {
      throw const RaiseRuleViolation('no_salary', 'No salary on record');
    }
    final current = salary.first[0]! as double;
    if (requested <= current) {
      throw const RaiseRuleViolation(
        'not_higher',
        'Requested salary must be above the current one',
      );
    }
    final open = await tx.execute(
      Sql.named(
        'select 1 from raise_requests where employee_id = @id and status in '
        "('awaiting_hr', 'awaiting_approver', 'awaiting_employee')",
      ),
      parameters: {'id': employeeId},
    );
    if (open.isNotEmpty) {
      throw const RaiseRuleViolation(
        'pending_exists',
        'A raise request is already open',
      );
    }
    final rows = await tx.execute(
      Sql.named(
        'insert into raise_requests (employee_id, current_salary, currency, '
        'requested, proposed, reason, status, skip_hr) values (@id, '
        '@current, @currency, @requested, @requested, @reason, @status, '
        '@skip) returning $_columns',
      ),
      parameters: {
        'id': employeeId,
        'current': current,
        'currency': salary.first[1],
        'requested': requested,
        'reason': reason,
        'status': skipHr ? 'awaiting_approver' : 'awaiting_hr',
        'skip': skipHr,
      },
    );
    final request = _json(rows.first.toColumnMap());
    await _event(tx, request['id'] as int, 'submitted', employeeId, requested);
    await _outbox(tx, request, skipHr ? 'RaiseForwarded' : 'RaiseRequested');
    return request;
  });

  @override
  Future<Map<String, dynamic>?> respond(
    int id, {
    required RaiseSide side,
    required String action,
    required String by,
    String? employeeId,
    double? amount,
    String? note,
  }) async {
    final done = await _db.transaction((tx) async {
      final rows = await tx.execute(
        Sql.named(
          'select $_columns from raise_requests where id = @id for update',
        ),
        parameters: {'id': id},
      );
      if (rows.isEmpty) return false;
      final current = _json(rows.first.toColumnMap());
      if (side == RaiseSide.employee && current['employeeId'] != employeeId) {
        throw const RaiseRuleViolation('not_found', 'No such request');
      }
      if (side != RaiseSide.employee && current['employeeId'] == employeeId) {
        throw const RaiseRuleViolation(
          'self_approval',
          'Your own request goes to someone else',
        );
      }
      final next = nextRaiseStatus(
        current['status'] as String,
        side,
        action,
        skipHr: current['skipHr'] == true,
      );
      checkAmount(amount, current['proposed'] as double);
      final proposed = amount ?? current['proposed'] as double;
      await tx.execute(
        Sql.named(
          'update raise_requests set status = @status, proposed = @proposed, '
          'decided_by = case when @final then @by else decided_by end, '
          'updated_at = now() where id = @id',
        ),
        parameters: {
          'id': id,
          'status': next,
          'proposed': proposed,
          'final': next == 'approved' || next == 'rejected',
          'by': by,
        },
      );
      await _event(tx, id, '${side.name}_$action', by, amount, note: note);
      final updated = {...current, 'status': next, 'proposed': proposed};
      if (next == 'approved') {
        await tx.execute(
          Sql.named(
            'update salaries set base_salary = @amount where employee_id = @id',
          ),
          parameters: {'id': current['employeeId'], 'amount': proposed},
        );
        await addOutboxEvent(
          tx,
          aggregate: 'salary',
          aggregateId: current['employeeId'] as String,
          eventType: 'SalaryRaised',
          payload: {
            'employeeId': current['employeeId'],
            'baseSalary': proposed.toStringAsFixed(2),
            'currency': current['currency'],
            'reason': 'raise_request',
          },
        );
      }
      await _outbox(tx, updated, switch (next) {
        'approved' => 'RaiseApproved',
        'rejected' => 'RaiseRejected',
        'awaiting_approver' => 'RaiseForwarded',
        'awaiting_employee' => 'RaiseReturned',
        'awaiting_hr' => 'RaiseRequested',
        _ => 'RaiseWithdrawn',
      });
      return true;
    });
    if (!done) return null;
    final found = await list();
    return found.where((r) => r['id'] == id).firstOrNull;
  }

  Future<void> _event(
    TxSession tx,
    int id,
    String action,
    String actor,
    double? amount, {
    String? note,
  }) => tx.execute(
    Sql.named(
      'insert into raise_request_events (request_id, action, actor, amount, '
      'note) values (@id, @action, @actor, @amount, @note)',
    ),
    parameters: {
      'id': id,
      'action': action,
      'actor': actor,
      'amount': amount,
      'note': note,
    },
  );

  /// Sự kiện lên Hub mang mã nhân viên, không mang số tiền lương
  Future<void> _outbox(
    TxSession tx,
    Map<String, dynamic> r,
    String type,
  ) => addOutboxEvent(
    tx,
    aggregate: 'raise_request',
    aggregateId: '${r['id']}',
    eventType: type,
    payload: {'requestId': r['id'], 'employeeId': r['employeeId']},
  );

  Map<String, dynamic> _json(Map<String, dynamic> r) => {
    'id': r['id'],
    'employeeId': r['employee_id'],
    'currentSalary': r['current_salary'],
    'currency': r['currency'],
    'requested': r['requested'],
    'proposed': r['proposed'],
    'reason': r['reason'],
    'status': r['status'],
    'decidedBy': r['decided_by'],
    'skipHr': r['skip_hr'] == true,
    'createdAt': (r['created_at'] as DateTime).toUtc().toIso8601String(),
    'updatedAt': (r['updated_at'] as DateTime).toUtc().toIso8601String(),
  };
}
