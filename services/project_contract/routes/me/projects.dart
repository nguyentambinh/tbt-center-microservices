/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/data/project_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /me/projects  dự án mình đang tham gia và số giờ đã làm (R38).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final employee = context.read<Claims>().employeeId;
  if (employee == null) {
    return apiError(403, 'no_employee', 'Account is not linked to an employee');
  }
  final items = await context.read<ProjectRepository>().projectsOf(employee);
  return Response.json(body: {'items': items});
}
