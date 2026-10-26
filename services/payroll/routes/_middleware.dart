/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:payroll_service/src/dependencies.dart';
import 'package:payroll_service/src/payout_desk.dart';
import 'package:payroll_service/src/payroll_repository.dart';
import 'package:payroll_service/src/raise_requests.dart';
import 'package:payroll_service/src/saga/payroll_run_repository.dart';
import 'package:payroll_service/src/saga/payroll_saga.dart';
import 'package:tbt_common/tbt_common.dart';

/// Lương là dữ liệu nhạy cảm (R26): bắt buộc token đúng khu vực,
/// ứng viên không vào được. Tài khoản cấp tập đoàn làm việc được ở mọi
/// khu vực (requireClaims tự cho qua vai trò group).
Handler middleware(Handler handler) {
  final protected = handler
      .use(idempotency(database))
      .use(
        requireClaims(
          anyRole: const {'employee', 'hr', 'finance', 'admin', 'executive'},
          region: Platform.environment['REGION'],
        ),
      );
  final internal = handler.use(requireInternalToken());

  return ((RequestContext context) {
        final path = context.request.uri.path;
        if (path == '/') return handler(context);
        if (isInternalPath(context.request.uri)) return internal(context);
        return protected(context);
      })
      .use(provider<PayrollRepository>((_) => payrollRepository))
      .use(provider<PayrollRunRepository>((_) => runRepository))
      .use(provider<PayrollSaga>((_) => payrollSaga))
      .use(provider<PayoutDesk>((_) => payoutDesk))
      .use(provider<RaiseRequestRepository>((_) => raiseRequests))
      .use(provider<RateSource>((_) => currencyRate))
      .use(correlationAndErrors())
      .use(metrics('payroll'))
      .use(serviceRegistry('payroll'));
}
