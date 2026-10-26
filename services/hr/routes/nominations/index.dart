/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:hr_service/src/responses.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /nominations?status=pending  danh sách đề cử
/// POST /nominations  {employeeId, proposedPosition, raisePercent, reason}
Future<Response> onRequest(RequestContext context) async {
  final repository = context.read<OrganizationRepository>();
  switch (context.request.method) {
    case HttpMethod.get:
      final status = context.request.uri.queryParameters['status'];
      return Response.json(
        body: {'items': await repository.nominations(status: status)},
      );
    case HttpMethod.post:
      if (!context.read<Claims>().hasAnyRole(const {'hr'})) {
        return apiError(HttpStatus.forbidden, 'forbidden', 'HR only');
      }
      final body = await jsonBody(context);
      final employeeId = body['employeeId'] as String?;
      final position = (body['proposedPosition'] as String? ?? '').trim();
      final percent = (body['raisePercent'] as num?)?.toDouble();
      final reason = (body['reason'] as String? ?? '').trim();
      if (employeeId == null ||
          position.isEmpty ||
          percent == null ||
          reason.isEmpty) {
        return badBody(
          'employeeId, proposedPosition, raisePercent, reason are required',
        );
      }
      try {
        final created = await repository.nominate(
          employeeId: employeeId,
          proposedPosition: position,
          raisePercent: percent,
          reason: reason,
          nominatedBy: actor(context),
          groupRole: body['groupRole'] as String?,
        );
        return Response.json(statusCode: HttpStatus.created, body: created);
      } on OrganizationViolation catch (e) {
        return violationResponse(e);
      }
    case _:
      return methodNotAllowed('GET, POST only');
  }
}
