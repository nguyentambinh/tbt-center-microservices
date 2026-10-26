/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:payroll_service/src/saga/payroll_run_repository.dart';
import 'package:payroll_service/src/saga/payroll_saga.dart';
import 'package:tbt_common/tbt_common.dart';

/// Vai trò được chốt lương.
const payrollRunnerRoles = {'finance', 'executive'};

/// GET  /payroll-runs                     các đợt chốt lương gần đây
/// POST /payroll-runs {"period":"2026-10"}  bắt đầu Saga chốt lương kỳ đó
Future<Response> onRequest(RequestContext context) async {
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole({...payrollRunnerRoles, 'hr'})) {
    return apiError(403, 'forbidden', 'Finance only');
  }
  final repository = context.read<PayrollRunRepository>();

  switch (context.request.method) {
    case HttpMethod.get:
      return Response.json(body: {'items': await repository.runs()});
    case HttpMethod.post:
      if (!claims.hasAnyRole(payrollRunnerRoles)) {
        return apiError(403, 'forbidden', 'Finance only');
      }
      final Object? period;
      try {
        period =
            (await context.request.json() as Map<String, dynamic>)['period'];
      } on Object {
        return apiError(400, 'invalid_json', 'Body must be {"period": ...}');
      }
      if (period is! String ||
          period.length != 7 ||
          DateTime.tryParse('$period-01') == null) {
        return apiError(400, 'invalid_period', 'period must be YYYY-MM');
      }
      if (!canRunPeriod(period, DateTime.now())) {
        return apiError(
          409,
          'payroll_too_early',
          'Payroll for $period opens on ${_day(earliestRunDate(period))}',
        );
      }

      final run = await repository.createRun(period, claims.username);
      if (!run.created) {
        final code = run.status == 'failed' ? 'run_failed' : 'run_exists';
        return apiError(409, code, 'Payroll for $period is ${run.status}');
      }
      // Chạy nền: chi lương có thể lâu, app xem tiến trình qua GET.
      unawaited(context.read<PayrollSaga>().execute(run.id, period));
      return Response.json(
        statusCode: 202,
        body: await repository.run(run.id),
      );
    case HttpMethod.put ||
        HttpMethod.patch ||
        HttpMethod.delete ||
        HttpMethod.head ||
        HttpMethod.options:
      return apiError(405, 'method_not_allowed', 'GET, POST only');
  }
}

String _day(DateTime d) => d.toIso8601String().substring(0, 10);
