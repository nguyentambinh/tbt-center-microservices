/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:tbt_common/src/storage/s3_presigner.dart';

/// Tệp người dùng tải lên kho của khu vực (Garage, chuẩn S3): app tải thẳng
/// bằng URL ký sẵn, service đọc lại qua địa chỉ nội bộ để kiểm, cho AI đọc
class ObjectStore {
  ObjectStore({
    required this.presigner,
    required this.publicEndpoint,
    required this.internalEndpoint,
  });

  /// null khi thiếu khóa S3
  static ObjectStore? fromEnvironment([Map<String, String>? environment]) {
    final env = environment ?? Platform.environment;
    final key = env['S3_ACCESS_KEY_ID'] ?? '';
    final secret = env['S3_SECRET_ACCESS_KEY'] ?? '';
    if (key.isEmpty || secret.isEmpty) return null;
    return ObjectStore(
      presigner: S3Presigner(
        accessKeyId: key,
        secretAccessKey: secret,
        bucket: env['S3_MEDIA_BUCKET'] ?? 'tbt-media',
      ),
      publicEndpoint: Uri.parse(
        env['S3_PUBLIC_ENDPOINT'] ?? 'http://localhost:3900',
      ),
      internalEndpoint: Uri.parse(
        env['S3_INTERNAL_ENDPOINT'] ?? 'http://garage:3900',
      ),
    );
  }

  final S3Presigner presigner;
  final Uri publicEndpoint;
  final Uri internalEndpoint;

  Uri uploadUrl(String key) =>
      presigner.presign('PUT', key, endpoint: publicEndpoint);

  Uri downloadUrl(String key) =>
      presigner.presign('GET', key, endpoint: publicEndpoint);

  /// Ghi object từ trong mạng nội bộ (sao lưu, tệp do service tạo)
  Future<void> write(
    String key,
    List<int> bytes, {
    String contentType = 'application/octet-stream',
  }) async {
    final client = HttpClient();
    try {
      final url = presigner.presign('PUT', key, endpoint: internalEndpoint);
      final request = await client.putUrl(url);
      request.headers
        ..contentType = ContentType.parse(contentType)
        ..contentLength = bytes.length;
      request.add(bytes);
      final response = await request.close();
      await response.drain<void>();
      if (response.statusCode >= 300) {
        throw HttpException('S3 PUT ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  /// Object có key bắt đầu bằng [prefix] (ListObjectsV2, tối đa 1000)
  Future<List<({String key, int size, DateTime modified})>> list(
    String prefix,
  ) async {
    final client = HttpClient();
    try {
      final url = presigner.presign(
        'GET',
        '',
        endpoint: internalEndpoint,
        extraQuery: {'list-type': '2', 'prefix': prefix},
      );
      final response = await (await client.getUrl(url)).close();
      final xml = await utf8.decodeStream(response);
      if (response.statusCode != 200) {
        throw HttpException('S3 LIST ${response.statusCode}');
      }
      String? tag(String block, String name) =>
          RegExp('<$name>(.*?)</$name>').firstMatch(block)?.group(1);
      return [
        for (final m in RegExp(
          '<Contents>(.*?)</Contents>',
          dotAll: true,
        ).allMatches(xml))
          (
            key: tag(m[1]!, 'Key') ?? '',
            size: int.tryParse(tag(m[1]!, 'Size') ?? '') ?? 0,
            modified:
                DateTime.tryParse(tag(m[1]!, 'LastModified') ?? '') ??
                DateTime(2000),
          ),
      ];
    } finally {
      client.close();
    }
  }

  /// `null` nếu không có object; ném [HttpException] khi quá [maxBytes]
  Future<Uint8List?> read(String key, {int maxBytes = 10 << 20}) async {
    final client = HttpClient();
    try {
      final url = presigner.presign('GET', key, endpoint: internalEndpoint);
      final response = await (await client.getUrl(url)).close();
      if (response.statusCode == 404) {
        await response.drain<void>();
        return null;
      }
      if (response.statusCode != 200) {
        throw HttpException('S3 GET ${response.statusCode}');
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in response) {
        bytes.add(chunk);
        if (bytes.length > maxBytes) throw const HttpException('too large');
      }
      return bytes.takeBytes();
    } finally {
      client.close();
    }
  }
}

/// Loại tệp theo mấy byte đầu, không tin đuôi tên tệp
String? sniffMimeType(List<int> bytes) {
  bool starts(List<int> sig) =>
      bytes.length >= sig.length &&
      [for (var i = 0; i < sig.length; i++) bytes[i] == sig[i]].every((b) => b);
  if (starts([0x25, 0x50, 0x44, 0x46])) return 'application/pdf';
  if (starts([0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (starts([0x89, 0x50, 0x4E, 0x47])) return 'image/png';
  if (starts([0x50, 0x4B, 0x03, 0x04])) {
    return 'application/vnd.openxmlformats-officedocument.'
        'wordprocessingml.document';
  }
  return null;
}
