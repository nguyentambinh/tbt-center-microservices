/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /candidates/{id}/status  {"status": "interview", "note": "..."}
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(recruiterRoles)) {
    return apiError(403, 'forbidden', 'HR only');
  }

  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final status = body['status'];
  if (status is! String || !pipeline.contains(status)) {
    return apiError(400, 'invalid_status', 'Unknown status');
  }
  if (hireOnlyStatuses.contains(status)) {
    return apiError(400, 'use_hire', 'Use POST /candidates/{id}/hire');
  }

  final candidate = await context.read<CandidateRepository>().changeStatus(
    id,
    status: status,
    changedBy: claims.username,
    note: (body['note'] as String?)?.trim(),
  );
  if (candidate == null) {
    return apiError(404, 'not_found', 'Candidate $id not found');
  }
  return Response.json(body: candidate);
}
