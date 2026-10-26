/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/data/project_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /internal/members/{employeeId}  dự án nhân viên đang tham gia
/// DELETE /internal/members/{employeeId}  rút khỏi mọi dự án (bảo lưu hồ sơ)
Future<Response> onRequest(RequestContext context, String employeeId) async {
  final repository = context.read<ProjectRepository>();
  switch (context.request.method) {
    case HttpMethod.get:
      return Response.json(
        body: {'items': await repository.projectsOf(employeeId)},
      );
    case HttpMethod.delete:
      final removed = await repository.removeMember(employeeId);
      return Response.json(
        body: {'employeeId': employeeId, 'removed': removed},
      );
    case _:
      return apiError(405, 'method_not_allowed', 'GET, DELETE only');
  }
}
