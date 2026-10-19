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
import 'package:payroll_service/src/saga/payroll_run_repository.dart';
import 'package:payroll_service/src/saga/payroll_saga.dart';
import 'package:tbt_common/tbt_common.dart';

/// Lương là dữ liệu nhạy cảm (R26): bắt buộc token đúng khu vực,
/// ứng viên không vào được. Lãnh đạo tập đoàn ra lệnh chốt, chuyển lương
/// được ở mọi công ty.
Handler middleware(Handler handler) {
  Handler guarded({Set<String> anyRegionRoles = const {}}) => handler
      .use(idempotency(database))
      .use(
        requireClaims(
          anyRole: const {'employee', 'hr', 'finance', 'admin', 'executive'},
          region: Platform.environment['REGION'],
          anyRegionRoles: anyRegionRoles,
        ),
      );
  final protected = guarded();
  final group = guarded(anyRegionRoles: const {'executive'});

  return ((RequestContext context) {
        final path = context.request.uri.path;
        if (path == '/') return handler(context);
        if (path.startsWith('/payroll-runs') || path.startsWith('/payouts')) {
          return group(context);
        }
        return protected(context);
      })
      .use(provider<PayrollRepository>((_) => payrollRepository))
      .use(provider<PayrollRunRepository>((_) => runRepository))
      .use(provider<PayrollSaga>((_) => payrollSaga))
      .use(provider<PayoutDesk>((_) => payoutDesk))
      .use(correlationAndErrors())
      .use(metrics('payroll'))
      .use(serviceRegistry('payroll'));
}
