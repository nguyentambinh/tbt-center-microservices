/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:audit_service/src/audit_repository.dart';
import 'package:dart_frog/dart_frog.dart';

/// GET /verify  tính lại chuỗi băm từ đầu, báo dòng đầu tiên bị sửa (nếu có).
Future<Response> onRequest(RequestContext context) async {
  final result = await context.read<AuditRepository>().verify();
  return Response.json(
    body: {
      'checked': result.checked,
      'intact': result.brokenAt == null,
      'brokenAt': result.brokenAt,
    },
  );
}
