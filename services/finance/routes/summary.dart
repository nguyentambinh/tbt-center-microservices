/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:finance_service/src/data/finance_repository.dart';
import 'package:finance_service/src/rate_source.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /summary?year=2025  doanh thu, chi phí, lợi nhuận theo tháng
/// bằng tiền khu vực và quy USD (R19, R20, R21).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final yearText = context.request.uri.queryParameters['year'];
  final year = int.tryParse(yearText ?? '') ?? DateTime.now().year;
  if (year < 2000 || year > 2100) {
    return apiError(400, 'invalid_year', 'year must be between 2000 and 2100');
  }
  return Response.json(
    body: {
      'year': year,
      'currency': context.read<RateSource>().currency,
      'months': await context.read<FinanceRepository>().monthly(year),
    },
  );
}
