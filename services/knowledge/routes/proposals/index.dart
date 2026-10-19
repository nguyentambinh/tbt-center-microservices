/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/graph/extractor.dart';
import 'package:knowledge_service/src/graph/graph_store.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /proposals?status=pending  đề xuất AI trích từ bài viết (R51)
/// POST /proposals {"articleId": "suppliers"}  cho AI đọc lại một bài, bỏ trống là mọi bài mới, bài đã sửa
Future<Response> onRequest(RequestContext context) async {
  if (!context.read<Claims>().hasAnyRole(reviewerRoles)) {
    return apiError(403, 'forbidden', 'HR, admin or executive only');
  }
  final extractor = context.read<GraphExtractor>();
  switch (context.request.method) {
    case HttpMethod.get:
      final status = context.request.uri.queryParameters['status'];
      if (status != null &&
          !const {
            'pending',
            'approved',
            'rejected',
            'invalid',
          }.contains(status)) {
        return apiError(400, 'invalid_status', 'Unknown status $status');
      }
      return Response.json(
        body: {
          'running': extractor.running,
          'configured': extractor.configured,
          'items': await context.read<GraphStore>().proposals(
            status: status,
            limit: 200,
          ),
        },
      );
    case HttpMethod.post:
      if (!extractor.configured) {
        return apiError(503, 'ai_unavailable', 'No AI model configured');
      }
      final body = await context.request.body();
      final json = body.trim().isEmpty
          ? const <String, dynamic>{}
          : jsonDecode(body);
      final articleId = json is Map ? json['articleId'] as String? : null;
      final queued = await extractor.queue(articleId: articleId);
      return Response.json(
        statusCode: 202,
        body: {'queued': queued, 'running': extractor.running},
      );
    case HttpMethod.delete ||
        HttpMethod.head ||
        HttpMethod.options ||
        HttpMethod.patch ||
        HttpMethod.put:
      return apiError(405, 'method_not_allowed', 'GET or POST only');
  }
}
