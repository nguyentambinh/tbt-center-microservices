/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// Đề cử thăng chức: HR khu vực gửi, Ban lãnh đạo (mọi khu vực) duyệt
Handler middleware(Handler handler) => handler.use(
  requireClaims(
    anyRole: const {'hr', 'executive'},
    region: Platform.environment['REGION'],
    anyRegionRoles: const {'executive'},
  ),
);
