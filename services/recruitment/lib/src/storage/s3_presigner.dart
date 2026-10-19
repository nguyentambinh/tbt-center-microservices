/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Tạo URL ký sẵn (presigned URL) theo chuẩn AWS Signature V4, kiểu đường dẫn
/// `/{bucket}/{key}`. Ai có URL thì được GET/PUT đúng một object trong thời
/// hạn ngắn, không cần biết khóa bí mật.
class S3Presigner {
  S3Presigner({
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.bucket,
    this.region = 'garage',
  });

  final String accessKeyId;
  final String secretAccessKey;
  final String bucket;
  final String region;

  /// [endpoint] là địa chỉ người dùng URL sẽ gọi tới (trong docker hay từ
  /// điện thoại khác nhau), vì header `host` nằm trong chữ ký.
  Uri presign(
    String method,
    String key, {
    required Uri endpoint,
    Duration expiresIn = const Duration(minutes: 10),
    DateTime? now,
  }) {
    final time = (now ?? DateTime.now()).toUtc();
    final date = _two(time.year, 4) + _two(time.month) + _two(time.day);
    final amzDate =
        '${date}T${_two(time.hour)}${_two(time.minute)}${_two(time.second)}Z';
    final scope = '$date/$region/s3/aws4_request';
    final host = endpoint.hasPort && !_defaultPort(endpoint)
        ? '${endpoint.host}:${endpoint.port}'
        : endpoint.host;
    final path = '/$bucket/${key.split('/').map(_encode).join('/')}';

    final query = {
      'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
      'X-Amz-Credential': '$accessKeyId/$scope',
      'X-Amz-Date': amzDate,
      'X-Amz-Expires': '${expiresIn.inSeconds}',
      'X-Amz-SignedHeaders': 'host',
    };
    final canonicalQuery = (query.keys.toList()..sort())
        .map((k) => '${_encode(k)}=${_encode(query[k]!)}')
        .join('&');

    final canonicalRequest = [
      method,
      path,
      canonicalQuery,
      'host:$host',
      '',
      'host',
      'UNSIGNED-PAYLOAD',
    ].join('\n');
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      scope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    List<int> signingKey = utf8.encode('AWS4$secretAccessKey');
    for (final part in [date, region, 's3', 'aws4_request']) {
      signingKey = Hmac(sha256, signingKey).convert(utf8.encode(part)).bytes;
    }
    final signature = Hmac(
      sha256,
      signingKey,
    ).convert(utf8.encode(stringToSign)).toString();

    return Uri.parse(
      '${endpoint.scheme}://$host$path?$canonicalQuery'
      '&X-Amz-Signature=$signature',
    );
  }

  static bool _defaultPort(Uri uri) =>
      (uri.scheme == 'http' && uri.port == 80) ||
      (uri.scheme == 'https' && uri.port == 443);

  static String _two(int value, [int width = 2]) =>
      value.toString().padLeft(width, '0');

  /// Mã hóa theo quy tắc của SigV4: chỉ giữ A-Z a-z 0-9 - _ . ~
  static String _encode(String value) {
    final out = StringBuffer();
    for (final byte in utf8.encode(value)) {
      final c = String.fromCharCode(byte);
      if (RegExp(r'[A-Za-z0-9\-_.~]').hasMatch(c)) {
        out.write(c);
      } else {
        out.write('%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}');
      }
    }
    return out.toString();
  }
}
