/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:finance_service/src/data/payroll_budget.dart';
import 'package:finance_service/src/domain/finance_rules.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /internal/payroll-budgets: Saga giữ ngân sách lương của kỳ
/// {"period": "2026-10", "runId": "...", "amount": "123.45"}
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final body = await _body(context);
  final period = body?['period'];
  final runId = body?['runId'];
  final amount = parseAmount(body?['amount']);
  if (period is! String || runId is! String || amount == null) {
    return apiError(400, 'invalid_budget', 'period, runId, amount required');
  }
  try {
    final status = await context.read<PayrollBudgets>().reserve(
      period: period,
      runId: runId,
      amount: amount,
      currency: Platform.environment['CURRENCY'] ?? 'VND',
      limit: Platform.environment['PAYROLL_BUDGET_LIMIT'],
    );
    return Response.json(body: {'period': period, 'status': status});
  } on FinanceRuleViolation catch (e) {
    return ruleError(e);
  }
}

Future<Map<String, dynamic>?> _body(RequestContext context) async {
  try {
    return await context.request.json() as Map<String, dynamic>;
  } on Object {
    return null;
  }
}
