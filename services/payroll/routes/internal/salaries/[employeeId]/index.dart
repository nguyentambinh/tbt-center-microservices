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

/// PUT /internal/salaries/{employeeId}  {baseSalary, currency, employmentType}
/// recruitment gọi khi nhận việc; gọi lại không đổi lương đã có
Future<Response> onRequest(RequestContext context, String employeeId) async {
  if (context.request.method != HttpMethod.put) {
    return apiError(405, 'method_not_allowed', 'PUT only');
  }
  final body = await context.request.json() as Map<String, dynamic>;
  final salary = (body['baseSalary'] as num?)?.toDouble();
  final currency = body['currency'];
  if (salary == null || salary <= 0) {
    return apiError(400, 'invalid_salary', 'baseSalary must be positive');
  }
  if (currency is! String || currency.length != 3) {
    return apiError(400, 'invalid_currency', 'currency must be ISO 4217');
  }
  final saved = await context.read<PayrollRepository>().setInitialSalary(
    employeeId,
    baseSalary: salary,
    currency: currency.toUpperCase(),
    employmentType: body['employmentType'] as String? ?? 'FT',
  );
  return Response.json(body: saved);
}
