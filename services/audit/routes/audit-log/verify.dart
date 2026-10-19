/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:audit_service/src/audit_reader.dart';
import 'package:audit_service/src/audit_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /audit-log/verify  tính lại chuỗi băm cho người kiểm toán tự xem sổ
/// có bị sửa không (R89).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final reader = auditReader(context);
  if (reader is Response) return reader;

  final repository = context.read<AuditRepository>();
  final result = await repository.verify();
  await repository.logAccess(
    accessOf(reader as Claims, 'verify', rowCount: result.checked),
  );
  return Response.json(
    body: {
      'checked': result.checked,
      'intact': result.brokenAt == null,
      'brokenAt': result.brokenAt,
    },
  );
}
