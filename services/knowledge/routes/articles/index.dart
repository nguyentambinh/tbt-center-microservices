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

const _languages = {'vi', 'en', 'de', 'pt'};

/// GET /articles?q=tang ca&lang=vi  tìm bài, chưa có ngôn ngữ đó thì dùng tiếng Anh
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final query = context.request.uri.queryParameters;
  final q = (query['q'] ?? '').trim();
  if (q.length > 200) {
    return apiError(400, 'query_too_long', 'At most 200 chars');
  }
  final lang = _languages.contains(query['lang']) ? query['lang']! : 'en';
  final region = context.read<Claims>().region ?? 'vn';
  final repository = context.read<KnowledgeRepository>();
  var items = await repository.search(q, lang: lang, region: region);
  if (items.isEmpty && lang != 'en' && lang != 'vi') {
    items = await repository.search(q, lang: 'en', region: region);
  }
  return Response.json(body: {'items': items});
}
