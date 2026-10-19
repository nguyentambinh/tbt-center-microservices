/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:finance_service/src/data/finance_repository.dart';
import 'package:finance_service/src/domain/finance_rules.dart';
import 'package:finance_service/src/rate_source.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /periods/{YYYY-MM}/close  chốt sổ tháng (R62). Số liệu chốt được gửi
/// lên Hub cho báo cáo hợp nhất; tháng đã chốt không nhập thêm chứng từ.
Future<Response> onRequest(RequestContext context, String period) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(financeWriterRoles)) {
    return apiError(403, 'forbidden', 'Finance only');
  }
  if (!isPeriod(period)) {
    return apiError(400, 'invalid_period', 'period must be YYYY-MM');
  }
  if (period.compareTo(periodOf(DateTime.now())) >= 0) {
    return apiError(400, 'period_not_ended', '$period has not ended yet');
  }

  try {
    final closing = await context.read<FinanceRepository>().closePeriod(
      period,
      currency: context.read<RateSource>().currency,
      closedBy: claims.username,
    );
    return Response.json(statusCode: 201, body: closing);
  } on FinanceRuleViolation catch (e) {
    return ruleError(e);
  }
}
