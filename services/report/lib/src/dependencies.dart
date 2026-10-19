/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:report_service/src/doris_client.dart';
import 'package:report_service/src/projector.dart';
import 'package:report_service/src/schema.dart';
import 'package:tbt_common/tbt_common.dart';

final _env = Platform.environment;

/// Sổ sự kiện audit ở Hub: report chỉ đọc.
final auditDb = Database.fromEnvironment();

final doris = DorisClient(
  feUrl: Uri.parse(_env['DORIS_FE_URL'] ?? 'http://localhost:8030'),
  beUrl: Uri.parse(_env['DORIS_BE_URL'] ?? 'http://localhost:8040'),
);

final cache = RedisCache.fromEnvironment();

final projector = Projector(
  audit: auditDb,
  doris: doris,
  onChanged: () => invalidateCache(cache, 'report'),
);

/// Tạo database và các bảng đọc nếu chưa có.
Future<void> ensureReportSchema() async {
  await doris.query(reportSchema.first, database: 'information_schema');
  for (final statement in reportSchema.skip(1)) {
    await doris.query(statement);
  }
}
