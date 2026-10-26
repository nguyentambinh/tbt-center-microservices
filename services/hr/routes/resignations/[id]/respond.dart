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
import 'package:hr_service/src/data/resignation_repository.dart';
import 'package:hr_service/src/organization.dart';
import 'package:hr_service/src/responses.dart';
import 'package:tbt_common/tbt_common.dart';

import '../index.dart';

/// POST /resignations/{id}/respond  {action, note}
/// HR: approve, reject, complete (sau ngày làm cuối: bảo lưu hồ sơ, rút khỏi
/// dự án; rút lỗi thì khôi phục hồ sơ). Nhân viên: withdraw
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  final repository = context.read<ResignationRepository>();
  final number = int.tryParse(id);
  final found = number == null ? null : await repository.find(number);
  if (found == null) return apiError(404, 'not_found', 'No resignation $id');
  // Đơn của chính mình thì xử lý như nhân viên, người khác duyệt
  final mine = found['employeeId'] == claims.employeeId;
  final hr = claims.hasAnyRole(resignationHandlerRoles) && !mine;
  if (!hr && !mine) {
    return apiError(403, 'forbidden', 'Not your resignation');
  }
  final body = await jsonBody(context);
  final action = body['action'];
  if (action is! String) return apiError(400, 'invalid_action', 'action');
  final lastDay = DateTime.parse(found['lastDay'] as String);
  final today = DateTime.now();
  try {
    final next = nextResignationStatus(
      found['status'] as String,
      action,
      hr: hr,
      lastDayPassed: !DateTime(
        today.year,
        today.month,
        today.day,
      ).isBefore(lastDay),
    );
    final employee = found['employeeId'] as String;
    if (next == 'completed') {
      final org = context.read<OrganizationRepository>();
      await org.archive(
        employee,
        reason: 'resigned: ${found['reason']}',
        by: actor(context),
      );
      try {
        await context.read<RemoveFromProjects>()(employee);
      } on InternalCallException {
        await org.restore(employee, by: actor(context));
        return apiError(
          502,
          'projects_unavailable',
          'Project service is not reachable',
        );
      }
      await invalidateCache(cache, employeesCache);
    }
    return Response.json(
      body: await repository.setStatus(
        number!,
        status: next,
        by: claims.username,
        note: (body['note'] as String?)?.trim(),
      ),
    );
  } on ResignationViolation catch (e) {
    return apiError(409, e.code, e.message);
  } on OrganizationViolation catch (e) {
    return violationResponse(e);
  }
}
