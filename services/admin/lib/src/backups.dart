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
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// CSDL nhật ký thao tác quản trị: giữ nguyên khi khôi phục
const _keptOnRestore = {'admin_db'};

/// Bảng kỹ thuật không bổ sung: sự kiện cũ đã lên sổ kiểm toán, khóa chống trùng
/// chỉ có ý nghĩa lúc gửi
const _skippedTables = {'outbox', 'idempotency_keys'};

/// Giới hạn kích thước tệp đọc lại khi khôi phục
const _maxBackupBytes = 512 << 20;

class BackupViolation implements Exception {
  const BackupViolation(this.code, this.message);

  final String code;
  final String message;
}

/// Giải nén bản sao lưu thành CSDL → bảng → chuỗi JSON các dòng. Bản định dạng
/// 2 giữ nguyên chuỗi do Postgres xuất nên không mất độ chính xác của số
Map<String, Map<String, String>> decodeBackup(
  List<int> bytes, {
  required String region,
}) {
  final Map<String, dynamic> file;
  try {
    file = jsonDecode(utf8.decode(gzip.decode(bytes))) as Map<String, dynamic>;
  } on Object {
    throw const BackupViolation('invalid_backup', 'Not a backup file');
  }
  if (file['databases'] is! Map<String, dynamic>) {
    throw const BackupViolation('invalid_backup', 'Not a backup file');
  }
  if (file['region'] != region) {
    throw const BackupViolation('wrong_region', 'Backup of another region');
  }
  return {
    for (final db in (file['databases'] as Map<String, dynamic>).entries)
      db.key: {
        for (final t in (db.value as Map<String, dynamic>).entries)
          t.key: t.value is String ? t.value as String : jsonEncode(t.value),
      },
  };
}

/// Sao lưu logic: mọi bảng của các CSDL khu vực thành một tệp JSON nén gzip
/// trong Garage (`backups/<khu vực>/<thời điểm>.json.gz`); tải về bằng URL ký
/// sẵn. Cấu trúc bảng do migration dựng nên tệp chỉ giữ dữ liệu
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
          "select coalesce(json_agg(t), '[]'::json)::text as rows, "
          'count(*)::int as n from "$table" t',
          fromPrimary: true,
        );
        rows += data.first['n'] as int;
        dump[table] = data.first['rows'];
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
          'format': 2,
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

  /// URL ký sẵn để tải một bản sao lưu từ máy lên kho của khu vực
  Map<String, String> uploadTarget() {
    final stamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(RegExp('[-:]'), '')
        .substring(0, 15);
    final key = '${_prefix}upload-$stamp.json.gz';
    return {
      'name': key.substring(_prefix.length),
      'uploadUrl': _store!.uploadUrl(key).toString(),
    };
  }

  /// Bổ sung từ bản [name] những dòng khu vực đang thiếu, không xóa và không
  /// sửa dòng đang có. Tự sao lưu trước; mỗi CSDL một giao dịch, lỗi giữa chừng
  /// thì CSDL đó giữ nguyên
  Future<Map<String, dynamic>> restore(
    String name, {
    required String by,
  }) async {
    final store = _store;
    if (store == null) throw StateError('Object store is not configured');
    if (!RegExp(r'^[\w.-]+\.json\.gz$').hasMatch(name)) {
      throw const BackupViolation('invalid_backup', 'Unknown backup name');
    }
    final bytes = await store.read('$_prefix$name', maxBytes: _maxBackupBytes);
    if (bytes == null) {
      throw const BackupViolation('invalid_backup', 'Backup not found');
    }
    final databases = decodeBackup(bytes, region: region);
    final safety = await create(by: by);
    final restored = <String>[];
    var added = 0;
    for (final db in databases.entries) {
      if (_keptOnRestore.contains(db.key) || !_databases.allowed(db.key)) {
        continue;
      }
      added += await _databases[db.key].transaction((tx) => _merge(tx, db.value));
      restored.add(db.key);
    }
    final result = {
      'name': name,
      'databases': restored,
      'addedRows': added,
      'safetyBackup': (safety['key'] as String).substring(_prefix.length),
    };
    await _log.transaction(
      (tx) => addOutboxEvent(
        tx,
        aggregate: 'admin',
        aggregateId: '$_prefix$name',
        eventType: 'BackupRestored',
        payload: {...result, 'by': by},
      ),
    );
    return result;
  }

  /// Thêm các dòng chưa có theo khóa chính, trả số dòng đã thêm. Tắt kiểm khóa
  /// ngoại trong giao dịch vì thứ tự bảng tùy ý; cột mới hơn bản sao lưu lấy mặc định
  Future<int> _merge(TxSession tx, Map<String, String> tables) async {
    await tx.execute("set local session_replication_role = 'replica'");
    final columns = <String, Set<String>>{};
    for (final row in await tx.execute(
      'select c.table_name::text, c.column_name::text '
      'from information_schema.columns c join information_schema.table_constraints k '
      'on k.table_schema = c.table_schema and k.table_name = c.table_name '
      "where c.table_schema = 'public' and k.constraint_type = 'PRIMARY KEY' "
      "and c.is_generated = 'NEVER'",
    )) {
      (columns[row[0]! as String] ??= {}).add(row[1]! as String);
    }
    var added = 0;
    for (final table in tables.entries) {
      final known = columns[table.key];
      if (known == null || _skippedTables.contains(table.key)) continue;
      final rows = table.value;
      final keys = await tx.execute(
        Sql.named(
          'select jsonb_object_keys(r)::text from '
          '(select @rows::text::jsonb -> 0 as r) x '
          "where jsonb_typeof(r) = 'object'",
        ),
        parameters: {'rows': rows},
      );
      final shared = [
        for (final k in keys)
          if (known.contains(k[0])) '"${k[0]}"',
      ].join(', ');
      if (shared.isEmpty) continue;
      final inserted = await tx.execute(
        Sql.named(
          'insert into "${table.key}" ($shared) overriding system value '
          'select $shared from jsonb_populate_recordset('
          'null::"${table.key}", @rows::text::jsonb) '
          'on conflict do nothing',
        ),
        parameters: {'rows': rows},
      );
      added += inserted.affectedRows;
    }
    // Bộ đếm tự tăng chạy tiếp sau giá trị lớn nhất vừa nạp
    for (final row in await tx.execute(
      'select table_name::text, column_name::text, pg_get_serial_sequence('
      "quote_ident(table_name), column_name) from information_schema.columns "
      "where table_schema = 'public' and pg_get_serial_sequence("
      'quote_ident(table_name), column_name) is not null',
    )) {
      if (!tables.containsKey(row[0])) continue;
      await tx.execute(
        Sql.named(
          'select setval(@seq::regclass, coalesce((select max("${row[1]}") '
          'from "${row[0]}"), 1), (select count(*) > 0 from "${row[0]}"))',
        ),
        parameters: {'seq': row[2]},
      );
    }
    return added;
  }
}
