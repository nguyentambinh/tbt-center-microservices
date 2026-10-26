/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/change_request_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /me/change-requests  đề xuất sửa thông tin của mình.
/// POST /me/change-requests  {changes: {phone: ...}, reason}  gửi HR duyệt.
Future<Response> onRequest(RequestContext context) async {
  final id = context.read<Claims>().employeeId;
  if (id == null) {
    return apiError(
      HttpStatus.forbidden,
      'no_employee',
      'Account is not linked to an employee',
    );
  }
  final repository = context.read<ChangeRequestRepository>();
  switch (context.request.method) {
    case HttpMethod.get:
      return Response.json(body: {'items': await repository.mine(id)});
    case HttpMethod.post:
      final body = await context.request.json() as Map<String, dynamic>;
      final changes =
          (body['changes'] as Map?)?.cast<String, Object?>() ?? const {};
      try {
        final created = await repository.create(
          id,
          changes,
          reason: body['reason'] as String?,
        );
        return Response.json(statusCode: HttpStatus.created, body: created);
      } on ChangeRequestViolation catch (e) {
        final status = e.code == 'pending_exists'
            ? HttpStatus.conflict
            : HttpStatus.badRequest;
        return apiError(status, e.code, e.message);
      }
    case _:
      return apiError(
        HttpStatus.methodNotAllowed,
        'method_not_allowed',
        'GET, POST only',
      );
  }
}
