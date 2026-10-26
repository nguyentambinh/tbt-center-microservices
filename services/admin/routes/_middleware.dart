/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:admin_service/src/backups.dart';
import 'package:admin_service/src/data_overview.dart';
import 'package:admin_service/src/region_databases.dart';
import 'package:admin_service/src/sql_console.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

final _env = Platform.environment;
final _region = _env['REGION'] ?? 'vn';
final _databases = RegionDatabases.fromEnvironment();
final _log = Database.fromEnvironment();
final _keycloak = KeycloakUsers.fromEnvironment();
final _console = SqlConsole(_databases, _log);
final _overview = DataOverview(_databases, _keycloak, region: _region);
final _backups = Backups(
  _databases,
  ObjectStore.fromEnvironment(),
  _log,
  region: _region,
);

/// Chỉ quản trị: quản trị một nước làm ở khu vực của mình, quản trị tập đoàn
/// (vai trò group) làm ở mọi khu vực
Handler middleware(Handler handler) {
  final protected = handler.use(
    requireClaims(anyRole: const {'admin'}, region: _region),
  );
  return ((RequestContext context) {
        if (context.request.uri.path == '/') return handler(context);
        return protected(context);
      })
      .use(provider<String>((_) => _region))
      .use(provider<Database>((_) => _log))
      .use(provider<KeycloakUsers>((_) => _keycloak))
      .use(provider<SqlConsole>((_) => _console))
      .use(provider<DataOverview>((_) => _overview))
      .use(provider<Backups>((_) => _backups))
      .use(correlationAndErrors())
      .use(metrics('admin'))
      .use(serviceRegistry('admin'));
}
