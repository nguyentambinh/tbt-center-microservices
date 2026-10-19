/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:geo_service/src/data/ip_country_table.dart';
import 'package:geo_service/src/domain/region_policy.dart';

/// GET /lookup?ip=...  hoặc  /lookup?country=DE (giả lập khi test).
/// Không truyền gì thì lấy IP của người gọi.
Response onRequest(RequestContext context) {
  final query = context.request.uri.queryParameters;
  final forcedCountry = query['country']?.toUpperCase();
  final ip = query['ip'] ?? _callerIp(context);

  final country = forcedCountry ??
      (ip == null ? null : context.read<IpCountryTable>().countryOf(ip));

  return Response.json(
    body: {
      'ip': ip,
      'country': country,
      'region': regionForCountry(country),
      'language': languageForCountry(country),
    },
  );
}

String? _callerIp(RequestContext context) {
  final forwarded = context.request.headers['x-forwarded-for'];
  if (forwarded != null && forwarded.isNotEmpty) {
    return forwarded.split(',').first.trim();
  }
  return context.request.connectionInfo.remoteAddress.address;
}
