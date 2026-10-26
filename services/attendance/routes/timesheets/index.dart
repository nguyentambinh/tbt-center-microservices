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
import 'package:attendance_service/src/region_time.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /timesheets?employee=&from=YYYY-MM-DD&to=YYYY-MM-DD
/// Mặc định: của chính mình, 31 ngày gần nhất.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final query = context.request.uri.queryParameters;
  final employee = resolveEmployee(context, query['employee']);
  if (employee is Response) return employee;

  final today = await regionNow(context);
  final to = parseDate(query['to']) ?? today;
  final from =
      parseDate(query['from']) ?? to.subtract(const Duration(days: 30));
  if (to.difference(from).inDays > 366) {
    return apiError(400, 'range_too_long', 'At most one year per request');
  }

  final rows = await context.read<AttendanceRepository>().timesheets(
    employee as String,
    from: from,
    to: to,
  );
  final totalHours = rows.fold<double>(
    0,
    (sum, r) => sum + ((r['totalHours'] as num?) ?? 0),
  );
  return Response.json(
    body: {'employeeId': employee, 'items': rows, 'totalHours': totalHours},
  );
}
