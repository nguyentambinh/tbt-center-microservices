/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/resignation_repository.dart';
import 'package:tbt_common/tbt_common.dart';

import '../index.dart' show resignationHandlerRoles;

/// GET /resignations/{id}/letter  URL tạm để mở bản đơn gốc (người gửi, cấp trên)
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(HttpStatus.methodNotAllowed, 'method_not_allowed', 'GET');
  }
  final number = int.tryParse(id);
  final repository = context.read<ResignationRepository>();
  final found = number == null ? null : await repository.find(number);
  if (found == null) return apiError(404, 'not_found', 'No resignation $id');
  final claims = context.read<Claims>();
  if (found['employeeId'] != claims.employeeId &&
      !claims.hasAnyRole(resignationHandlerRoles)) {
    return apiError(403, 'forbidden', 'Not your resignation');
  }
  final key = await repository.letterKey(number!);
  final store = context.read<ObjectStore?>();
  if (key == null || store == null) {
    return apiError(404, 'file_missing', 'No letter attached');
  }
  return Response.json(
    body: {
      'url': store.downloadUrl(key).toString(),
      'name': found['letterName'],
    },
  );
}
