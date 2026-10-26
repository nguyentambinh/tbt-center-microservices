/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:attendance_service/src/data/period_lock.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

abstract interface class AttendanceRepository {
  Future<List<Map<String, dynamic>>> timesheets(
    String employeeId, {
    required DateTime from,
    required DateTime to,
  });

  Future<List<Map<String, dynamic>>> holidays(int year);

  /// Tổng giờ công và tăng ca của mọi nhân viên trong khoảng ngày.
  Future<List<Map<String, dynamic>>> hoursByEmployee({
    required DateTime from,
    required DateTime to,
  });

  Future<List<LeaveRequest>> leaveRequests({
    String? employeeId,
    String? status,
  });

  /// Ném [LeaveRuleViolation] `overlap` nếu trùng ngày với đơn chưa bị từ chối.
  Future<LeaveRequest> createLeave({
    required String employeeId,
    required DateTime fromDate,
    required DateTime toDate,
    required String leaveType,
    String? reason,
  });

  /// `null` nếu không có đơn; ném `already_decided` nếu đơn không còn chờ,
  /// `self_approval` nếu người duyệt chính là người xin nghỉ.
  Future<LeaveRequest?> decide(
    String id, {
    required bool approve,
    required String decidedBy,
    String? deciderEmployeeId,
  });
}

class PostgresAttendanceRepository implements AttendanceRepository {
  PostgresAttendanceRepository(this._db);

  final Database _db;

  static const _leaveColumns =
      'id::text, employee_id, from_date, to_date, leave_type, status, reason, '
      'approved_by, created_at, ai_summary, ai_source, '
      '(select count(*)::int from leave_attachments a '
      'where a.leave_id = leave_requests.id) as file_count';

