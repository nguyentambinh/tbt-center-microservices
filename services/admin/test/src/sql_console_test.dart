/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:admin_service/src/region_databases.dart';
import 'package:admin_service/src/sql_console.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

class _MockDatabase extends Mock implements Database {}

void main() {
  final console = SqlConsole(
    RegionDatabases(defaultDatabases, (_) => _MockDatabase()),
    _MockDatabase(),
  );

  Future<String?> refusal(String database, String sql) async {
    try {
      await console.run(database, sql, write: false, by: 'admin.vn');
      return null;
    } on SqlViolation catch (e) {
      return e.code;
    }
  }

  test('ô SQL không đụng tới nhật ký quản trị trong admin_db', () async {
    expect(
      await refusal('admin_db', 'delete from outbox'),
      'protected_database',
    );
  });

  test('chỉ CSDL trong danh sách, câu lệnh không được trống', () async {
    expect(await refusal('audit_db', 'select 1'), 'unknown_database');
    expect(await refusal('hr_db', '   '), 'empty_sql');
  });
}
