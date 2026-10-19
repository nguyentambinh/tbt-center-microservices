/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:bank_mock_service/src/bank.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /transfers/{reference}  đối chiếu một giao dịch chi lương (R74).
Response onRequest(RequestContext context, String reference) {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final transfer = context.read<MockBank>().find(reference);
  if (transfer == null) {
    return apiError(404, 'not_found', 'No transfer with this reference');
  }
  return Response.json(body: transfer.toJson());
}
