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

/// GET /ask/stats?days=30  HR, quản trị xem câu hỏi chưa trả lời được để bổ sung bài (R51)
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  if (!context.read<Claims>().hasAnyRole(const {'hr', 'admin', 'executive'})) {
    return apiError(403, 'forbidden', 'HR, admin or executive only');
  }
  final days =
      (int.tryParse(context.request.uri.queryParameters['days'] ?? '') ?? 30)
          .clamp(1, 90);
  return Response.json(
    body: await context.read<KnowledgeRepository>().stats(days: days),
  );
}
