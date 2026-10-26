/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:payroll_service/src/payroll_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /internal/salaries/{employeeId}/raise  {percent, reason}
/// hr gọi khi Ban lãnh đạo duyệt thăng chức; chỉ được tăng (0 < percent ≤ 100).
Future<Response> onRequest(RequestContext context, String employeeId) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final body = await context.request.json() as Map<String, dynamic>;
  final percent = (body['percent'] as num?)?.toDouble();
  if (percent == null || percent <= 0 || percent > 100) {
    return apiError(400, 'invalid_percent', 'percent must be in (0, 100]');
  }
  final raised = await context.read<PayrollRepository>().raiseSalary(
    employeeId,
    percent: percent,
    reason: body['reason'] as String? ?? 'promotion',
  );
  if (raised == null) {
    return apiError(404, 'no_salary', 'No salary for $employeeId');
  }
  return Response.json(body: raised);
}
