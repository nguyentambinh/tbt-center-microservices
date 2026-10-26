/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/work_region.dart';
import '../../core/config/env.dart';
import '../../core/error/app_failure.dart';
import '../../core/network/api_client.dart';

typedef DbTable = ({String name, int rows});
typedef DbActivity = ({String day, int events});
typedef DbInfo = ({String name, int? sizeBytes, List<DbTable> tables, List<DbActivity> activity, bool available});
typedef DataOverview = ({List<DbInfo> databases, Map<String, int>? accounts});
typedef AdminUser = ({String id, String username, String name, String? email, bool enabled, String? region, String? employeeId, List<String> roles});
typedef SqlResult = ({List<String> columns, List<List<Object?>> rows, int affected, bool truncated});
typedef Backup = ({String name, int sizeBytes, DateTime createdAt, String downloadUrl});
typedef Holiday = ({DateTime date, String name});
typedef PositionItem = ({String id, String name, int level, double coefficient, int holders});

/// Quản trị dữ liệu khu vực: thống kê, tài khoản, lịch làm việc, chức vụ, SQL, sao lưu
class AdminRepository {
  AdminRepository(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  Future<DataOverview> overview() async {
    final d = await _send(() => _dio.get<Map<String, dynamic>>('$baseUrl/admin/overview'));
    return (
      databases: [
        for (final db in d['databases'] as List? ?? const [])
          (
            name: (db as Map<String, dynamic>)['name'] as String,
            sizeBytes: (db['sizeBytes'] as num?)?.toInt(),
            tables: [for (final t in db['tables'] as List? ?? const []) (name: (t as Map)['name'] as String, rows: (t['rows'] as num).toInt())],
            activity: [for (final a in db['activity'] as List? ?? const []) (day: (a as Map)['day'] as String, events: (a['events'] as num).toInt())],
            available: db['error'] == null,
          ),
      ],
      accounts: (d['accounts'] as Map?)?.map((k, v) => MapEntry(k as String, (v as num).toInt())),
    );
  }

  Future<List<AdminUser>> users(String query) async {
    final d = await _send(() => _dio.get<Map<String, dynamic>>('$baseUrl/admin/users', queryParameters: {if (query.isNotEmpty) 'q': query}));
    return [for (final u in d['items'] as List? ?? const []) _user(u as Map<String, dynamic>)];
  }

  Future<AdminUser> updateUser(String id, {bool? enabled, Set<String> add = const {}, Set<String> remove = const {}}) async => _user(
        await _send(() => _dio.patch<Map<String, dynamic>>('$baseUrl/admin/users/$id',
            data: {'enabled': ?enabled, 'addRoles': add.toList(), 'removeRoles': remove.toList()})),
      );

  Future<SqlResult> runSql(String database, String sql, {required bool write}) async {
    final d = await _send(() => _dio.post<Map<String, dynamic>>('$baseUrl/admin/sql', data: {'database': database, 'sql': sql, 'write': write}));
    return (
      columns: [for (final c in d['columns'] as List? ?? const []) '$c'],
      rows: [for (final r in d['rows'] as List? ?? const []) List<Object?>.from(r as List)],
      affected: (d['affected'] as num? ?? 0).toInt(),
      truncated: d['truncated'] == true,
    );
  }

  Future<List<Backup>> backups() async {
    final d = await _send(() => _dio.get<Map<String, dynamic>>('$baseUrl/admin/backups'));
    return [for (final b in d['items'] as List? ?? const []) _backup(b as Map<String, dynamic>)];
  }

  Future<void> createBackup() => _send(() => _dio.post<Map<String, dynamic>>('$baseUrl/admin/backups', options: Options(receiveTimeout: const Duration(minutes: 3))));

  Future<List<Holiday>> holidays(int year) async {
    final d = await _send(() => _dio.get<Map<String, dynamic>>('$baseUrl/attendance/holidays', queryParameters: {'year': year}, options: Options(extra: {'noCache': true})));
    return [
      for (final h in d['items'] as List? ?? const [])
        (date: DateTime.parse((h as Map)['date'] as String), name: h['name'] as String? ?? ''),
    ];
  }

  Future<void> addHoliday(DateTime date, String name) =>
      _send(() => _dio.post<Map<String, dynamic>>('$baseUrl/attendance/holidays', data: {'date': _day(date), 'name': name}));

  Future<void> removeHoliday(DateTime date) => _send(() => _dio.delete<Map<String, dynamic>>('$baseUrl/attendance/holidays/${_day(date)}'));

  Future<int> setShift({required DateTime from, required DateTime to, required String start, required String end}) async =>
      ((await _send(() => _dio.put<Map<String, dynamic>>('$baseUrl/attendance/schedules/shift',
              data: {'from': _day(from), 'to': _day(to), 'start': start, 'end': end})))['schedules'] as num? ??
          0)
          .toInt();

  Future<List<PositionItem>> positions() async {
    final d = await _send(() => _dio.get<Map<String, dynamic>>('$baseUrl/hr/positions'));
    return [for (final p in d['items'] as List? ?? const []) _position(p as Map<String, dynamic>)];
  }

  Future<void> savePosition({String? id, required String name, required int level, required double coefficient}) => _send(() => id == null
      ? _dio.post<Map<String, dynamic>>('$baseUrl/hr/positions', data: {'name': name, 'level': level, 'coefficient': coefficient})
      : _dio.patch<Map<String, dynamic>>('$baseUrl/hr/positions/$id', data: {'name': name, 'level': level, 'coefficient': coefficient}));

  Future<void> deletePosition(String id) => _send(() => _dio.delete<Map<String, dynamic>>('$baseUrl/hr/positions/$id'));

  static AdminUser _user(Map<String, dynamic> u) => (
        id: u['id'] as String,
        username: u['username'] as String? ?? '',
        name: u['name'] as String? ?? '',
        email: u['email'] as String?,
        enabled: u['enabled'] == true,
        region: u['region'] as String?,
        employeeId: u['employeeId'] as String?,
        roles: [for (final r in u['roles'] as List? ?? const []) '$r'],
      );

  static Backup _backup(Map<String, dynamic> b) => (
        name: b['name'] as String? ?? '',
        sizeBytes: (b['sizeBytes'] as num? ?? 0).toInt(),
        createdAt: DateTime.tryParse(b['createdAt'] as String? ?? '') ?? DateTime(2000),
        downloadUrl: b['downloadUrl'] as String? ?? '',
      );

  static PositionItem _position(Map<String, dynamic> p) => (
        id: p['id'] as String,
        name: p['name'] as String? ?? '',
        level: (p['level'] as num? ?? 1).toInt(),
        coefficient: (p['coefficient'] as num? ?? 1).toDouble(),
        holders: (p['holders'] as num? ?? 0).toInt(),
      );

  static String _day(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<Map<String, dynamic>> _send(Future<Response<Map<String, dynamic>>> Function() call) async {
    try {
      return (await call()).data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(ref.watch(workRegionProvider))),
);

final adminOverviewProvider = FutureProvider.autoDispose<DataOverview>((ref) => ref.watch(adminRepositoryProvider).overview());
final adminBackupsProvider = FutureProvider.autoDispose<List<Backup>>((ref) => ref.watch(adminRepositoryProvider).backups());
final adminPositionsProvider = FutureProvider.autoDispose<List<PositionItem>>((ref) => ref.watch(adminRepositoryProvider).positions());
final adminHolidaysProvider = FutureProvider.autoDispose.family<List<Holiday>, int>((ref, year) => ref.watch(adminRepositoryProvider).holidays(year));
final adminUsersProvider = FutureProvider.autoDispose.family<List<AdminUser>, String>((ref, q) => ref.watch(adminRepositoryProvider).users(q));
