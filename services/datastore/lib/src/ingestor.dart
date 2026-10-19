/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:tbt_common/tbt_common.dart';

typedef BucketWrite = ({
  String path,
  Map<String, Map<String, Object?>> rows,
  Map<String, Object?> top,
});

/// Ghi các ngăn lên Firestore (tách ra để test không cần mạng)
typedef BucketWriter = Future<void> Function(List<BucketWrite> buckets);

/// Một dòng khu vực gửi lên: khóa chính và dữ liệu (null là đã xóa)
typedef IncomingRow = ({Map<String, Object?> key, Map<String, Object?>? data});

class IngestRejected implements Exception {
  const IngestRejected(this.code, this.message);

  final String code;
  final String message;
}

/// Hub: bảo vệ từng dòng (mã hóa, ký) rồi gom theo ngăn để ghi ít lần nhất
class Ingestor {
  Ingestor(this.cipher, this.write, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final FieldCipher cipher;
  final BucketWriter write;
  final DateTime Function() _clock;

  /// Firestore cho tối đa 500 thao tác một lần, chừa chỗ cho mục lục
  static const maxRows = 400;

  Future<int> ingest(
    String region,
    String tableName,
    List<IncomingRow> rows,
  ) async {
    final table = syncTable(tableName);
    if (table == null) {
      throw IngestRejected('unknown_table', 'Table $tableName is not synced');
    }
    if (rows.length > maxRows) {
      throw const IngestRejected('too_many_rows', 'At most $maxRows rows');
    }
    for (final r in rows) {
      if (r.key.keys.toSet().difference(table.key.toSet()).isNotEmpty ||
          r.key.length != table.key.length) {
        throw IngestRejected('invalid_key', 'Key must be ${table.key}');
      }
    }
    final at = _clock();
    final buckets = <String, Map<String, Map<String, Object?>>>{};
    for (final r in rows) {
      final secure = protectRow(
        cipher,
        region,
        table,
        r.key,
        r.data,
        syncedAt: at,
      );
      (buckets[secure.bucket] ??= {})[secure.docId] = secure.row;
    }
    final syncedAt = at.toUtc().toIso8601String();
    await write([
      for (final b in buckets.entries)
        (
          path: 'regions/$region/${table.table}/${b.key}',
          rows: b.value,
          top: {
            '_syncedAt': syncedAt,
            '_region': region,
            '_table': table.table,
          },
        ),
      // Mục lục của nước: khu vực đọc ở đây để biết bảng nào vừa đổi
      (
        path: 'regions/$region',
        rows: const {},
        top: {'tables.${table.table}': syncedAt},
      ),
    ]);
    return rows.length;
  }
}
