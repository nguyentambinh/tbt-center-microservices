/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:admin_service/src/backups.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET  /backups  bản sao lưu đã có (mới nhất trước), kèm link tải
/// POST /backups  sao lưu ngay toàn bộ CSDL của khu vực
Future<Response> onRequest(RequestContext context) async {
  final backups = context.read<Backups>();
  if (!backups.configured) {
    return apiError(
      HttpStatus.serviceUnavailable,
      'storage_unavailable',
      'Object storage is not configured',
    );
  }
  return switch (context.request.method) {
    HttpMethod.get => Response.json(body: {'items': await backups.list()}),
    HttpMethod.post => Response.json(
      statusCode: HttpStatus.created,
      body: await backups.create(by: context.read<Claims>().username),
    ),
    _ => apiError(
      HttpStatus.methodNotAllowed,
      'method_not_allowed',
      'GET or POST',
    ),
  };
}
