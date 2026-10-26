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

/// GET /analytics?granularity=day|month|year&from=&to=  thu, chi vật liệu,
/// chi lương, lợi nhuận theo mốc thời gian (mặc định 12 tháng gần nhất)
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final q = context.request.uri.queryParameters;
  final granularity = q['granularity'] ?? 'month';
  if (!granularities.containsKey(granularity)) {
    return apiError(400, 'invalid_granularity', 'day, month or year');
  }
  final now = DateTime.now();
  final to = DateTime.tryParse(q['to'] ?? '') ?? now;
  final from =
      DateTime.tryParse(q['from'] ?? '') ??
      switch (granularity) {
        'day' => to.subtract(const Duration(days: 30)),
        'year' => DateTime(to.year - 5),
        _ => DateTime(to.year - 1, to.month),
      };
  if (granularity == 'day' && to.difference(from).inDays > 366) {
    return apiError(400, 'range_too_long', 'At most one year by day');
  }
  return Response.json(
    body: {
      'granularity': granularity,
      'currency': context.read<RateSource>().currency,
      'items': await context.read<AnalyticsRepository>().series(
        granularity: granularity,
        from: from,
        to: to,
      ),
    },
  );
}
