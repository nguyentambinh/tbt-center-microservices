/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:finance_service/src/data/finance_repository.dart';
import 'package:finance_service/src/domain/finance_rules.dart';
import 'package:finance_service/src/rate_source.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /suppliers/{id}/payments {"amount":"1500000","paidOn":"2025-04-20"}
/// Ghi một lần trả tiền nhà cung cấp, không được trả quá số nợ (R104).
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(financeWriterRoles)) {
    return apiError(403, 'forbidden', 'Finance only');
  }

  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final amount = parseAmount(body['amount']);
  final paidOn = parseDay(body['paidOn']);
  if (amount == null) {
    return apiError(400, 'invalid_amount', 'amount must be positive');
  }
  if (paidOn == null) {
    return apiError(400, 'invalid_date', 'paidOn must be YYYY-MM-DD');
  }

  final rates = context.read<RateSource>();
  try {
    final payment = await context.read<FinanceRepository>().recordPayment(
      supplierId: id,
      paidOn: paidOn,
      amount: amount,
      currency: rates.currency,
      rate: await rates.rateOn(paidOn),
      recordedBy: claims.username,
      note: (body['note'] as String?)?.trim(),
    );
    return Response.json(statusCode: 201, body: payment);
  } on FinanceRuleViolation catch (e) {
    return ruleError(e);
  }
}
