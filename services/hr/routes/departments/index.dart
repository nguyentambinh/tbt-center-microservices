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
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:hr_service/src/responses.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /departments  danh sách phòng ban
/// POST /departments  {name, companyId}  thêm phòng ban
Future<Response> onRequest(RequestContext context) async {
  final repository = context.read<OrganizationRepository>();
  switch (context.request.method) {
    case HttpMethod.get:
      return Response.json(body: {'items': await repository.departments()});
    case HttpMethod.post:
      final body = await jsonBody(context);
      final name = (body['name'] as String? ?? '').trim();
      final companyId = body['companyId'] as String? ?? '';
      if (name.isEmpty || companyId.isEmpty) {
        return badBody('name and companyId are required');
      }
      try {
        final created = await repository.createDepartment(
          name: name,
          companyId: companyId,
          createdBy: actor(context),
        );
        await invalidateCache(cache, employeesCache);
        return Response.json(statusCode: HttpStatus.created, body: created);
      } on OrganizationViolation catch (e) {
        return violationResponse(e);
      }
    case _:
      return methodNotAllowed('GET, POST only');
  }
}
