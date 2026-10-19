/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:finance_service/src/data/finance_repository.dart';
import 'package:finance_service/src/data/payroll_budget.dart';
import 'package:finance_service/src/domain/finance_rules.dart';
import 'package:finance_service/src/rate_source.dart';
import 'package:tbt_common/tbt_common.dart';

final _env = Platform.environment;
final _database = Database.fromEnvironment();
final _repository = PostgresFinanceRepository(_database);
final _budgets = PostgresPayrollBudgets(_database);
final _rates = RateSource(
  _env['CURRENCY'] ?? 'VND',
  InternalClient(
    'currency',
    Uri.parse(_env['CURRENCY_URL'] ?? 'http://currency:8080'),
  ),
);

/// `/internal/...` chỉ cho service khác trong khu vực (cần `X-Internal-Token`),
/// còn lại cần token của bộ phận tài chính.
Handler middleware(Handler handler) {
  final internal = handler.use(requireInternalToken());
  final protected = handler
      .use(idempotency(_database))
      .use(
        requireClaims(
          anyRole: financeViewerRoles,
          region: _env['REGION'],
        ),
      );

  return ((RequestContext context) {
        final uri = context.request.uri;
        if (uri.path == '/') return handler(context);
        if (isInternalPath(uri)) return internal(context);
        return protected(context);
      })
      .use(provider<FinanceRepository>((_) => _repository))
      .use(provider<PayrollBudgets>((_) => _budgets))
      .use(provider<RateSource>((_) => _rates))
      .use(correlationAndErrors())
      .use(metrics('finance'))
      .use(serviceRegistry('finance'));
}
