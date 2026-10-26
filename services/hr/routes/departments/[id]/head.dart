/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/cache.dart';
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:hr_service/src/responses.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /departments/{id}/head  {employeeId}  đặt trưởng phòng
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return methodNotAllowed('POST only');
  }
  final employeeId = (await jsonBody(context))['employeeId'] as String?;
  if (employeeId == null) return badBody('employeeId is required');
  try {
    await context.read<OrganizationRepository>().setHead(
      id,
      employeeId,
      by: actor(context),
    );
    await invalidateCache(cache, employeesCache);
    return Response.json(body: {'departmentId': id, 'headId': employeeId});
  } on OrganizationViolation catch (e) {
    return violationResponse(e);
  }
}
