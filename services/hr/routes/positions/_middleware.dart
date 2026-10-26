/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// Danh mục chức vụ: HR, văn phòng quản lý xem; quản trị thêm, sửa, xóa
Handler middleware(Handler handler) => handler.use(
  requireClaims(
    anyRole: const {'admin', 'hr', 'executive'},
    region: Platform.environment['REGION'],
  ),
);
