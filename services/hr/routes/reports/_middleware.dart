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

final _reports = ReportSubmissions(Database.fromEnvironment(), kind: 'hr');

/// Báo cáo nhân sự gửi Ban lãnh đạo: HR, quản trị lập, Ban lãnh đạo ở mọi
/// khu vực xác nhận
Handler middleware(Handler handler) => handler
    .use(provider<ReportSubmissions>((_) => _reports))
    .use(
      requireClaims(
        anyRole: const {'hr', 'executive'},
        region: Platform.environment['REGION'],
        anyRegionRoles: const {'executive'},
      ),
    );
