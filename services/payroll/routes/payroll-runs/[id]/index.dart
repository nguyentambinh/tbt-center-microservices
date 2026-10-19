/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:payroll_service/src/saga/payroll_run_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /payroll-runs/{id}  trạng thái đợt chốt, nhật ký từng bước Saga,
/// tổng số phiếu nháp/đã chi.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  if (!context.read<Claims>().hasAnyRole(
    {'finance', 'hr', 'admin', 'executive'},
  )) {
    return apiError(403, 'forbidden', 'Finance only');
  }
  final run = await context.read<PayrollRunRepository>().run(id);
  if (run == null) return apiError(404, 'not_found', 'Payroll run not found');
  return Response.json(body: run);
}
