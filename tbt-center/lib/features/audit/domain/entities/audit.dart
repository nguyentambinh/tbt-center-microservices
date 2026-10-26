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
    this.anomalies = const [],
  });

  final int id;
  final String region;
  final String sourceService;
  final String eventType;
  final String aggregateId;
  final DateTime occurredAt;
  final String hash;

  /// `after_hours` (22h–6h giờ địa phương), `failure` (thất bại, từ chối, bù trừ)
  final List<String> anomalies;
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

/// Điều kiện tra cứu sổ; [from]/[to] có giờ phút thì lọc đúng thời điểm, không thì theo ngày
typedef AuditQuery = ({String? region, String? type, String? service, String? anomaly, DateTime? from, DateTime? to});

const AuditQuery emptyAuditQuery = (region: null, type: null, service: null, anomaly: null, from: null, to: null);

typedef AuditCount = ({String key, int count});

/// Số liệu cho biểu đồ kiểm toán, cùng điều kiện lọc với danh sách
class AuditStats {
  const AuditStats({
    required this.total,
    required this.afterHours,
    required this.failures,
    required this.byType,
    required this.byRegion,
    required this.byService,
    required this.byDay,
    required this.byLocalHour,
  });

  final int total;
  final int afterHours;
  final int failures;
  final List<AuditCount> byType;
  final List<AuditCount> byRegion;
  final List<AuditCount> byService;
  final List<AuditCount> byDay;

  /// 24 ô, theo giờ địa phương của khu vực phát sinh
  final List<int> byLocalHour;
}
