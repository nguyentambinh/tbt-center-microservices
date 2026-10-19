/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:attendance_service/src/access.dart';
import 'package:attendance_service/src/data/overtime_repository.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET  /overtime-requests?employee=&status=  danh sách đơn tăng ca
/// POST /overtime-requests {"workDate":"2026-10-20","hours":2,"reason":"..."}
Future<Response> onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.get => _list(context),
    HttpMethod.post => _create(context),
    _ => Future.value(apiError(405, 'method_not_allowed', 'GET, POST only')),
  };
}

Future<Response> _list(RequestContext context) async {
  final query = context.request.uri.queryParameters;
  final isManager = context.read<Claims>().hasAnyRole(managerRoles);

  // Giống đơn nghỉ: quản lý không truyền employee thì xem tất cả để duyệt.
  String? employee;
  if (!isManager || query['employee'] != null) {
    final resolved = resolveEmployee(context, query['employee']);
    if (resolved is Response) return resolved;
    employee = resolved as String;
  }
  final items = await context.read<OvertimeRepository>().requests(
    employeeId: employee,
    status: query['status'],
  );
  return Response.json(body: {'items': items});
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
  final workDate = parseDate(body['workDate']);
  final hours = body['hours'];
  if (workDate == null) {
    return apiError(400, 'invalid_dates', 'workDate must be YYYY-MM-DD');
  }
  if (hours is! num || hours <= 0 || hours > maxOvertimeHours) {
    return apiError(
      400,
      'invalid_hours',
      'hours must be between 0 and $maxOvertimeHours',
    );
  }

  try {
    final request = await context.read<OvertimeRepository>().create(
      employeeId: employee,
      workDate: workDate,
      hours: hours.toDouble(),
      reason: (body['reason'] as String?)?.trim(),
    );
    return Response.json(statusCode: 201, body: request);
  } on LeaveRuleViolation catch (e) {
    return ruleError(e);
  }
}
