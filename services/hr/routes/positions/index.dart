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

/// GET  /positions  chức vụ kèm cấp, hệ số, số người giữ
/// POST /positions  {name, level, coefficient}  quản trị thêm chức vụ
Future<Response> onRequest(RequestContext context) async {
  final catalog = context.read<PositionCatalog>();
  if (context.request.method == HttpMethod.get) {
    return Response.json(body: {'items': await catalog.list()});
  }
  if (context.request.method != HttpMethod.post) {
    return methodNotAllowed('GET, POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(const {'admin'})) {
    return apiError(HttpStatus.forbidden, 'forbidden', 'Administrators only');
  }
  final body = await jsonBody(context);
  try {
    final created = await catalog.create(
      name: body['name'] as String? ?? '',
      level: (body['level'] as num?)?.toInt() ?? 1,
      coefficient: (body['coefficient'] as num?)?.toDouble() ?? 1,
      by: claims.username,
    );
    return Response.json(statusCode: HttpStatus.created, body: created);
  } on OrganizationViolation catch (e) {
    return violationResponse(e);
  }
}
