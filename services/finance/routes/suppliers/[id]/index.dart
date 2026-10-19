/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:finance_service/src/data/finance_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /suppliers/{id}  lịch sử mua và trả để đối chiếu công nợ (R104).
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final supplier = await context.read<FinanceRepository>().supplier(id);
  if (supplier == null) return apiError(404, 'not_found', 'No supplier $id');
  return Response.json(body: supplier);
}
