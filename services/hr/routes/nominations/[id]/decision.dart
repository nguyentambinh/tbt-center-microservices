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
import 'package:hr_service/src/group_role.dart';
import 'package:hr_service/src/organization.dart';
import 'package:hr_service/src/responses.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /nominations/{id}/decision  {approve, note}  chỉ Ban lãnh đạo
/// Duyệt thì đổi chức vụ ở hr rồi tăng lương cơ bản ở payroll
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return methodNotAllowed('POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(const {'executive'})) {
    return apiError(HttpStatus.forbidden, 'forbidden', 'Executives only');
  }
  final nominationId = int.tryParse(id);
  if (nominationId == null) {
    return apiError(HttpStatus.notFound, 'not_found', 'No nomination $id');
  }
  final body = await jsonBody(context);
  final approve = body['approve'];
  if (approve is! bool) return badBody('approve must be true or false');
  final Map<String, dynamic>? decided;
  try {
    decided = await context.read<OrganizationRepository>().decideNomination(
      nominationId,
      approve: approve,
      decidedBy: actor(context),
      note: body['note'] as String?,
      groupDecider: claims.isGroup,
    );
  } on OrganizationViolation catch (e) {
    return violationResponse(e);
  }
  if (decided == null) {
    return apiError(HttpStatus.notFound, 'not_found', 'No nomination $id');
  }
  if (!approve) return Response.json(body: decided);
  await invalidateCache(cache, employeesCache);
  var salaryRaised = true;
  try {
    await context.read<RaiseSalary>()(
      decided['employeeId'] as String,
      decided['raisePercent'] as double,
      'Thăng chức: ${decided['proposedPosition']}',
    );
  } on InternalCallException catch (e) {
    // Chức vụ đã đổi; tăng lương làm lại được ở payroll
    stderr.writeln('Không tăng được lương: $e');
    salaryRaised = false;
  }
  // Lên cấp tập đoàn: tài khoản nhận thêm vai trò group, làm việc mọi khu vực
  if (decided['scope'] == 'group') {
    final granted = await grantGroupRole(
      context.read<KeycloakUsers>(),
      decided['employeeId'] as String,
      decided['groupRole'] as String? ?? 'hr',
    );
    return Response.json(
      body: {
        ...decided,
        'salaryRaised': salaryRaised,
        'accountUpdated': granted,
      },
    );
  }
  return Response.json(body: {...decided, 'salaryRaised': salaryRaised});
}
