/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:attendance_service/src/access.dart';
import 'package:attendance_service/src/data/attendance_repository.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET  /leave-requests?employee=&status=  danh sách đơn
/// POST /leave-requests                    gửi đơn của chính mình
Future<Response> onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.get => _list(context),
    HttpMethod.post => _create(context),
    _ => Future.value(apiError(405, 'method_not_allowed', 'GET, POST only')),
  };
}

Future<Response> _list(RequestContext context) async {
  final query = context.request.uri.queryParameters;
  final claims = context.read<Claims>();
  final isManager = claims.hasAnyRole(managerRoles);

  // Quản lý không truyền employee thì xem tất cả để duyệt,
  // người khác chỉ xem đơn của mình.
  String? employee;
  if (!isManager || query['employee'] != null) {
    final resolved = resolveEmployee(context, query['employee']);
    if (resolved is Response) return resolved;
    employee = resolved as String;
  }

  final items = await context.read<AttendanceRepository>().leaveRequests(
    employeeId: employee,
    status: query['status'],
  );
  return Response.json(
    body: {
      'items': [for (final item in items) item.toJson()],
    },
  );
}

Future<Response> _create(RequestContext context) async {
  final employee = context.read<Claims>().employeeId;
  if (employee == null) {
    return apiError(403, 'no_employee', 'Account is not linked to an employee');
  }

  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }

  final fromDate = parseDate(body['fromDate']);
  final toDate = parseDate(body['toDate']);
  final leaveType = body['leaveType'] as String?;
  final violation = validateLeave(
    fromDate: fromDate,
    toDate: toDate,
    leaveType: leaveType,
  );
  if (violation != null) return ruleError(violation);

  try {
    final leave = await context.read<AttendanceRepository>().createLeave(
      employeeId: employee,
      fromDate: fromDate!,
      toDate: toDate!,
      leaveType: leaveType!.trim(),
      reason: (body['reason'] as String?)?.trim(),
    );
    return Response.json(statusCode: 201, body: leave.toJson());
  } on LeaveRuleViolation catch (e) {
    return ruleError(e);
  }
}
