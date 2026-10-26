/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:audit_service/src/audit_access.dart';
import 'package:audit_service/src/audit_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// Kiểm người gọi được đọc sổ kiểm toán không; trả [Claims] hoặc [Response]
/// lỗi. Dùng chung cho mọi route `/audit-log`.
Object auditReader(RequestContext context) {
  final claims = context.read<Claims>();
  final denied = auditorAccessDenied(claims, DateTime.now());
  return switch (denied) {
    null => claims,
    'access_expired' => apiError(
      403,
      'access_expired',
      'Auditor access has expired',
    ),
    _ => apiError(403, 'forbidden', 'Audit log is not available for you'),
  };
}

/// Đọc điều kiện tra cứu từ query; `null` nếu ngày sai dạng.
AuditFilter? filterFrom(Map<String, String> query) {
  DateTime? day(String key) =>
      query[key] == null ? null : DateTime.tryParse(query[key]!);
  final from = day('from');
  final to = day('to');
  if ((query['from'] != null && from == null) ||
      (query['to'] != null && to == null)) {
    return null;
  }
  final anomaly = query['anomaly'];
  if (anomaly != null && !{'after_hours', 'failure', 'any'}.contains(anomaly)) {
    return null;
  }
  return AuditFilter(
    region: query['region'],
    eventType: query['type'],
    service: query['service'],
    anomaly: anomaly,
    from: from,
    to: to,
    // Có giờ phút (2026-10-25T08:30) thì lọc đúng thời điểm
    exactTime: [
      query['from'],
      query['to'],
    ].any((v) => v?.contains('T') ?? false),
  );
}

AccessRecord accessOf(
  Claims claims,
  String action, {
  AuditFilter filter = const AuditFilter(),
  int? rowCount,
  String? checksum,
}) => AccessRecord(
  userSub: claims.subject,
  username: claims.username,
  roles: claims.roles,
  action: action,
  filter: filter,
  rowCount: rowCount,
  checksum: checksum,
);
