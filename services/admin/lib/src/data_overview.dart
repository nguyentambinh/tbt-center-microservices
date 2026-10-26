/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:admin_service/src/region_databases.dart';
import 'package:tbt_common/tbt_common.dart';

/// Thống kê dữ liệu khu vực: dung lượng, số dòng từng bảng, hoạt động 14 ngày
/// (đếm theo outbox của mỗi service) và số tài khoản theo vai trò
class DataOverview {
  DataOverview(this._databases, this._keycloak, {required this.region});

  final RegionDatabases _databases;
  final KeycloakUsers _keycloak;
  final String region;

  static const _roles = [
    'employee',
    'hr',
    'finance',
    'executive',
    'admin',
    'auditor',
    'candidate',
  ];

  Future<Map<String, dynamic>> load() async {
    final databases = await Future.wait([
      for (final name in _databases.names) _database(name),
    ]);
    return {
      'region': region,
      'databases': databases,
      'accounts': await _accounts(),
    };
  }

  Future<Map<String, dynamic>> _database(String name) async {
    final db = _databases[name];
    try {
      final size = await db.query(
        'select pg_database_size(current_database())::bigint as bytes',
      );
      final tables = await db.query(
        'select table_name from information_schema.tables '
        "where table_schema = 'public' and table_type = 'BASE TABLE' "
        'order by table_name',
      );
      final names = [for (final t in tables) t['table_name'] as String];
      final counts = names.isEmpty
          ? const <Map<String, dynamic>>[]
          : await db.query(
              [
                for (final t in names)
                  "select '$t' as name, count(*)::int as rows from \"$t\"",
              ].join(' union all '),
            );
      final events = names.contains('outbox')
          ? await db.query(
              "select to_char(created_at, 'YYYY-MM-DD') as day, "
              'count(*)::int as events from outbox '
              "where created_at > now() - interval '14 days' "
              'group by 1 order by 1',
            )
          : const <Map<String, dynamic>>[];
      return {
        'name': name,
        'sizeBytes': size.first['bytes'],
        'tables': [
          for (final c in counts) {'name': c['name'], 'rows': c['rows']},
        ],
        'activity': [
          for (final e in events) {'day': e['day'], 'events': e['events']},
        ],
      };
    } on Exception catch (e) {
      stderr.writeln('Không đọc được $name: $e');
      return {'name': name, 'error': 'unavailable'};
    }
  }

  /// Số tài khoản của khu vực theo vai trò; Keycloak lỗi thì để trống
  Future<Map<String, int>?> _accounts() async {
    if (!_keycloak.configured) return null;
    try {
      final users = await _keycloak.search(
        attributes: {'region': region},
        max: 1000,
      );
      final counts = {for (final r in _roles) r: 0};
      for (final u in users) {
        for (final r in await _keycloak.roles(u.id)) {
          if (counts.containsKey(r)) counts[r] = counts[r]! + 1;
        }
      }
      return {'total': users.length, ...counts};
    } on KeycloakException catch (e) {
      stderr.writeln('Không đếm được tài khoản: $e');
      return null;
    }
  }
}
