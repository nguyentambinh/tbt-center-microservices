/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/knowledge_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /ask/{id}/feedback {helpful: true|false, comment?}
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_body', 'JSON object expected');
  }
  final helpful = body['helpful'];
  if (helpful is! bool) {
    return apiError(400, 'invalid_feedback', 'helpful must be true or false');
  }
  final comment = (body['comment'] as String?)?.trim();
  if (!RegExp(r'^[0-9a-f-]{36}$').hasMatch(id)) {
    return apiError(404, 'not_found', 'Answer $id not found');
  }
  final saved = await context.read<KnowledgeRepository>().saveFeedback(
    id,
    username: context.read<Claims>().username,
    helpful: helpful,
    comment: comment == null || comment.isEmpty
        ? null
        : comment.substring(0, comment.length.clamp(0, 500)),
  );
  if (!saved) return apiError(404, 'not_found', 'Answer $id not found');
  return Response(statusCode: 204);
}
