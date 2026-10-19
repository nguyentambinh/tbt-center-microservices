/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:sync_worker/src/table_exporter.dart';
import 'package:tbt_common/tbt_common.dart';

/// Kết quả một lượt đọc về
typedef MirrorResult = ({int rows, int tampered, int drift});

/// Khu vực đọc kho tổng trên Firestore (quyền chỉ đọc) về mirror_db
class FirestoreMirror {
  FirestoreMirror({
    required this.firestore,
    required this.cipher,
    required this.mirror,
    required this.region,
    required this.ownState,
    this.regions = const ['vn', 'de', 'us', 'br', 'za', 'au'],
  });

  final FirestoreClient firestore;
  final FieldCipher cipher;
  final Pool<void> mirror;
  final String region;

  /// Dấu băm dòng của nước mình lúc gửi lên, để đối chiếu lệch
  final Future<Map<String, String>> Function(String table) ownState;
  final List<String> regions;

  Future<void> prepare() async {
    await mirror.execute(
      'create table if not exists mirror_rows ('
      'region text not null, tbl text not null, doc_id text not null, '
      'row_key jsonb, data jsonb not null, readable boolean not null, '
      'deleted boolean not null, synced_at text not null, '
      'primary key (region, tbl, doc_id))',
    );
    await mirror.execute(
      'create table if not exists mirror_checkpoint ('
      'region text not null, tbl text not null, synced_at text not null, '
      'primary key (region, tbl))',
    );
  }

  Future<MirrorResult> mirrorOnce() async {
    var rows = 0, tampered = 0, drift = 0;
    final checkpoints = {
      for (final r in await mirror.execute(
        'select region, tbl, synced_at from mirror_checkpoint',
      ))
        '${r[0]}/${r[1]}': r[2]! as String,
    };
    for (final source in regions) {
      // Mục lục của nước: chỉ đọc bảng vừa đổi, tiết kiệm lượt đọc
      final index = await firestore.get('regions/$source');
      final tables = (index?['tables'] as Map<String, Object?>?) ?? {};
      for (final entry in tables.entries) {
        final table = syncTable(entry.key);
        final last = checkpoints['$source/${entry.key}'] ?? '';
        if (table == null || (entry.value! as String).compareTo(last) <= 0) {
          continue;
        }
        final buckets = await firestore.changedSince(
          'regions/$source',
          table.table,
          last,
        );
        final ownHashes = source == region ? await ownState(table.table) : null;
        await mirror.runTx((tx) async {
          for (final bucket in buckets) {
            final stored = bucket.fields['rows'] as Map<String, Object?>? ?? {};
            for (final row in stored.entries) {
              final OpenedRow opened;
              try {
                opened = openRow(
                  cipher,
                  source,
                  table,
                  row.key,
                  row.value! as Map<String, Object?>,
                );
              } on CipherTampered catch (e) {
                // Bị sửa trên kho tổng: không lấy về, báo lỗi
                tampered++;
                stderr.writeln('Dòng bị sửa trên Firestore: $e');
                continue;
              }
              if (ownHashes != null && opened.key != null && !opened.deleted) {
                if (ownHashes[jsonEncode(opened.key)] != rowHash(opened.data)) {
                  drift++;
                }
              }
              await tx.execute(
                Sql.named(
                  'insert into mirror_rows (region, tbl, doc_id, row_key, data, '
                  'readable, deleted, synced_at) values (@r, @t, @d, @k, @data, '
                  '@readable, @deleted, @at) on conflict (region, tbl, doc_id) do '
                  'update set row_key = excluded.row_key, data = excluded.data, '
                  'readable = excluded.readable, deleted = excluded.deleted, '
                  'synced_at = excluded.synced_at',
                ),
                parameters: {
                  'r': source,
                  't': table.table,
                  'd': opened.docId,
                  'k': TypedValue(Type.jsonb, opened.key),
                  'data': TypedValue(Type.jsonb, opened.data),
                  'readable': opened.readable,
                  'deleted': opened.deleted,
                  'at': (row.value! as Map<String, Object?>)['_syncedAt'],
                },
              );
              rows++;
            }
          }
          await tx.execute(
            Sql.named(
              'insert into mirror_checkpoint (region, tbl, synced_at) '
              'values (@r, @t, @at) on conflict (region, tbl) do update '
              'set synced_at = excluded.synced_at',
            ),
            parameters: {'r': source, 't': table.table, 'at': entry.value},
          );
        });
      }
    }
    return (rows: rows, tampered: tampered, drift: drift);
  }
}
