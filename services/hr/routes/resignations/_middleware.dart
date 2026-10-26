/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/resignation_repository.dart';
import 'package:hr_service/src/resignation_analyst.dart';
import 'package:tbt_common/tbt_common.dart';

final _repository = PostgresResignationRepository(Database.fromEnvironment());
final _store = ObjectStore.fromEnvironment();
// Đọc đơn viết tay, ảnh chụp cần đọc hiểu nên dùng Sonnet
final _analyst = ResignationAnalyst(
  StructuredAi.fromEnvironment(null, claudeSonnet),
);

/// Xin thôi việc: nhân viên trong khu vực gửi, HR, quản trị xử lý
Handler middleware(Handler handler) => handler
    .use(provider<ResignationRepository>((_) => _repository))
    .use(provider<ObjectStore?>((_) => _store))
    .use(provider<ResignationAnalyst>((_) => _analyst))
    .use(
      requireClaims(
        anyRole: const {'employee', 'hr', 'executive'},
        region: Platform.environment['REGION'],
      ),
    );
