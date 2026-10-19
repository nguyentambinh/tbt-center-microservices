/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:tbt_common/tbt_common.dart';

/// Được đọc sổ kiểm toán: lãnh đạo, quản trị, kiểm toán (nội bộ và độc lập).
const auditReaderRoles = {'executive', 'admin', 'auditor'};

/// Xem ai đã truy cập sổ (R90): chỉ lãnh đạo và quản trị.
const accessLogRoles = {'executive', 'admin'};

/// Kiểm toán độc lập chỉ được cấp quyền có thời hạn (R88): tài khoản chỉ có
/// vai trò `auditor` phải mang claim `access_until` (YYYY-MM-DD, tính hết
/// ngày đó). Trả lý do từ chối, `null` nếu còn được truy cập.
String? auditorAccessDenied(Claims claims, DateTime now) {
  if (claims.hasAnyRole(const {'executive', 'admin'})) return null;
  if (!claims.hasAnyRole(const {'auditor'})) return 'forbidden';
  final until = DateTime.tryParse(claims.accessUntil ?? '');
  if (until == null) return 'access_expired';
  final endOfDay = DateTime.utc(until.year, until.month, until.day + 1);
  return now.toUtc().isBefore(endOfDay) ? null : 'access_expired';
}

/// Cột của tệp xuất cho kiểm toán. Có cả `hash`, `prev_hash` để bên nhận tự
/// kiểm lại chuỗi băm.
const exportColumns = [
  'id',
  'region',
  'source_service',
  'event_type',
  'aggregate_id',
  'occurred_at',
  'received_at',
  'payload',
  'prev_hash',
  'hash',
];

/// Xuất CSV (UTF-8, dòng đầu là tên cột) và mã SHA-256 của đúng nội dung đó
/// (R89). Bên nhận tính lại SHA-256 của tệp, khác mã là tệp đã bị sửa.
({String csv, String checksum}) exportCsv(List<Map<String, dynamic>> rows) {
  String cell(Object? value) {
    final text = switch (value) {
      null => '',
      DateTime() => value.toUtc().toIso8601String(),
      Map() || List() => jsonEncode(value),
      _ => '$value',
    };
    final needsQuotes = text.contains(RegExp('[",\n\r]'));
    return needsQuotes ? '"${text.replaceAll('"', '""')}"' : text;
  }

  final buffer = StringBuffer()..write('${exportColumns.join(',')}\r\n');
  for (final row in rows) {
    buffer.write('${exportColumns.map((c) => cell(row[c])).join(',')}\r\n');
  }
  final csv = buffer.toString();
  return (csv: csv, checksum: sha256.convert(utf8.encode(csv)).toString());
}
