/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/graph/extractor.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /proposals/{id} {"action": "approve"} hoặc {"action": "reject", "reason": "..."}
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(reviewerRoles)) {
    return apiError(403, 'forbidden', 'HR, admin or executive only');
  }
  if (!RegExp(r'^[0-9a-f-]{36}$').hasMatch(id)) {
    return apiError(404, 'not_found', 'No proposal $id');
  }
  final body = await context.request.json();
  if (body is! Map<String, dynamic>) {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final extractor = context.read<GraphExtractor>();
  final problem = switch (body['action']) {
    'approve' => await extractor.approve(id, reviewer: claims.username),
    'reject' => await extractor.reject(
      id,
      reviewer: claims.username,
      reason: body['reason'] as String?,
    ),
    _ => 'invalid_action',
  };
  return switch (problem) {
    null => Response.json(
      body: {
        'id': id,
        'status': body['action'] == 'approve' ? 'approved' : 'rejected',
      },
    ),
    'not_found' => apiError(404, 'not_found', 'No proposal $id'),
    'invalid_action' => apiError(
      400,
      'invalid_action',
      'action must be approve or reject',
    ),
    'not_pending' => apiError(409, 'not_pending', 'Proposal already reviewed'),
    _ => apiError(409, 'invalid_proposal', problem),
  };
}
