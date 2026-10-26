/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:attendance_service/src/data/work_config.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:attendance_service/src/holidays_cache.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// DELETE /holidays/{YYYY-MM-DD}  quản trị bỏ một ngày lễ
Future<Response> onRequest(RequestContext context, String date) async {
  if (context.request.method != HttpMethod.delete) {
    return apiError(405, 'method_not_allowed', 'DELETE only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(const {'admin'})) {
    return apiError(403, 'forbidden', 'Administrators only');
  }
  final day = parseDate(date);
  if (day == null) return apiError(400, 'invalid_date', 'Use YYYY-MM-DD');
  final removed = await context.read<WorkConfig>().removeHoliday(
    day,
    by: claims.username,
  );
  if (!removed) return apiError(404, 'not_found', 'No holiday on $date');
  await invalidateCache(holidaysCache, 'attendance:holidays');
  return Response(statusCode: 204);
}
