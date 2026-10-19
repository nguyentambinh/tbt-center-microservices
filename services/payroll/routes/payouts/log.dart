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

/// GET /payouts/log?period=2026-10[&employeeId=...]  nhật ký chuyển lương, mới nhất trước
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(payrollRunnerRoles)) {
    return apiError(403, 'forbidden', 'Finance only');
  }
  final query = context.request.uri.queryParameters;
  final period = query['period'];
  if (period == null || DateTime.tryParse('$period-01') == null) {
    return apiError(400, 'invalid_period', 'period must be YYYY-MM');
  }
  final local = claims.region == Platform.environment['REGION'];
  final items = await context.read<PayoutDesk>().store.history(
    period,
    employeeId: query['employeeId'],
  );
  return Response.json(
    body: {
      'items': [
        for (final i in items)
          if (local) i else {...i, 'amount': null},
      ],
    },
  );
}
