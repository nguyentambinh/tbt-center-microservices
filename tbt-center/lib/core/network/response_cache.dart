/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CachedResponse {
  const CachedResponse(this.data, this.savedAt);

  final Object? data;
  final DateTime savedAt;
}

/// Lưu kết quả GET gần nhất ra file để xem lại khi mất mạng.
/// Trên Android, `Directory.systemTemp` là thư mục cache của app: hệ điều hành có thể dọn khi thiếu bộ nhớ,
/// nên chỉ dùng cho dữ liệu đọc lại được, không lưu gì quan trọng ở đây.
class ResponseCache {
  ResponseCache([Directory? root]) : _root = root ?? Directory('${Directory.systemTemp.path}/tbt_http_cache');

  final Directory _root;

  File _fileFor(String key) => File('${_root.path}/${key.hashCode.toUnsigned(32)}.json');

  void write(String key, Object? data) {
    try {
      _root.createSync(recursive: true);
      _fileFor(key).writeAsStringSync(jsonEncode({
        'key': key,
        'savedAt': DateTime.now().toIso8601String(),
        'data': data,
      }));
    } on Object {
      // Dữ liệu không đổi sang JSON được hoặc hết chỗ: bỏ qua, cache chỉ là phụ.
    }
  }

  CachedResponse? read(String key) {
    try {
      final file = _fileFor(key);
      if (!file.existsSync()) return null;
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      // Hai key khác nhau có thể trùng hashCode, nên so lại key gốc.
      if (json['key'] != key) return null;
      return CachedResponse(json['data'], DateTime.parse(json['savedAt'] as String));
    } on Object {
      return null;
    }
  }

  void clear() {
    if (_root.existsSync()) _root.deleteSync(recursive: true);
  }
}

final responseCacheProvider = Provider<ResponseCache>((ref) => ResponseCache());
