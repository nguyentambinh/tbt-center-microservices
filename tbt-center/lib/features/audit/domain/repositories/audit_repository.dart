/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/audit.dart';

/// Sổ kiểm toán ở Hub, chỉ đọc (R54, R88–R90).
abstract interface class AuditRepository {
  Future<List<AuditEvent>> events({String? region});

  Future<ChainCheck> verify();

  Future<AuditExport> export({String? region});

  Future<List<AccessEntry>> accessLog();
}
