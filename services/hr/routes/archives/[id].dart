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
import 'package:hr_service/src/organization.dart';
import 'package:hr_service/src/responses.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /archives/{id}  dự án đang tham gia, để cảnh báo trước khi bảo lưu
/// POST /archives/{id}  {reason}  rút khỏi mọi dự án rồi bảo lưu hồ sơ
/// DELETE /archives/{id}  khôi phục hồ sơ
Future<Response> onRequest(RequestContext context, String id) async {
  final repository = context.read<OrganizationRepository>();
  try {
    switch (context.request.method) {
      case HttpMethod.get:
        final projects = await context.read<ProjectsOf>()(id);
        return Response.json(body: {'employeeId': id, 'projects': projects});
      case HttpMethod.post:
        final reason = ((await jsonBody(context))['reason'] as String? ?? '')
            .trim();
        if (reason.isEmpty) return badBody('reason is required');
        // Bảo lưu trước (kiểm luật phòng ban), rút dự án lỗi thì hoàn lại
        await repository.archive(id, reason: reason, by: actor(context));
        final int removed;
        try {
          removed = await context.read<RemoveFromProjects>()(id);
        } on InternalCallException {
          await repository.restore(id, by: actor(context));
          rethrow;
        }
        await invalidateCache(cache, employeesCache);
        return Response.json(
          body: {
            'employeeId': id,
            'status': 'archived',
            'projectsLeft': removed,
          },
        );
      case HttpMethod.delete:
        await repository.restore(id, by: actor(context));
        await invalidateCache(cache, employeesCache);
        return Response.json(body: {'employeeId': id, 'status': 'active'});
      case _:
        return methodNotAllowed('GET, POST, DELETE only');
    }
  } on OrganizationViolation catch (e) {
    return violationResponse(e);
  } on InternalCallException catch (e) {
    stderr.writeln('Không gọi được project_contract: $e');
    return apiError(
      HttpStatus.badGateway,
      'projects_unavailable',
      'Project service is not reachable',
    );
  }
}
