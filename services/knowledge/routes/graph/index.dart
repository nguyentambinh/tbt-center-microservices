/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/graph_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /graph?q=tang ca&lang=vi  danh sách nút, có q thì lọc theo tên
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final query = context.request.uri.queryParameters;
  final q = query['q'] ?? '';
  if (q.length > 100) {
    return apiError(400, 'query_too_long', 'At most 100 chars');
  }
  final nodes = await context.read<GraphRepository>().nodes(
    lang: query['lang'] ?? 'en',
    query: q,
  );
  return Response.json(body: {'items': nodes});
}
