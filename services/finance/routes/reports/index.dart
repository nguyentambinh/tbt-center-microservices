/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:finance_service/src/data/analytics_repository.dart';
import 'package:finance_service/src/rate_source.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /reports: báo cáo tài chính đã gửi. POST {period: YYYY-MM, note}: chụp
/// thu chi, lợi nhuận của tháng và 5 dự án lãi nhất gửi Ban lãnh đạo
Future<Response> onRequest(RequestContext context) async {
  final reports = context.read<ReportSubmissions>();
  final claims = context.read<Claims>();
  if (context.request.method == HttpMethod.get) {
    return Response.json(body: {'items': await reports.list()});
  }
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'GET or POST');
  }
  if (!claims.hasAnyRole(const {'finance', 'admin'})) {
    return apiError(403, 'forbidden', 'Finance or admin only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final period = (body['period'] as String?)?.trim() ?? '';
  final month = DateTime.tryParse('$period-01');
  if (month == null) {
    return apiError(400, 'invalid_period', 'period must be YYYY-MM');
  }
  final analytics = context.read<AnalyticsRepository>();
  final series = await analytics.series(
    granularity: 'month',
    from: month,
    to: DateTime(month.year, month.month + 1, 0),
  );
  final ranking = await analytics.projectRanking();
  final totals = series.isEmpty
      ? {'revenue': 0.0, 'material': 0.0, 'payroll': 0.0, 'profit': 0.0}
      : series.first;
  try {
    return Response.json(
      statusCode: 201,
      body: await reports.submit(
        period: period,
        data: {
          'currency': context.read<RateSource>().currency,
          'revenue': totals['revenue'],
          'material': totals['material'],
          'payroll': totals['payroll'],
          'profit': totals['profit'],
          'topProjects': ranking.take(5).toList(),
        },
        by: claims.username,
        note: (body['note'] as String?)?.trim(),
      ),
    );
  } on ReportRuleViolation catch (e) {
    return apiError(409, e.code, e.message);
  }
}
