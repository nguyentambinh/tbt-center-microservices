/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Gửi một lô dòng của bảng lên Hub; trả số dòng Hub đã ghi
typedef IngestSender = Future<int> Function(
  String table,
  List<Map<String, Object?>> rows,
);

/// Dấu băm ổn định của một dòng (sắp khóa) để biết dòng có đổi không
String rowHash(Map<String, Object?> row) {
  Object? canonical(Object? v) => switch (v) {
    final Map<String, Object?> m => {
      for (final k in m.keys.toList()..sort()) k: canonical(m[k]),
    },
    final List<Object?> l => [for (final x in l) canonical(x)],
    _ => v,
  };
  return sha256.convert(utf8.encode(jsonEncode(canonical(row)))).toString();
}

/// Đẩy dữ liệu bảng của một CSDL lên Hub: chỉ dòng mới, đổi hoặc bị xóa
class TableExporter {
  TableExporter(this.db, this.tables, this.send, {this.batchSize = 400});

  final Pool<void> db;
  final List<SyncTable> tables;
  final IngestSender send;
  final int batchSize;

  Future<void> prepare() => db.execute(
    'create table if not exists fs_export_state ('
    'tbl text not null, key text not null, hash text not null, '
    'primary key (tbl, key))',
  );

  /// Một lượt quét; trả số dòng đã gửi
  Future<int> exportOnce() async {
    var sent = 0;
    for (final table in tables) {
      sent += await _exportTable(table);
    }
    return sent;
  }

  Future<int> _exportTable(SyncTable table) async {
    final rows = await db.execute(
      'select to_jsonb(t)::text from public.${table.table} t',
    );
    final current =
        <
          String,
          ({Map<String, Object?> key, Map<String, Object?> data, String hash})
        >{};
    for (final r in rows) {
      final data = jsonDecode(r[0]! as String) as Map<String, Object?>;
      final key = {for (final k in table.key) k: data[k]};
      current[jsonEncode(key)] = (key: key, data: data, hash: rowHash(data));
    }
    final state = {
      for (final r in await db.execute(
        Sql.named('select key, hash from fs_export_state where tbl = @t'),
        parameters: {'t': table.table},
      ))
        r[0]! as String: r[1]! as String,
    };

    final changed = [
      for (final e in current.entries)
        if (state[e.key] != e.value.hash) e.key,
    ];
    final deleted = [
      for (final k in state.keys)
        if (!current.containsKey(k)) k,
    ];
    if (changed.isEmpty && deleted.isEmpty) return 0;

    final payload = [
      for (final k in changed)
        {'key': current[k]!.key, 'data': current[k]!.data},
      for (final k in deleted) {'key': jsonDecode(k), 'data': null},
    ];
    for (var i = 0; i < payload.length; i += batchSize) {
      final chunk = payload.sublist(
        i,
        (i + batchSize).clamp(0, payload.length),
      );
      await send(table.table, chunk);
      // Hub ghi xong lô nào thì mới đánh dấu lô đó
      await db.runTx((tx) async {
        for (final p in chunk) {
          final k = jsonEncode(p['key']);
          if (p['data'] == null) {
            await tx.execute(
              Sql.named(
                'delete from fs_export_state where tbl = @t and key = @k',
              ),
              parameters: {'t': table.table, 'k': k},
            );
          } else {
            await tx.execute(
              Sql.named(
                'insert into fs_export_state (tbl, key, hash) values (@t, @k, @h) '
                'on conflict (tbl, key) do update set hash = excluded.hash',
              ),
              parameters: {'t': table.table, 'k': k, 'h': current[k]!.hash},
            );
          }
        }
      });
    }
    return payload.length;
  }
}

/// Gửi lên datastore ở Hub kèm token riêng của nước
IngestSender httpIngestSender(Uri endpoint, String token) {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  return (table, rows) async {
    final request = await client.postUrl(endpoint);
    request.headers
      ..set('x-datastore-token', token)
      ..contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode({'table': table, 'rows': rows})));
    final response = await request.close().timeout(const Duration(seconds: 60));
    final text = await utf8.decodeStream(response);
    if (response.statusCode != 200) {
      throw HttpException('Hub datastore ${response.statusCode}: $text');
    }
    return (jsonDecode(text) as Map<String, dynamic>)['written'] as int;
  };
}
