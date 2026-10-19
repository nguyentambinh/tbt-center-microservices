/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

final _cache = RedisCache.fromEnvironment();

/// Ngày lễ ít đổi, cache 1 giờ
Handler middleware(Handler handler) => handler.use(
  cachedGet(
    _cache,
    namespace: 'attendance:holidays',
    ttl: const Duration(hours: 1),
  ),
);
