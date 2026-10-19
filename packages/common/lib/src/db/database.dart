/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:postgres/postgres.dart';

/// Kết nối tới database riêng của một service, tách đọc và ghi:
/// ghi (và đọc ngay sau khi ghi) đi primary, đọc danh sách, báo cáo đi replica.
class Database {
  Database({required Pool<void> primary, required Pool<void> replica})
    : _primary = primary,
      _replica = replica;

  /// Đọc cấu hình từ biến môi trường do docker compose truyền vào.
  factory Database.fromEnvironment([Map<String, String>? environment]) {
    final env = environment ?? Platform.environment;
    final primaryHost = env['DB_PRIMARY_HOST'] ?? 'localhost';

    Pool<void> pool(String host) => Pool.withEndpoints(
      [
        Endpoint(
          host: host,
          port: int.parse(env['DB_PORT'] ?? '5432'),
          database: env['DB_NAME'] ?? 'postgres',
          username: env['POSTGRES_USER'],
          password: env['POSTGRES_PASSWORD'],
        ),
      ],
      // Postgres nằm cùng mạng nội bộ docker, không bật SSL.
      settings: const PoolSettings(
        maxConnectionCount: 5,
        sslMode: SslMode.disable,
      ),
    );

    return Database(
      primary: pool(primaryHost),
      replica: pool(env['DB_REPLICA_HOST'] ?? primaryHost),
    );
  }

  final Pool<void> _primary;
  final Pool<void> _replica;

  /// Câu SELECT; [fromPrimary] khi cần thấy ngay dữ liệu vừa ghi.
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, Object?> params = const {},
    bool fromPrimary = false,
  }) async {
    final pool = fromPrimary ? _primary : _replica;
    final result = await pool.execute(Sql.named(sql), parameters: params);
    return [for (final row in result) row.toColumnMap()];
  }

  /// INSERT, UPDATE, DELETE luôn đi primary. Trả về các dòng của RETURNING.
  Future<List<Map<String, dynamic>>> execute(
    String sql, {
    Map<String, Object?> params = const {},
  }) async {
    final result = await _primary.execute(Sql.named(sql), parameters: params);
    return [for (final row in result) row.toColumnMap()];
  }

  /// Nhiều câu lệnh trong một giao dịch, ví dụ ghi dữ liệu cùng bảng outbox.
  Future<T> transaction<T>(Future<T> Function(TxSession tx) action) =>
      _primary.runTx(action);

  Future<void> close() async {
    await _primary.close();
    await _replica.close();
  }
}
