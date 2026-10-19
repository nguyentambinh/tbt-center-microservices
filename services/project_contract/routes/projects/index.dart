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

/// GET /projects?q=&limit=&offset=  dự án theo hợp đồng, khách hàng (R100).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  if (!context.read<Claims>().hasAnyRole(projectViewerRoles)) {
    return apiError(403, 'forbidden', 'Not allowed to view projects');
  }
  final query = context.request.uri.queryParameters;
  final limit = (int.tryParse(query['limit'] ?? '') ?? 20).clamp(1, 100);
  final offset = (int.tryParse(query['offset'] ?? '') ?? 0).clamp(0, 1 << 30);

  final page = await context.read<ProjectRepository>().projects(
    search: query['q']?.trim(),
    limit: limit,
    offset: offset,
  );
  return Response.json(body: {'items': page.items, 'total': page.total});
}
