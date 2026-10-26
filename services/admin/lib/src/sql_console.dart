/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:admin_service/src/region_databases.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// CSDL giữ nhật ký thao tác quản trị, ô SQL không được đụng tới
const protectedDatabase = 'admin_db';

/// Số dòng tối đa trả về một lần
const maxSqlRows = 500;

class SqlViolation implements Exception {
  const SqlViolation(this.code, this.message);

  final String code;
  final String message;
}

typedef SqlResult = ({
  List<String> columns,
  List<List<Object?>> rows,
  int affected,
  bool truncated,
});

/// Chạy một câu SQL trên CSDL của khu vực: mặc định trong giao dịch chỉ đọc,
/// tối đa 10 giây; ghi phải bật `write`. Mỗi lần chạy ghi một sự kiện để lên
/// sổ kiểm toán (ai chạy, câu gì, ghi hay đọc)
class SqlConsole {
  SqlConsole(this._databases, this._log);

  final RegionDatabases _databases;
  final Database _log;

  Future<SqlResult> run(
    String database,
    String sql, {
    required bool write,
    required String by,
  }) async {
    final text = sql.trim();
    if (!_databases.allowed(database)) {
      throw const SqlViolation('unknown_database', 'Pick a listed database');
    }
    // Nhật ký thao tác quản trị nằm ở admin_db chờ đẩy lên Hub: không cho
    // chính quản trị sửa, xóa qua ô SQL
    if (database == protectedDatabase) {
      throw const SqlViolation(
        'protected_database',
        'The admin log database cannot be queried here',
      );
    }
    if (text.isEmpty) throw const SqlViolation('empty_sql', 'SQL is empty');
    final SqlResult result;
    try {
      result = await _databases[database].transaction((tx) async {
        // Phải đặt chế độ giao dịch trước mọi câu khác
        if (!write) await tx.execute('set transaction read only');
        await tx.execute("set local statement_timeout = '10s'");
        final rows = await tx.execute(text);
        return (
          columns: [
            for (final c in rows.schema.columns) c.columnName ?? '?',
          ],
          rows: [
            for (final row in rows.take(maxSqlRows))
              [for (final v in row) _plain(v)],
          ],
          affected: rows.affectedRows,
          truncated: rows.length > maxSqlRows,
        );
      });
    } on ServerException catch (e) {
      await _record(database, text, write: write, by: by, error: e.message);
      throw SqlViolation(
        e.code == '25006' ? 'read_only' : 'sql_error',
        e.message,
      );
    }
    await _record(
      database,
      text,
      write: write,
      by: by,
      affected: result.affected,
    );
    return result;
  }

  Future<void> _record(
    String database,
    String sql, {
    required bool write,
    required String by,
    int? affected,
    String? error,
  }) => _log.transaction(
    (tx) => addOutboxEvent(
      tx,
      aggregate: 'admin',
      aggregateId: database,
      eventType: write ? 'AdminSqlWrite' : 'AdminSqlRead',
      payload: {
        'database': database,
        'sql': sql.length > 2000 ? sql.substring(0, 2000) : sql,
        'by': by,
        'affected': affected,
        'error': error,
      },
    ),
  );

  static Object? _plain(Object? v) => switch (v) {
    null || bool() || int() || double() || String() => v,
    DateTime() => v.toIso8601String(),
    _ => v.toString(),
  };
}
