/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:hr_service/src/responses.dart';

/// GET /org-tree  cây tổ chức: phòng ban, trưởng phòng, người theo cấp chức vụ
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return methodNotAllowed('GET only');
  }
  return Response.json(
    body: await context.read<OrganizationRepository>().orgTree(),
  );
}
