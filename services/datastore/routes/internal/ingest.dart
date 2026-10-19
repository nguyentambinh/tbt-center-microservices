/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:datastore_service/src/ingestor.dart';
import 'package:tbt_common/tbt_common.dart';

import '../_middleware.dart';

/// POST /internal/ingest {"table", "rows": [{"key": {...}, "data": {...}|null}]}
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final region = context.read<SourceRegion>();
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final table = body['table'];
  final rows = body['rows'];
  if (table is! String || rows is! List) {
    return apiError(400, 'invalid_ingest', 'table and rows required');
  }
  try {
    final written = await context.read<Ingestor>().ingest(region, table, [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          key: r['key'] as Map<String, Object?>,
          data: r['data'] as Map<String, Object?>?,
        ),
    ]);
    return Response.json(
      body: {'region': region, 'table': table, 'written': written},
    );
  } on IngestRejected catch (e) {
    return apiError(400, e.code, e.message);
  }
}
