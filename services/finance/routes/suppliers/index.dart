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

/// GET /suppliers  nhà cung cấp kèm tổng mua, đã trả, còn nợ (R103, R104).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final items = await context.read<FinanceRepository>().suppliers();
  return Response.json(body: {'items': items});
}
