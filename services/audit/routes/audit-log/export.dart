/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:audit_service/src/audit_access.dart';
import 'package:audit_service/src/audit_reader.dart';
import 'package:audit_service/src/audit_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /audit-log/export?region=&type=&from=&to=
/// Tệp CSV cho kiểm toán kèm mã SHA-256 ở header `X-Checksum-SHA256` (R89).
/// Mã cũng được ghi vào nhật ký truy cập, nên về sau đối chiếu được tệp nào
/// đã xuất cho ai, có bị sửa sau khi xuất không.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final reader = auditReader(context);
  if (reader is Response) return reader;

  final filter = filterFrom(
    context.request.uri.queryParameters,
    region: readerRegion(reader as Claims),
  );
  if (filter == null) {
    return apiError(400, 'invalid_dates', 'from, to must be YYYY-MM-DD');
  }
  final repository = context.read<AuditRepository>();
  final rows = await repository.search(filter, exportAll: true);
  final export = exportCsv(rows);
  await repository.logAccess(
    accessOf(
      reader,
      'export',
      filter: filter,
      rowCount: rows.length,
      checksum: export.checksum,
    ),
  );
  return Response(
    body: export.csv,
    headers: {
      'content-type': 'text/csv; charset=utf-8',
      'content-disposition': 'attachment; filename="tbt-audit.csv"',
      'x-checksum-sha256': export.checksum,
      'x-row-count': '${rows.length}',
    },
  );
}
