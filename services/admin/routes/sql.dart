/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:admin_service/src/sql_console.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /sql  {database, sql, write}  chạy một câu SQL; mặc định chỉ đọc,
/// ghi phải gửi `write: true`. Mọi lần chạy đều lên sổ kiểm toán
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(HttpStatus.methodNotAllowed, 'method_not_allowed', 'POST');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(HttpStatus.badRequest, 'invalid_body', 'JSON object');
  }
  final database = body['database'];
  final sql = body['sql'];
  if (database is! String || sql is! String) {
    return apiError(
      HttpStatus.badRequest,
      'invalid_body',
      'database and sql are required',
    );
  }
  final claims = context.read<Claims>();
  try {
    final result = await context.read<SqlConsole>().run(
      database,
      sql,
      write: body['write'] == true,
      by: claims.username,
    );
    return Response.json(
      body: {
        'columns': result.columns,
        'rows': result.rows,
        'affected': result.affected,
        'truncated': result.truncated,
      },
    );
  } on SqlViolation catch (e) {
    return apiError(HttpStatus.badRequest, e.code, e.message);
  }
}
