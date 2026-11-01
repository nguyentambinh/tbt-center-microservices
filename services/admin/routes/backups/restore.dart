/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-11-01
 */

import 'dart:io';

import 'package:admin_service/src/backups.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /backups/restore  {name, confirm}  bổ sung từ một bản sao lưu những
/// dòng khu vực đang thiếu. Chỉ quản trị tập đoàn; `confirm` phải là mã khu vực
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(HttpStatus.methodNotAllowed, 'method_not_allowed', 'POST');
  }
  final claims = context.read<Claims>();
  if (!claims.isGroup) {
    return apiError(HttpStatus.forbidden, 'group_admin_only', 'Group admin');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(HttpStatus.badRequest, 'invalid_body', 'JSON object');
  }
  final name = body['name'];
  if (name is! String || body['confirm'] != context.read<String>()) {
    return apiError(
      HttpStatus.badRequest,
      'restore_not_confirmed',
      'confirm must be the region code',
    );
  }
  try {
    return Response.json(
      body: await context.read<Backups>().restore(name, by: claims.username),
    );
  } on BackupViolation catch (e) {
    return apiError(HttpStatus.badRequest, e.code, e.message);
  }
}
