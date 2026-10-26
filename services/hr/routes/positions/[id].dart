/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:hr_service/src/data/position_catalog.dart';
import 'package:hr_service/src/responses.dart';
import 'package:tbt_common/tbt_common.dart';

/// PATCH  /positions/{id}  {name, level, coefficient}  quản trị sửa
/// DELETE /positions/{id}  quản trị xóa chức vụ không còn ai giữ
Future<Response> onRequest(RequestContext context, String id) async {
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(const {'admin'})) {
    return apiError(HttpStatus.forbidden, 'forbidden', 'Administrators only');
  }
  final catalog = context.read<PositionCatalog>();
  try {
    switch (context.request.method) {
      case HttpMethod.patch:
        final body = await jsonBody(context);
        final updated = await catalog.update(
          id,
          by: claims.username,
          name: body['name'] as String?,
          level: (body['level'] as num?)?.toInt(),
          coefficient: (body['coefficient'] as num?)?.toDouble(),
        );
        return updated == null
            ? apiError(HttpStatus.notFound, 'not_found', 'No position $id')
            : Response.json(body: updated);
      case HttpMethod.delete:
        return await catalog.delete(id, by: claims.username)
            ? Response(statusCode: HttpStatus.noContent)
            : apiError(HttpStatus.notFound, 'not_found', 'No position $id');
      case _:
        return methodNotAllowed('PATCH, DELETE only');
    }
  } on OrganizationViolation catch (e) {
    return violationResponse(e);
  }
}
