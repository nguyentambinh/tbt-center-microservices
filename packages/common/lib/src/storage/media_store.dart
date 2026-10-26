/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:io';

import 'package:tbt_common/src/storage/s3_presigner.dart';

/// Ảnh nhân viên, dự án trong Garage của khu vực: CSDL lưu đường dẫn object
/// (`employees/<mã>.jpg`), API trả URL ký sẵn để app tải thẳng từ Garage.
class MediaStore {
  MediaStore({
    required this.presigner,
    required this.publicEndpoint,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// null khi thiếu khóa S3 hoặc địa chỉ công khai: API không trả ảnh
  static MediaStore? fromEnvironment([Map<String, String>? env]) {
    final e = env ?? Platform.environment;
    final key = e['S3_ACCESS_KEY_ID'];
    final secret = e['S3_SECRET_ACCESS_KEY'];
    final endpoint = e['S3_PUBLIC_ENDPOINT'];
    if ([key, secret, endpoint].any((v) => v == null || v.isEmpty)) return null;
    return MediaStore(
      presigner: S3Presigner(
        accessKeyId: key!,
        secretAccessKey: secret!,
        bucket: e['S3_MEDIA_BUCKET'] ?? 'tbt-media',
      ),
      publicEndpoint: Uri.parse(endpoint!),
    );
  }

  final S3Presigner presigner;
  final Uri publicEndpoint;
  final DateTime Function() _clock;

  /// Ký theo mốc đầu ngày (UTC), hạn 2 ngày: trong ngày URL không đổi, app lưu đệm được
  String? url(String? key) {
    if (key == null || key.isEmpty) return null;
    if (key.startsWith('http://') || key.startsWith('https://')) return key;
    final now = _clock().toUtc();
    final day = DateTime.utc(now.year, now.month, now.day);
    return presigner
        .presign(
          'GET',
          key,
          endpoint: publicEndpoint,
          expiresIn: const Duration(days: 2),
          now: day,
        )
        .toString();
  }
}
