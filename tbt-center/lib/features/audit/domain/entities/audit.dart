/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Một dòng trong sổ kiểm toán ở Hub (chỉ ghi thêm, nối chuỗi băm).
class AuditEvent {
  const AuditEvent({
    required this.id,
    required this.region,
    required this.sourceService,
    required this.eventType,
    required this.aggregateId,
    required this.occurredAt,
    required this.hash,
  });

  final int id;
  final String region;
  final String sourceService;
  final String eventType;
  final String aggregateId;
  final DateTime occurredAt;
  final String hash;
}

class ChainCheck {
  const ChainCheck({required this.checked, this.brokenAt});

  final int checked;

  /// Dòng đầu tiên không khớp chuỗi băm; `null` là sổ còn nguyên vẹn.
  final int? brokenAt;

  bool get intact => brokenAt == null;
}

/// Kết quả xuất cho kiểm toán: số dòng và mã SHA-256 của tệp (R89).
class AuditExport {
  const AuditExport({required this.rowCount, required this.checksum, required this.csv});

  final int rowCount;
  final String checksum;
  final String csv;
}

/// Một lần ai đó đọc, kiểm, xuất sổ (R90).
class AccessEntry {
  const AccessEntry({
    required this.username,
    required this.action,
    required this.accessedAt,
    this.rowCount,
    this.checksum,
  });

  final String username;

  /// `search`, `verify` hoặc `export`.
  final String action;
  final DateTime accessedAt;
  final int? rowCount;
  final String? checksum;
}
