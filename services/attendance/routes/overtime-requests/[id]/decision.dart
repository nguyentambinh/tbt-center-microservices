/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:attendance_service/src/access.dart';
import 'package:attendance_service/src/data/overtime_repository.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /overtime-requests/{id}/decision  {"approve": true}
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(managerRoles)) {
    return apiError(403, 'forbidden', 'Only HR or managers can decide');
  }

  final Object? approve;
  try {
    approve = (await context.request.json() as Map<String, dynamic>)['approve'];
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be {"approve": bool}');
  }
  if (approve is! bool) {
    return apiError(400, 'invalid_json', 'Body must be {"approve": bool}');
  }

  try {
    final request = await context.read<OvertimeRepository>().decide(
      id,
      approve: approve,
      decidedBy: claims.username,
      deciderEmployeeId: claims.employeeId,
    );
    if (request == null) {
      return apiError(404, 'not_found', 'Overtime request $id not found');
    }
    return Response.json(body: request);
  } on LeaveRuleViolation catch (e) {
    return ruleError(e);
  }
}
