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

/// POST /internal/acceptances
/// {"projectId": "1XNN01", "acceptedOn": "2026-10-15", "amount": "123870000"}
/// project_contract gọi khi nghiệm thu dự án: ghi doanh thu (R100), tỷ giá
/// lấy theo ngày nghiệm thu.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final projectId = (body['projectId'] as String?)?.trim() ?? '';
  final acceptedOn = parseDay(body['acceptedOn']);
  final amount = parseAmount(body['amount']);
  if (projectId.isEmpty || acceptedOn == null || amount == null) {
    return apiError(
      400,
      'invalid_acceptance',
      'projectId, acceptedOn, amount required',
    );
  }

  final rates = context.read<RateSource>();
  try {
    final created = await context.read<FinanceRepository>().recordAcceptance(
      projectId: projectId,
      acceptedOn: acceptedOn,
      amount: amount,
      currency: rates.currency,
      rate: await rates.rateOn(acceptedOn),
    );
    return Response.json(
      statusCode: created ? 201 : 200,
      body: {'projectId': projectId, 'created': created},
    );
  } on FinanceRuleViolation catch (e) {
    return ruleError(e);
  }
}
