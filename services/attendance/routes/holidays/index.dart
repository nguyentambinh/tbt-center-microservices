/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:attendance_service/src/data/attendance_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /holidays?year=2026
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final year =
      int.tryParse(context.request.uri.queryParameters['year'] ?? '') ??
      DateTime.now().year;
  final items = await context.read<AttendanceRepository>().holidays(year);
  return Response.json(body: {'year': year, 'items': items});
}
