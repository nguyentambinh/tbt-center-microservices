/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:convert';
import 'dart:io';

import 'package:admin_service/src/region_databases.dart';
import 'package:tbt_common/tbt_common.dart';

/// Sao lưu logic: mọi bảng của các CSDL khu vực thành một tệp JSON nén gzip
/// trong Garage (`backups/<khu vực>/<thời điểm>.json.gz`); tải về bằng URL ký sẵn
class Backups {
  Backups(this._databases, this._store, this._log, {required this.region});

  final RegionDatabases _databases;
  final ObjectStore? _store;
  final Database _log;
  final String region;

  String get _prefix => 'backups/$region/';

  bool get configured => _store != null;

  Future<List<Map<String, dynamic>>> list() async {
    final store = _store;
    if (store == null) return const [];
    final items = await store.list(_prefix)
      ..sort((a, b) => b.modified.compareTo(a.modified));
    return [
      for (final i in items)
        {
          'key': i.key,
          'name': i.key.substring(_prefix.length),
          'sizeBytes': i.size,
          'createdAt': i.modified.toIso8601String(),
          'downloadUrl': store.downloadUrl(i.key).toString(),
        },
    ];
  }

  Future<Map<String, dynamic>> create({required String by}) async {
    final store = _store;
    if (store == null) throw StateError('Object store is not configured');
    final now = DateTime.now().toUtc();
    final databases = <String, Map<String, dynamic>>{};
    var rows = 0;
    for (final name in _databases.names) {
      final db = _databases[name];
      final tables = await db.query(
        'select table_name from information_schema.tables '
        "where table_schema = 'public' and table_type = 'BASE TABLE' "
        'order by table_name',
        fromPrimary: true,
      );
      final dump = <String, dynamic>{};
      for (final t in tables) {
        final table = t['table_name'] as String;
        final data = await db.query(
          "select coalesce(json_agg(t), '[]'::json)::text as rows "
          'from "$table" t',
          fromPrimary: true,
        );
        final list = jsonDecode(data.first['rows'] as String) as List;
        rows += list.length;
        dump[table] = list;
      }
      databases[name] = dump;
    }
    final stamp = now
        .toIso8601String()
        .replaceAll(RegExp('[-:]'), '')
        .substring(0, 15);
    final key = '$_prefix$stamp.json.gz';
    final bytes = gzip.encode(
      utf8.encode(
        jsonEncode({
          'region': region,
          'createdAt': now.toIso8601String(),
          'databases': databases,
        }),
      ),
    );
    await store.write(key, bytes, contentType: 'application/gzip');
    final result = {
      'key': key,
      'sizeBytes': bytes.length,
      'rows': rows,
      'databases': databases.keys.toList(),
    };
    await _log.transaction(
      (tx) => addOutboxEvent(
        tx,
        aggregate: 'admin',
        aggregateId: key,
        eventType: 'BackupCreated',
        payload: {...result, 'by': by},
      ),
    );
    return {...result, 'downloadUrl': store.downloadUrl(key).toString()};
  }
}
