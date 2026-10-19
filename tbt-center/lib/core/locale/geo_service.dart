/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../config/env.dart';

class GeoResult {
  const GeoResult({this.ip, this.country, required this.region, required this.language});

  factory GeoResult.fromJson(Map<String, dynamic> json) => GeoResult(
        ip: json['ip'] as String?,
        country: json['country'] as String?,
        region: json['region'] as String,
        language: json['language'] as String,
      );

  final String? ip;
  final String? country;
  final String region;
  final String language;
}

/// Xác định khu vực và ngôn ngữ mặc định theo IP công khai của máy.
/// Bật VPN thì IP công khai là IP của VPN, nên đổi nước bằng VPN là test được.
class GeoService {
  GeoService(this._dio);

  final Dio _dio;

  /// [ip] hoặc [country] dùng khi giả lập; để trống thì tự lấy IP thật.
  Future<GeoResult> detect({String? ip, String? country}) async {
    var lookupIp = ip;
    if (lookupIp == null && country == null) {
      // Server ở máy tính chỉ thấy IP nội bộ, nên app tự hỏi IP công khai của mình trước.
      try {
        final response = await _dio.get<String>(Env.publicIpUrl);
        lookupIp = response.data?.trim();
      } on DioException {
        lookupIp = null;
      }
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '${Env.geoUrl}/lookup',
      queryParameters: {
        'ip': ?lookupIp,
        'country': ?country,
      },
    );
    return GeoResult.fromJson(response.data!);
  }
}
