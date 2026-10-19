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

/// POST /internal/payroll-budgets/{period}/release {"runId": "..."}: bù trừ
Future<Response> onRequest(RequestContext context, String period) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final Object? runId;
  try {
    runId = (await context.request.json() as Map<String, dynamic>)['runId'];
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be {"runId": "..."}');
  }
  if (runId is! String) {
    return apiError(400, 'invalid_budget', 'runId required');
  }
  try {
    final status = await context.read<PayrollBudgets>().release(period, runId);
    return Response.json(body: {'period': period, 'status': status});
  } on FinanceRuleViolation catch (e) {
    return ruleError(e);
  }
}
