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

/// POST /departments/{id}/members  {employeeIds: [...]}  điều chuyển vào phòng
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return methodNotAllowed('POST only');
  }
  final body = await jsonBody(context);
  final ids = [
    ...(body['employeeIds'] as List? ?? const []).cast<String>(),
    if (body['employeeId'] case final String one) one,
  ];
  if (ids.isEmpty) return badBody('employeeIds is required');
  final repository = context.read<OrganizationRepository>();
  final moved = <String>[];
  final failed = <Map<String, String>>[];
  for (final employeeId in ids) {
    try {
      await repository.transfer(
        employeeId,
        toDepartment: id,
        by: actor(context),
      );
      moved.add(employeeId);
    } on OrganizationViolation catch (e) {
      if (ids.length == 1) return violationResponse(e);
      failed.add({'employeeId': employeeId, 'code': e.code});
    }
  }
  if (moved.isNotEmpty) await invalidateCache(cache, employeesCache);
  return Response.json(body: {'moved': moved, 'failed': failed});
}
