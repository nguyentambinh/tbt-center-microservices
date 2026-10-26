/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:tbt_common/tbt_common.dart';

/// CSDL của các service trong khu vực mà quản trị được xem, sao lưu
const defaultDatabases = [
  'hr_db',
  'attendance_db',
  'payroll_db',
  'finance_db',
  'project_contract_db',
  'recruitment_db',
  'notification_db',
  'currency_db',
  'admin_db',
];

/// Mở kết nối tới từng CSDL theo tên, giữ lại để dùng tiếp
class RegionDatabases {
  RegionDatabases(this.names, this._open);

  factory RegionDatabases.fromEnvironment() {
    final env = Platform.environment;
    final names = (env['REGION_DATABASES'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return RegionDatabases(
      names.isEmpty ? defaultDatabases : names,
      (name) => Database.fromEnvironment({...env, 'DB_NAME': name}),
    );
  }

  final List<String> names;
  final Database Function(String name) _open;
  final _opened = <String, Database>{};

  bool allowed(String name) => names.contains(name);

  Database operator [](String name) {
    if (!allowed(name)) throw ArgumentError.value(name, 'database');
    return _opened.putIfAbsent(name, () => _open(name));
  }
}
