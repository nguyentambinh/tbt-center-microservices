/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:attendance_service/src/access.dart';
import 'package:attendance_service/src/data/calendar_repository.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:attendance_service/src/region_time.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /calendar?employee=&from=&to=  lịch làm việc từng ngày: ca, giờ vào
/// ra, ngày lễ, đơn nghỉ. Mặc định tháng hiện tại của chính mình
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final query = context.request.uri.queryParameters;
  final employee = resolveEmployee(context, query['employee']);
  if (employee is Response) return employee;
  final now = await regionNow(context);
  final from = parseDate(query['from']) ?? DateTime(now.year, now.month);
  final to = parseDate(query['to']) ?? DateTime(now.year, now.month + 1, 0);
  if (to.isBefore(from) || to.difference(from).inDays > 92) {
    return apiError(400, 'range_too_long', 'At most 3 months per request');
  }
  final days = await context.read<CalendarRepository>().calendar(
    employee as String,
    from: from,
    to: to,
  );
  return Response.json(body: {'employeeId': employee, 'items': days});
}
