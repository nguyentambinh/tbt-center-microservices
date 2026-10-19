/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:finance_service/src/data/payroll_budget.dart';
import 'package:finance_service/src/domain/finance_rules.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /internal/payroll-budgets/{period}/expense: ghi chi phí lương sau khi đã chi
/// {"runId": "...", "amount": "123.45", "paidCount": 10}
Future<Response> onRequest(RequestContext context, String period) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final runId = body['runId'];
  final amount = parseAmount(body['amount']);
  final count = body['paidCount'];
  if (runId is! String || amount == null || count is! int) {
    return apiError(400, 'invalid_budget', 'runId, amount, paidCount required');
  }
  final status = await context.read<PayrollBudgets>().spend(
    period: period,
    runId: runId,
    amount: amount,
    paidCount: count,
  );
  return Response.json(body: {'period': period, 'status': status});
}
