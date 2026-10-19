/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/knowledge_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /articles/{id}?lang=vi
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final lang = context.request.uri.queryParameters['lang'] ?? 'en';
  final repository = context.read<KnowledgeRepository>();
  final article =
      await repository.find(id, lang: lang) ??
      await repository.find(id, lang: 'en');
  if (article == null) {
    return apiError(404, 'not_found', 'Article $id not found');
  }
  return Response.json(body: article);
}
