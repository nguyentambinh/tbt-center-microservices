/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:recruitment_service/src/storage/s3_presigner.dart';

/// CV lớn nhất nhận vào: 10 MB.
const maxCvBytes = 10 * 1024 * 1024;

/// Kho CV của khu vực (Garage, chuẩn S3).
class CvStorage {
  CvStorage({
    required this.presigner,
    required this.internalEndpoint,
    required this.publicEndpoint,
  });

  factory CvStorage.fromEnvironment([Map<String, String>? environment]) {
    final env = environment ?? Platform.environment;
    return CvStorage(
      presigner: S3Presigner(
        accessKeyId: env['S3_ACCESS_KEY_ID'] ?? '',
        secretAccessKey: env['S3_SECRET_ACCESS_KEY'] ?? '',
        bucket: env['S3_BUCKET'] ?? 'tbt-cv',
      ),
      internalEndpoint: Uri.parse(
        env['S3_INTERNAL_ENDPOINT'] ?? 'http://localhost:3900',
      ),
      publicEndpoint: Uri.parse(
        env['S3_PUBLIC_ENDPOINT'] ?? 'http://localhost:3900',
      ),
    );
  }

  final S3Presigner presigner;

  /// Địa chỉ service gọi tới trong mạng docker.
  final Uri internalEndpoint;

  /// Địa chỉ app trên điện thoại gọi tới (qua adb reverse khi dev).
  final Uri publicEndpoint;

  Uri uploadUrl(String key) =>
      presigner.presign('PUT', key, endpoint: publicEndpoint);

  Uri downloadUrl(String key) => presigner.presign(
    'GET',
    key,
    endpoint: publicEndpoint,
    expiresIn: const Duration(minutes: 5),
  );

  /// Tải object về service; `null` nếu không có. Ném lỗi nếu quá [maxCvBytes].
  Future<Uint8List?> read(String key) async {
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
        if (bytes.length > maxCvBytes) {
          throw const HttpException('CV quá lớn');
        }
      }
      return bytes.takeBytes();
    } finally {
      client.close();
    }
  }
}
