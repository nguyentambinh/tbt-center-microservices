/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/cache.dart';
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:hr_service/src/responses.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /employees/{id}/position  {positionId, promote, reason}
/// Văn phòng quản lý thăng chức, đổi chức vụ có hiệu lực ngay, ghi sổ kiểm toán
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return methodNotAllowed('POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(const {'executive'})) {
    return apiError(HttpStatus.forbidden, 'forbidden', 'Executives only');
  }
  if (claims.employeeId == id) {
    return apiError(
      HttpStatus.conflict,
      'self_approval',
      'You cannot change your own position',
    );
  }
  final body = await jsonBody(context);
  final positionId = body['positionId'];
  if (positionId is! String || positionId.isEmpty) {
    return badBody('positionId is required');
  }
  try {
    final changed = await context
        .read<OrganizationRepository>()
        .changePosition(
          id,
          positionId: positionId,
          promote: body['promote'] != false,
          by: actor(context),
          reason: (body['reason'] as String?)?.trim(),
        );
    await invalidateCache(cache, employeesCache);
    return Response.json(body: changed);
  } on OrganizationViolation catch (e) {
    return violationResponse(e);
  }
}
