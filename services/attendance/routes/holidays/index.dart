/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:attendance_service/src/data/attendance_repository.dart';
import 'package:attendance_service/src/data/work_config.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:attendance_service/src/holidays_cache.dart';
import 'package:attendance_service/src/region_time.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /holidays?year=2026
/// POST /holidays  {date, name}  quản trị thêm ngày lễ của nước mình
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) return _add(context);
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET, POST only');
  }
  final year =
      int.tryParse(context.request.uri.queryParameters['year'] ?? '') ??
      (await regionNow(context)).year;
  final items = await context.read<AttendanceRepository>().holidays(year);
  return Response.json(body: {'year': year, 'items': items});
}

Future<Response> _add(RequestContext context) async {
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
  final date = parseDate(body['date'] as String?);
  final name = (body['name'] as String? ?? '').trim();
  if (date == null || name.isEmpty) {
    return apiError(400, 'invalid_body', 'date (YYYY-MM-DD) and name');
  }
  await context.read<WorkConfig>().addHoliday(
    date,
    name,
    by: claims.username,
  );
  await invalidateCache(holidaysCache, 'attendance:holidays');
  return Response.json(
    statusCode: 201,
    body: {'date': body['date'], 'name': name},
  );
}
