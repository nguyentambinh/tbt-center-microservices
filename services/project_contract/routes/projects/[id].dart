/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/access.dart';
import 'package:project_contract_service/src/data/project_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /projects/{id}  hợp đồng, khách hàng, nhân sự tham gia.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(projectViewerRoles)) {
    return apiError(403, 'forbidden', 'Not allowed to view projects');
  }

  final project = await context.read<ProjectRepository>().project(id);
  if (project == null) return apiError(404, 'not_found', 'No project $id');

  final customer = project['customer'] as Map<String, dynamic>?;
  if (customer != null && !claims.hasAnyRole(customerContactRoles)) {
    project['customer'] = {
      'id': customer['id'],
      'name': customer['name'],
      'type': customer['type'],
    };
  }
  return Response.json(body: project);
}
