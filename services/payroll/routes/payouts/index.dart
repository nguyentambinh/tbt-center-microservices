/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-19
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:payroll_service/src/payout_desk.dart';
import 'package:tbt_common/tbt_common.dart';

import '../payroll-runs/index.dart' show payrollRunnerRoles;

/// GET  /payouts?period=2026-10   phiếu lương từng người, đã chuyển mấy lần
/// POST /payouts {"period", "employeeIds"?, "duplicates": "ask|skip|resend"}
///      chuyển cho cả công ty (không có employeeIds) hoặc những người đã chọn
Future<Response> onRequest(RequestContext context) async {
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(payrollRunnerRoles)) {
    return apiError(403, 'forbidden', 'Finance only');
  }
  final desk = context.read<PayoutDesk>();

  switch (context.request.method) {
    case HttpMethod.get:
      final period = context.request.uri.queryParameters['period'];
      if (!_validPeriod(period)) {
        return apiError(400, 'invalid_period', 'period must be YYYY-MM');
      }
      // Lương từng người chỉ hiện cho người cùng khu vực (R26)
      final local = claims.region == Platform.environment['REGION'];
      return Response.json(
        body: {
          'period': period,
          'runStatus': await desk.store.runStatus(period!),
          'items': [
            for (final l in await desk.store.lines(period))
              l.toJson(withAmount: local),
          ],
        },
      );
    case HttpMethod.post:
      final Map<String, dynamic> body;
      try {
        body = await context.request.json() as Map<String, dynamic>;
      } on Object {
        return apiError(400, 'invalid_json', 'Body must be a JSON object');
      }
      final period = body['period'];
      final ids = body['employeeIds'];
      final mode = DuplicateMode.values
          .asNameMap()[body['duplicates'] ?? 'ask'];
      if (!_validPeriod(period) ||
          mode == null ||
          (ids != null && (ids is! List || ids.isEmpty))) {
        return apiError(400, 'invalid_payout', 'Invalid payout request');
      }
      final outcome = await desk.transfer(
        period: period as String,
        actor: claims.username,
        employeeIds: ids == null ? null : [for (final id in ids as List) '$id'],
        mode: mode,
      );
      return switch (outcome) {
        NotCalculated() => apiError(
          409,
          'not_calculated',
          'No payslips for $period',
        ),
        RunInProgress() => apiError(409, 'run_running', 'Payroll is running'),
        PayoutBusy() => apiError(409, 'payout_busy', 'Another payout runs'),
        DuplicatesFound(:final duplicates, :final pending) => Response.json(
          statusCode: 409,
          body: {
            'code': 'already_paid',
            'message': '${duplicates.length} already paid',
            'pending': pending,
            'duplicates': [
              for (final d in duplicates)
                {
                  'employeeId': d.employeeId,
                  'transfers': d.transfers,
                  'paidOn': d.paidOn?.toIso8601String().substring(0, 10),
                },
            ],
          },
        ),
        PayoutAccepted() => Response.json(
          statusCode: 202,
          body: outcome.toJson(),
        ),
        PayoutDone(:final failure?) => Response.json(
          statusCode: 502,
          body: {
            'code': 'payout_failed',
            'message': failure,
            ...outcome.toJson(),
          },
        ),
        PayoutDone() => Response.json(body: outcome.toJson()),
      };
    case HttpMethod.put ||
        HttpMethod.patch ||
        HttpMethod.delete ||
        HttpMethod.head ||
        HttpMethod.options:
      return apiError(405, 'method_not_allowed', 'GET, POST only');
  }
}

bool _validPeriod(Object? period) =>
    period is String &&
    period.length == 7 &&
    DateTime.tryParse('$period-01') != null;
