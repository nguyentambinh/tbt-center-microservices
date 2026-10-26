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

/// GET /org-tree/positions-above/{mã nhân viên}  chức vụ cấp cao hơn, để đề cử
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return methodNotAllowed('GET only');
  }
  final items = await context.read<OrganizationRepository>().positionsAbove(
    id,
  );
  return Response.json(body: {'items': items});
}
