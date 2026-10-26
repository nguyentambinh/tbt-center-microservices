/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:payroll_service/src/payroll_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// PUT /salaries/{employeeId}  {baseSalary, reason}
/// Văn phòng quản lý đổi lương cơ bản có hiệu lực ngay, ghi sổ kiểm toán
Future<Response> onRequest(RequestContext context, String employeeId) async {
  if (context.request.method != HttpMethod.put) {
    return apiError(HttpStatus.methodNotAllowed, 'method_not_allowed', 'PUT');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(const {'executive'})) {
    return apiError(HttpStatus.forbidden, 'forbidden', 'Executives only');
  }
  if (claims.employeeId == employeeId) {
    return apiError(
      HttpStatus.conflict,
      'self_approval',
      'You cannot change your own salary',
    );
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(HttpStatus.badRequest, 'invalid_body', 'JSON object');
  }
  final amount = (body['baseSalary'] as num?)?.toDouble();
  if (amount == null || amount <= 0) {
    return apiError(
      HttpStatus.badRequest,
      'invalid_amount',
      'baseSalary must be > 0',
    );
  }
  final result = await context.read<PayrollRepository>().setBaseSalary(
    employeeId,
    amount: amount,
    by: claims.employeeId ?? claims.username,
    reason: (body['reason'] as String?)?.trim(),
  );
  if (result == null) {
    return apiError(HttpStatus.notFound, 'not_found', 'No salary record');
  }
  return Response.json(body: result);
}
