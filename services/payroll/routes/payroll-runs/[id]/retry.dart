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

/// POST /payroll-runs/{id}/retry  chạy lại đợt đã lỗi. Người đã nhận lương
/// ở lần trước giữ nguyên; người chưa nhận được tính và chi lại.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  if (!context.read<Claims>().hasAnyRole({'finance', 'admin', 'executive'})) {
    return apiError(403, 'forbidden', 'Finance only');
  }
  final repository = context.read<PayrollRunRepository>();
  final run = await repository.run(id);
  if (run == null) return apiError(404, 'not_found', 'Payroll run not found');
  // Đợt lỗi hoặc đang chờ xử lý tay mới chạy lại được
  if (run['status'] != 'failed' && run['status'] != 'needs_attention') {
    return apiError(409, 'not_failed', 'Only failed runs can be retried');
  }

  await repository.markRunning(id);
  await repository.logStep(id, 'retry', 'started');
  unawaited(context.read<PayrollSaga>().execute(id, run['period'] as String));
  return Response.json(statusCode: 202, body: await repository.run(id));
}
