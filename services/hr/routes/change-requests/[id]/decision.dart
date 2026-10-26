/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/cache.dart';
import 'package:hr_service/src/data/change_request_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /change-requests/{id}/decision  {approve: true|false, note}
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(
      HttpStatus.methodNotAllowed,
      'method_not_allowed',
      'POST only',
    );
  }
  final requestId = int.tryParse(id);
  if (requestId == null) {
    return apiError(HttpStatus.notFound, 'not_found', 'No request $id');
  }
  final body = await context.request.json() as Map<String, dynamic>;
  final approve = body['approve'];
  if (approve is! bool) {
    return apiError(
      HttpStatus.badRequest,
      'invalid_body',
      'approve must be true or false',
    );
  }
  final claims = context.read<Claims>();
  try {
    final decided = await context.read<ChangeRequestRepository>().decide(
      requestId,
      approve: approve,
      decidedBy: claims.employeeId ?? claims.subject,
      note: body['note'] as String?,
    );
    if (decided == null) {
      return apiError(HttpStatus.notFound, 'not_found', 'No request $id');
    }
    // Hồ sơ vừa đổi: danh sách, chi tiết trong cache hết đúng
    if (approve) await invalidateCache(cache, employeesCache);
    return Response.json(body: decided);
  } on ChangeRequestViolation catch (e) {
    return apiError(HttpStatus.conflict, e.code, e.message);
  }
}
