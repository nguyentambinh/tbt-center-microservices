/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../http/metrics.dart';
import 'redis_cache.dart';

/// Cache-aside cho GET: có trong Redis thì trả luôn, không thì gọi handler rồi lưu.
/// Ghi dữ liệu thì gọi [invalidateCache] để đổi phiên bản, key cũ tự hết hạn.
Middleware cachedGet(
  CacheStore? store, {
  required String namespace,
  Duration ttl = const Duration(seconds: 60),
}) {
  return (handler) {
    return (context) async {
      final request = context.request;
      if (store == null || request.method != HttpMethod.get) {
        return handler(context);
      }

      String? key;
      try {
        final version = await store.get('tbt:$namespace:version') ?? '0';
        key =
            'tbt:$namespace:v$version:${request.uri.path}?${request.uri.query}';
        final hit = await store.get(key);
        ServiceMetrics.instance.cacheResult(namespace, hit: hit != null);
        if (hit != null) {
          final saved = jsonDecode(hit) as Map<String, dynamic>;
          return Response(
            statusCode: saved['status'] as int,
            body: saved['body'] as String,
            headers: {
              HttpHeaders.contentTypeHeader: saved['type'] as String,
              'x-cache': 'HIT',
            },
          );
        }
      } on Object catch (e) {
        // Redis lỗi thì bỏ qua cache, request vẫn chạy bình thường
        stderr.writeln('Cache $namespace bỏ qua: $e');
        key = null;
      }

      final response = await handler(context);
      if (key == null || response.statusCode != 200) return response;
      final body = await response.body();
      final type =
          response.headers[HttpHeaders.contentTypeHeader] ?? 'application/json';
      try {
        await store.set(
          key,
          jsonEncode({'status': 200, 'body': body, 'type': type}),
          ttl,
        );
      } on Object catch (e) {
        stderr.writeln('Không lưu được cache $namespace: $e');
      }
      return response.copyWith(
        body: body,
        headers: {...response.headers, 'x-cache': 'MISS'},
      );
    };
  };
}

/// Đổi phiên bản namespace: mọi key cũ không còn được đọc nữa
Future<void> invalidateCache(CacheStore? store, String namespace) async {
  if (store == null) return;
  try {
    await store.incr('tbt:$namespace:version');
  } on Object catch (e) {
    stderr.writeln('Không xóa được cache $namespace: $e');
  }
}
