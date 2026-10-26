/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:attendance_service/src/holidays_cache.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// Ngày lễ ít đổi, cache 1 giờ
Handler middleware(Handler handler) => handler.use(
  cachedGet(
    holidaysCache,
    namespace: 'attendance:holidays',
    ttl: const Duration(hours: 1),
  ),
);
