/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-11-01
 */

import 'package:attendance_service/src/data/work_config.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:attendance_service/src/region_time.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// PUT    /schedules  {employeeIds, from, to, weekdays, start, end, note}
/// DELETE /schedules  {employeeIds, from, to}
/// HR đặt, bỏ lịch làm việc của nhân viên từ hôm nay trở đi
Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  if (method != HttpMethod.put && method != HttpMethod.delete) {
    return apiError(405, 'method_not_allowed', 'PUT, DELETE only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(const {'hr'})) {
    return apiError(403, 'forbidden', 'HR only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_body', 'JSON object');
  }
  final ids = body['employeeIds'];
  final from = parseDate(body['from'] as String?);
  final to = parseDate(body['to'] as String?);
  if (ids is! List || from == null || to == null) {
    return apiError(400, 'invalid_body', 'employeeIds, from, to are required');
  }
  final employeeIds = {for (final id in ids) '$id'}.toList();
  final today = await regionNow(context);
  final config = context.read<WorkConfig>();
  try {
    if (method == HttpMethod.delete) {
      final removed = await config.clearSchedules(
        employeeIds: employeeIds,
        from: from,
        to: to,
        today: today,
        by: claims.username,
      );
      return Response.json(body: {'schedules': removed});
    }
    final start = body['start'];
    final end = body['end'];
    final weekdays = body['weekdays'];
    final note = (body['note'] as String?)?.trim();
    if (start is! String || end is! String || weekdays is! List) {
      return apiError(400, 'invalid_body', 'start, end, weekdays are required');
    }
    final written = await config.setSchedules(
      employeeIds: employeeIds,
      from: from,
      to: to,
      today: today,
      weekdays: [for (final d in weekdays) if (d is int) d],
      start: start,
      end: end,
      note: note == null || note.isEmpty ? null : note,
      by: claims.username,
    );
    return Response.json(body: {'schedules': written});
  } on WorkConfigViolation catch (e) {
    return apiError(400, e.code, e.message);
  } on LeaveRuleViolation catch (e) {
    return apiError(409, e.code, e.message);
  }
}
