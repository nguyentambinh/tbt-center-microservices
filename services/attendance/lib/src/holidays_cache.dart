/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:tbt_common/tbt_common.dart';

/// Cache danh sách ngày lễ (1 giờ); quản trị sửa ngày lễ thì xóa
final holidaysCache = RedisCache.fromEnvironment();
