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

/// POST /backups/upload-url  URL ký sẵn để tải một bản sao lưu từ máy lên kho
/// của khu vực. Chỉ quản trị tập đoàn
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(HttpStatus.methodNotAllowed, 'method_not_allowed', 'POST');
  }
  if (!context.read<Claims>().isGroup) {
    return apiError(HttpStatus.forbidden, 'group_admin_only', 'Group admin');
  }
  final backups = context.read<Backups>();
  if (!backups.configured) {
    return apiError(
      HttpStatus.serviceUnavailable,
      'storage_unavailable',
      'Object storage is not configured',
    );
  }
  return Response.json(body: backups.uploadTarget());
}
