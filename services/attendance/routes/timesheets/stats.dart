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

/// GET /timesheets/stats?employee=&months=3  tần suất chấm công. Quản lý
/// không truyền employee thì xem cả khu vực, nhân viên xem của mình
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final query = context.request.uri.queryParameters;
  final manager = context.read<Claims>().hasAnyRole(managerRoles);
  String? employee;
  if (!manager || query['employee'] != null) {
    final resolved = resolveEmployee(context, query['employee']);
    if (resolved is Response) return resolved;
    employee = resolved as String;
  }
  final months = (int.tryParse(query['months'] ?? '') ?? 3).clamp(1, 12);
  final now = await regionNow(context);
  final stats = await context.read<CalendarRepository>().stats(
    employeeId: employee,
    from: DateTime(now.year, now.month - months + 1),
    to: now,
  );
  return Response.json(
    body: {'employeeId': employee, 'months': months, ...stats},
  );
}
