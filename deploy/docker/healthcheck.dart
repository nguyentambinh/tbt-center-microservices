/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

// Docker HEALTHCHECK: image scratch không có curl nên dùng chương trình này
Future<void> main() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
  try {
    final request = await client.getUrl(Uri.parse('http://127.0.0.1:8080/'));
    final response = await request.close().timeout(const Duration(seconds: 2));
    await response.drain<void>();
    exit(response.statusCode == 200 ? 0 : 1);
  } on Object {
    exit(1);
  }
}
