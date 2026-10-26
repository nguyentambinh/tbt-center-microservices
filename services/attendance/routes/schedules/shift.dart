/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:attendance_service/src/data/work_config.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// PUT /schedules/shift  {from, to, start, end}  quản trị đổi giờ ca cho mọi
/// lịch làm việc trong khoảng ngày (chỉ từ hôm nay trở đi)
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.put) {
    return apiError(405, 'method_not_allowed', 'PUT only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(const {'admin'})) {
    return apiError(403, 'forbidden', 'Administrators only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_body', 'JSON object');
  }
  final from = parseDate(body['from'] as String?);
  final to = parseDate(body['to'] as String?);
  final start = body['start'];
  final end = body['end'];
  if (from == null || to == null || start is! String || end is! String) {
    return apiError(400, 'invalid_body', 'from, to, start, end are required');
  }
  try {
    final changed = await context.read<WorkConfig>().setShift(
      from: from,
      to: to,
      start: start,
      end: end,
      by: claims.username,
    );
    return Response.json(body: {'schedules': changed});
  } on WorkConfigViolation catch (e) {
    return apiError(400, e.code, e.message);
  }
}
