/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:postgres/postgres.dart';
import 'package:sync_worker/src/firestore_mirror.dart';
import 'package:sync_worker/src/outbox_relay.dart';
import 'package:sync_worker/src/table_exporter.dart';
import 'package:tbt_common/tbt_common.dart';

/// Mỗi khu vực chạy một sync_worker: đọc outbox của các service, đẩy lên Hub.
/// Hub mất kết nối thì chờ lâu dần (5 giây → tối đa 1 phút) rồi thử lại.
Future<void> main() async {
  final env = Platform.environment;
  final region = env['REGION'] ?? 'vn';
  final services = (env['SYNC_SERVICES'] ?? 'attendance').split(',');
  final send = httpHubSender(
    Uri.parse(env['HUB_AUDIT_URL'] ?? 'http://localhost:8195/events'),
    env['SYNC_TOKEN'] ?? '',
  );

  final relays = [
    for (final service in services)
      OutboxRelay(
        region: region,
        service: service.trim(),
        send: send,
        db: Pool<void>.withEndpoints(
          [
            Endpoint(
              host: env['DB_PRIMARY_HOST'] ?? 'localhost',
              port: int.parse(env['DB_PORT'] ?? '5432'),
              database: '${service.trim()}_db',
              username: env['POSTGRES_USER'],
              password: env['POSTGRES_PASSWORD'],
            ),
          ],
          settings: const PoolSettings(
            maxConnectionCount: 2,
            sslMode: SslMode.disable,
          ),
        ),
      ),
  ];

  stdout.writeln('sync_worker $region: theo dõi ${services.join(', ')}');
  unawaited(_datastore(env, region));
  var failures = 0;
  while (true) {
    var sent = 0;
    var ok = true;
    for (final relay in relays) {
      try {
        sent += await relay.relayOnce();
      } on Exception catch (e) {
        ok = false;
        stderr.writeln('${relay.service}: $e');
      }
    }
    if (sent > 0) stdout.writeln('Đã đẩy $sent sự kiện lên Hub');
    failures = ok ? 0 : failures + 1;
    final wait = ok ? 5 : min(60, 5 << min(failures, 4));
    await Future<void>.delayed(Duration(seconds: wait));
  }
}

Pool<void> _pool(Map<String, String> env, String database) =>
    Pool<void>.withEndpoints(
      [
        Endpoint(
          host: env['DB_PRIMARY_HOST'] ?? 'localhost',
          port: int.parse(env['DB_PORT'] ?? '5432'),
          database: database,
          username: env['POSTGRES_USER'],
          password: env['POSTGRES_PASSWORD'],
        ),
      ],
      settings: const PoolSettings(
        maxConnectionCount: 2,
        sslMode: SslMode.disable,
      ),
    );

/// Kho tổng: đẩy bảng lên Hub mỗi phút, đọc Firestore về mỗi 10 phút
Future<void> _datastore(Map<String, String> env, String region) async {
  final url = env['DATASTORE_URL'];
  final token = env['DATASTORE_TOKEN'];
  if (url == null || token == null || token.isEmpty) {
    stdout.writeln('Chưa cấu hình kho tổng, bỏ qua');
    return;
  }
  final send = httpIngestSender(Uri.parse(url), token);
  final dbs = <String, Pool<void>>{};
  final exporters = <TableExporter>[];
  for (final db in {for (final t in syncCatalog) t.db}) {
    final pool = dbs[db] = _pool(env, db);
    exporters.add(
      TableExporter(pool, [
        for (final t in syncCatalog)
          if (t.db == db) t,
      ], send),
    );
  }
  for (final e in exporters) {
    await e.prepare();
  }

  final firestore = FirestoreClient.fromFile(env['FIRESTORE_SA']);
  FirestoreMirror? mirror;
  if (firestore != null) {
    mirror = FirestoreMirror(
      firestore: firestore,
      cipher: FieldCipher.fromEnvironment(),
      mirror: _pool(env, 'mirror_db'),
      region: region,
      ownState: (table) async {
        final db = dbs[syncTable(table)!.db]!;
        return {
          for (final r in await db.execute(
            Sql.named('select key, hash from fs_export_state where tbl = @t'),
            parameters: {'t': table},
          ))
            r[0]! as String: r[1]! as String,
        };
      },
    );
    await mirror.prepare();
  }

  var lastMirror = DateTime(2000);
  while (true) {
    try {
      var sent = 0;
      for (final e in exporters) {
        sent += await e.exportOnce();
      }
      if (sent > 0) stdout.writeln('Kho tổng: đã gửi $sent dòng lên Hub');
    } on Exception catch (e) {
      stderr.writeln('Kho tổng: gửi lên Hub lỗi, lượt sau thử lại: $e');
    }
    if (mirror != null &&
        DateTime.now().difference(lastMirror) > const Duration(minutes: 10)) {
      try {
        final r = await mirror.mirrorOnce();
        lastMirror = DateTime.now();
        stdout.writeln(
          'Kho tổng: đọc về ${r.rows} dòng, lệch ${r.drift}, bị sửa ${r.tampered}',
        );
      } on Exception catch (e) {
        stderr.writeln('Kho tổng: đọc Firestore lỗi: $e');
      }
    }
    await Future<void>.delayed(const Duration(minutes: 1));
  }
}
