/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /internal/rate?quote=VND&date=2026-10-31
/// Tỷ giá 1 USD = ? quote của ngày gần nhất không sau date (R21).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final query = context.request.uri.queryParameters;
  final quote = query['quote']?.toUpperCase();
  final date = DateTime.tryParse(query['date'] ?? '') ?? DateTime.now();
  if (quote == null || quote.length != 3) {
    return apiError(400, 'invalid_quote', 'quote must be a currency code');
  }
  if (quote == 'USD') {
    return Response.json(
      body: {'quote': 'USD', 'rate': '1', 'rateDate': _day(date)},
    );
  }

  final rows = await context.read<Database>().query(
    'select rate::text, rate_date, source from exchange_rates '
    'where quote = @quote and rate_date <= @date '
    'order by rate_date desc limit 1',
    params: {'quote': quote, 'date': date},
  );
  if (rows.isEmpty) {
    return apiError(404, 'no_rate', 'No rate for $quote');
  }
  return Response.json(
    body: {
      'quote': quote,
      'rate': rows.first['rate'],
      'rateDate': _day(rows.first['rate_date'] as DateTime),
      'source': rows.first['source'],
    },
  );
}

String _day(DateTime d) => d.toIso8601String().substring(0, 10);
