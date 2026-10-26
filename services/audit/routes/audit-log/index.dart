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

/// GET /audit-log?region=&type=&from=&to=&limit=  tra cứu chỉ đọc (R54, R88).
/// Mỗi lần tra cứu được ghi vào nhật ký truy cập (R90).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final reader = auditReader(context);
  if (reader is Response) return reader;
  final claims = reader as Claims;

  final query = context.request.uri.queryParameters;
  final filter = filterFrom(query, region: readerRegion(claims));
  if (filter == null) {
    return apiError(400, 'invalid_dates', 'from, to must be YYYY-MM-DD');
  }
  final limit = (int.tryParse(query['limit'] ?? '') ?? 100).clamp(1, 500);

  final repository = context.read<AuditRepository>();
  final items = await repository.search(filter, limit: limit);
  await repository.logAccess(
    accessOf(claims, 'search', filter: filter, rowCount: items.length),
  );
  return Response.json(body: {'items': items});
}
