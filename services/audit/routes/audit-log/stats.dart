/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:audit_service/src/audit_reader.dart';
import 'package:audit_service/src/audit_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /audit-log/stats?region=&type=&service=&anomaly=&from=&to=
/// số liệu cho biểu đồ kiểm toán; mỗi lần xem cũng ghi nhật ký truy cập
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final reader = auditReader(context);
  if (reader is Response) return reader;
  final filter = filterFrom(context.request.uri.queryParameters);
  if (filter == null) {
    return apiError(400, 'invalid_filter', 'Check dates and anomaly');
  }
  final repository = context.read<AuditRepository>();
  final stats = await repository.stats(filter);
  await repository.logAccess(
    accessOf(
      reader as Claims,
      'stats',
      filter: filter,
      rowCount: stats['total'] as int? ?? 0,
    ),
  );
  return Response.json(body: stats);
}
