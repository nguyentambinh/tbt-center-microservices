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
import 'package:payroll_service/src/saga/payroll_saga.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET  /bonuses-penalties?employee=  thưởng phạt của một nhân viên
/// POST /bonuses-penalties  {employeeId, kind: bonus|penalty, amount, reason}
/// Văn phòng quản lý ghi thẳng vào kỳ lương hiện tại, ghi sổ kiểm toán
Future<Response> onRequest(RequestContext context) async {
  final claims = context.read<Claims>();
  final repository = context.read<PayrollRepository>();
  if (context.request.method == HttpMethod.get) {
    final employee = context.request.uri.queryParameters['employee'];
    if (employee == null) {
      return apiError(HttpStatus.badRequest, 'invalid_query', 'employee');
    }
    if (employee != claims.employeeId &&
        !claims.hasAnyRole(payrollViewerRoles)) {
      return apiError(HttpStatus.forbidden, 'forbidden', 'Not your record');
    }
    return Response.json(
      body: {'items': await repository.bonusesPenalties(employee)},
    );
  }
  if (context.request.method != HttpMethod.post) {
    return apiError(HttpStatus.methodNotAllowed, 'method_not_allowed', 'GET');
  }
  if (!claims.hasAnyRole(const {'executive'})) {
    return apiError(HttpStatus.forbidden, 'forbidden', 'Executives only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(HttpStatus.badRequest, 'invalid_body', 'JSON object');
  }
  final employeeId = body['employeeId'];
  final kind = body['kind'];
  final amount = (body['amount'] as num?)?.toDouble();
  if (employeeId is! String || (kind != 'bonus' && kind != 'penalty')) {
    return apiError(
      HttpStatus.badRequest,
      'invalid_body',
      'employeeId and kind (bonus|penalty) are required',
    );
  }
  if (amount == null || amount <= 0) {
    return apiError(HttpStatus.badRequest, 'invalid_amount', 'amount > 0');
  }
  if (employeeId == claims.employeeId) {
    return apiError(
      HttpStatus.conflict,
      'self_approval',
      'You cannot reward or penalize yourself',
    );
  }
  final currency = await repository.currencyOf(employeeId);
  if (currency == null) {
    return apiError(HttpStatus.notFound, 'not_found', 'No salary record');
  }
  final today = DateTime.now();
  final rate = await context.read<RateSource>()(currency, today);
  final result = await repository.addBonusPenalty(
    employeeId: employeeId,
    kind: kind as String,
    amount: amount,
    currency: currency,
    occurredOn: DateTime(today.year, today.month, today.day),
    rate: rate,
    by: claims.employeeId ?? claims.username,
    reason: (body['reason'] as String?)?.trim(),
  );
  return Response.json(statusCode: HttpStatus.created, body: result);
}
