/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:tbt_common/tbt_common.dart';

/// Redis của khu vực, null nếu không cấu hình
final cache = RedisCache.fromEnvironment();

const employeesCache = 'hr:employees';
