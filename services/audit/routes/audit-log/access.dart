/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:audit_service/src/audit_access.dart';
import 'package:audit_service/src/audit_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /audit-log/access  ai đã đọc, kiểm, xuất sổ kiểm toán (R90).
/// Chỉ lãnh đạo, quản trị xem; kiểm toán viên không xem được nhật ký của mình.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  if (!context.read<Claims>().hasAnyRole(accessLogRoles)) {
    return apiError(403, 'forbidden', 'Executives and admins only');
  }
  final items = await context.read<AuditRepository>().accessLog();
  return Response.json(body: {'items': items});
}
