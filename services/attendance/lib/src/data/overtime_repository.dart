/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:attendance_service/src/data/period_lock.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Tăng ca một ngày tối đa 12 tiếng.
const maxOvertimeHours = 12;

abstract interface class OvertimeRepository {
  Future<List<Map<String, dynamic>>> requests({
    String? employeeId,
    String? status,
  });

  /// Ném [LeaveRuleViolation] `overlap` nếu ngày đó đã có đơn chưa bị từ chối.
  Future<Map<String, dynamic>> create({
    required String employeeId,
    required DateTime workDate,
    required double hours,
    String? reason,
  });

  /// `null` nếu không có đơn; ném `already_decided`, `self_approval` như đơn
  /// nghỉ.
  Future<Map<String, dynamic>?> decide(
    String id, {
    required bool approve,
    required String decidedBy,
    String? deciderEmployeeId,
  });
}

class PostgresOvertimeRepository implements OvertimeRepository {
  PostgresOvertimeRepository(this._db);

  final Database _db;

  static const _columns =
      'id::text, employee_id, work_date, hours::float8 as hours, reason, '
      'status, decided_by, created_at';

  @override
  Future<List<Map<String, dynamic>>> requests({
    String? employeeId,
    String? status,
  }) async {
    final rows = await _db.query(
      'select $_columns from overtime_requests '
      'where (@employee::text is null or employee_id = @employee) '
      'and (@status::text is null or status = @status) '
      'order by work_date desc, created_at desc limit 200',
      params: {'employee': employeeId, 'status': status},
    );
    return [for (final r in rows) _json(r)];
  }

  @override
  Future<Map<String, dynamic>> create({
    required String employeeId,
    required DateTime workDate,
    required double hours,
    String? reason,
  }) {
    return _db.transaction((tx) async {
      final List<Map<String, dynamic>> rows;
      try {
        rows = [
          for (final r in await tx.execute(
            Sql.named(
              'insert into overtime_requests (employee_id, work_date, hours, '
              'reason) values (@employee, @day, @hours, @reason) '
              'returning $_columns',
            ),
            parameters: {
              'employee': employeeId,
              'day': workDate,
              'hours': hours,
              'reason': reason,
            },
          ))
            r.toColumnMap(),
        ];
      } on ServerException catch (e) {
        if (e.code == '23505') {
          throw const LeaveRuleViolation(
            'overlap',
            'There is already an overtime request for this day',
          );
        }
        rethrow;
      }
      final request = _json(rows.first);
      await addOutboxEvent(
        tx,
        aggregate: 'overtime_request',
        aggregateId: request['id'] as String,
        eventType: 'OvertimeRequested',
        payload: request,
      );
      return request;
    });
  }

  @override
  Future<Map<String, dynamic>?> decide(
    String id, {
    required bool approve,
    required String decidedBy,
    String? deciderEmployeeId,
  }) {
    return _db.transaction((tx) async {
      final found = await tx.execute(
        Sql.named(
          'select employee_id, status, work_date from overtime_requests '
          'where id = @id::uuid for update',
        ),
        parameters: {'id': id},
      );
      if (found.isEmpty) return null;
      final current = found.first.toColumnMap();
      if (current['status'] != 'pending') {
        throw const LeaveRuleViolation('already_decided', 'Already decided');
      }
      if (current['employee_id'] == deciderEmployeeId) {
        throw const LeaveRuleViolation(
          'self_approval',
          'You cannot decide your own request',
        );
      }
      final day = current['work_date'] as DateTime;
      await ensurePeriodsOpen(tx, day, day);

      final rows = await tx.execute(
        Sql.named(
          'update overtime_requests set status = @status, decided_by = @by '
          'where id = @id::uuid returning $_columns',
        ),
        parameters: {
          'id': id,
          'status': approve ? 'approved' : 'rejected',
          'by': decidedBy,
        },
      );
      final request = _json(rows.first.toColumnMap());
      await addOutboxEvent(
        tx,
        aggregate: 'overtime_request',
        aggregateId: id,
        eventType: approve ? 'OvertimeApproved' : 'OvertimeRejected',
        payload: request,
      );
      return request;
    });
  }

  Map<String, dynamic> _json(Map<String, dynamic> r) => {
    'id': r['id'],
    'employeeId': r['employee_id'],
    'workDate': (r['work_date'] as DateTime).toIso8601String().substring(0, 10),
    'hours': r['hours'],
    'reason': r['reason'],
    'status': r['status'],
    'decidedBy': r['decided_by'],
    'createdAt': (r['created_at'] as DateTime?)?.toIso8601String(),
  };
}
