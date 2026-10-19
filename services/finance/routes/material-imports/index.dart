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

/// POST /material-imports
/// {"supplierId":"NCC01","materialName":"Thép","importedOn":"2025-04-20",
///  "amount":"5200000"}
/// Ghi chứng từ mua vật liệu của nhà cung cấp (R103).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  if (!context.read<Claims>().hasAnyRole(financeWriterRoles)) {
    return apiError(403, 'forbidden', 'Finance only');
  }

  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final supplierId = (body['supplierId'] as String?)?.trim() ?? '';
  final materialName = (body['materialName'] as String?)?.trim() ?? '';
  final amount = parseAmount(body['amount']);
  final importedOn = parseDay(body['importedOn']);
  if (supplierId.isEmpty || materialName.isEmpty) {
    return apiError(
      400,
      'missing_fields',
      'supplierId and materialName are required',
    );
  }
  if (amount == null) {
    return apiError(400, 'invalid_amount', 'amount must be positive');
  }
  if (importedOn == null) {
    return apiError(400, 'invalid_date', 'importedOn must be YYYY-MM-DD');
  }

  final rates = context.read<RateSource>();
  try {
    final purchase = await context.read<FinanceRepository>().recordPurchase(
      supplierId: supplierId,
      materialName: materialName,
      importedOn: importedOn,
      amount: amount,
      currency: rates.currency,
      rate: await rates.rateOn(importedOn),
    );
    return Response.json(statusCode: 201, body: purchase);
  } on FinanceRuleViolation catch (e) {
    return ruleError(e);
  }
}
