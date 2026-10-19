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

/// GET /graph/{id}?lang=vi&depth=1  một nút và các nút quanh nó;
/// có to=... thì trả đường ngắn nhất nối hai nút
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final query = context.request.uri.queryParameters;
  final lang = query['lang'] ?? 'en';
  final graph = context.read<GraphRepository>();
  if (query['to'] case final to? when to.isNotEmpty) {
    final path = await graph.path(id, to, lang: lang);
    if (path == null) {
      return apiError(404, 'no_path', 'No path from $id to $to');
    }
    return Response.json(body: path);
  }
  final depth = int.tryParse(query['depth'] ?? '') ?? 1;
  final result = await graph.neighborhood(id, lang: lang, depth: depth);
  if (result == null) return apiError(404, 'not_found', 'Node $id not found');
  return Response.json(body: result);
}
