/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/cache.dart';
import 'package:tbt_common/tbt_common.dart';

/// Hồ sơ nhân viên chỉ cho các vai trò quản lý xem,
/// và chỉ trong khu vực của mình.
Handler middleware(Handler handler) {
  return handler
      .use(cachedGet(cache, namespace: employeesCache))
      .use(
        requireClaims(
          anyRole: const {'executive', 'admin', 'hr', 'finance'},
          region: Platform.environment['REGION'],
        ),
      );
}