  @override
  Future<List<Map<String, dynamic>>> timesheets(
    String employeeId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _db.query(
      'select work_date, check_in::text, check_out::text, '
      'work_hours::float8, overtime_hours::float8, total_hours::float8 '
      'from timesheets where employee_id = @id '
      'and work_date between @from and @to order by work_date desc',
      params: {'id': employeeId, 'from': from, 'to': to},
    );
    return [
      for (final r in rows)
        {
          'workDate': _date(r['work_date'] as DateTime),
          'checkIn': r['check_in'],
          'checkOut': r['check_out'],
          'workHours': r['work_hours'],
          'overtimeHours': r['overtime_hours'],
          'totalHours': r['total_hours'],
        },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> hoursByEmployee({
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _db.query(
      'select employee_id, count(*)::int as days, '
      'coalesce(sum(work_hours), 0)::float8 as work_hours, '
      'coalesce(sum(overtime_hours), 0)::float8 as overtime_hours '
      'from timesheets where work_date between @from and @to '
      'group by employee_id order by employee_id',
      params: {'from': from, 'to': to},
    );
    return [
      for (final r in rows)
        {
          'employeeId': r['employee_id'],
          'days': r['days'],
          'workHours': r['work_hours'],
          'overtimeHours': r['overtime_hours'],
        },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> holidays(int year) async {
    final rows = await _db.query(
      'select holiday_date, name from holidays '
      'where extract(year from holiday_date) = @year order by holiday_date',
      params: {'year': year},
    );
    return [
      for (final r in rows)
        {'date': _date(r['holiday_date'] as DateTime), 'name': r['name']},
    ];
  }

  @override
  Future<List<LeaveRequest>> leaveRequests({
    String? employeeId,
    String? status,
  }) async {
    final where = [
      if (employeeId != null) 'employee_id = @employee',
      if (status != null) 'status = @status',
    ];
    final rows = await _db.query(
      'select $_leaveColumns from leave_requests '
      '${where.isEmpty ? '' : 'where ${where.join(' and ')}'} '
      'order by created_at desc limit 200',
      params: {'employee': ?employeeId, 'status': ?status},
      // Người dùng vừa gửi đơn thì phải thấy ngay, replica có thể chậm vài ms.
      fromPrimary: true,
    );
    return rows.map(_leave).toList();
  }

  @override
  Future<LeaveRequest> createLeave({
    required String employeeId,
    required DateTime fromDate,
    required DateTime toDate,
    required String leaveType,
    String? reason,
  }) {
    return _db.transaction((tx) async {
      // Khóa các đơn của người này để hai request song song không cùng lọt qua.
      final overlap = await tx.execute(
        Sql.named(
          'select id from leave_requests where employee_id = @employee '
          "and status <> 'rejected' and from_date <= @to and to_date >= @from "
          'for update',
        ),
        parameters: {'employee': employeeId, 'from': fromDate, 'to': toDate},
      );
      if (overlap.isNotEmpty) {
        throw const LeaveRuleViolation(
          'overlap',
          'Overlaps another leave request',
        );
      }

      final inserted = await tx.execute(
        Sql.named(
          'insert into leave_requests '
          '(employee_id, from_date, to_date, leave_type, reason) '
          'values (@employee, @from, @to, @type, @reason) '
          'returning $_leaveColumns',
        ),
        parameters: {
          'employee': employeeId,
          'from': fromDate,
          'to': toDate,
          'type': leaveType,
          'reason': reason,
        },
      );
      final leave = _leave(inserted.first.toColumnMap());
      await addOutboxEvent(
        tx,
        aggregate: 'leave_request',
        aggregateId: leave.id,
        eventType: 'LeaveRequested',
        payload: leave.toJson(),
      );
      return leave;
    });
  }

  @override
  Future<LeaveRequest?> decide(
    String id, {
    required bool approve,
    required String decidedBy,
    String? deciderEmployeeId,
  }) {
    return _db.transaction((tx) async {
      final current = await tx.execute(
        Sql.named(
          'select status, employee_id, from_date, to_date from leave_requests '
          'where id::text = @id for update',
        ),
        parameters: {'id': id},
      );
      if (current.isEmpty) return null;
      final row = current.first.toColumnMap();
      if (row['employee_id'] == deciderEmployeeId) {
        throw const LeaveRuleViolation(
          'self_approval',
          'You cannot decide your own leave request',
        );
      }
      if (row['status'] != 'pending') {
        throw const LeaveRuleViolation(
          'already_decided',
          'Leave request is no longer pending',
        );
      }
      await ensurePeriodsOpen(
        tx,
        row['from_date'] as DateTime,
        row['to_date'] as DateTime,
      );

      final updated = await tx.execute(
        Sql.named(
          'update leave_requests set status = @status, approved_by = @by '
          'where id::text = @id returning $_leaveColumns',
        ),
        parameters: {
          'status': approve ? 'approved' : 'rejected',
          'by': decidedBy,
          'id': id,
        },
      );
      final leave = _leave(updated.first.toColumnMap());
      await addOutboxEvent(
        tx,
        aggregate: 'leave_request',
        aggregateId: leave.id,
        eventType: approve ? 'LeaveApproved' : 'LeaveRejected',
        payload: leave.toJson(),
      );
      return leave;
    });
  }

  LeaveRequest _leave(Map<String, dynamic> r) => LeaveRequest(
    id: r['id'] as String,
    employeeId: r['employee_id'] as String,
    fromDate: r['from_date'] as DateTime,
    toDate: r['to_date'] as DateTime,
    leaveType: r['leave_type'] as String,
    status: r['status'] as String,
    reason: r['reason'] as String?,
    approvedBy: r['approved_by'] as String?,
    createdAt: r['created_at'] as DateTime?,
    aiSummary: switch (r['ai_summary']) {
      final Map<String, dynamic> m => m,
      final String s => jsonDecode(s) as Map<String, dynamic>,
      _ => null,
    },
    aiSource: r['ai_source'] as String?,
    fileCount: r['file_count'] as int? ?? 0,
  );

  String _date(DateTime d) => d.toIso8601String().substring(0, 10);
}
