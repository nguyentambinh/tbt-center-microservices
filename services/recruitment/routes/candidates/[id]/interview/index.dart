/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/interviews.dart';
import 'package:recruitment_service/src/responses.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /candidates/{id}/interview  {scheduledAt, location, note}: HR hẹn
/// phỏng vấn, gửi email và thông báo cho ứng viên
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(recruiterRoles)) {
    return apiError(403, 'forbidden', 'HR only');
  }
  final body = await jsonObject(context);
  final at = parseTime(body?['scheduledAt']);
  if (body == null || at == null) {
    return apiError(400, 'time_required', 'scheduledAt must be ISO 8601');
  }
  try {
    final candidate = await context.read<InterviewRepository>().schedule(
      id,
      at: at,
      by: claims.username,
      location: (body['location'] as String?)?.trim(),
      note: (body['note'] as String?)?.trim(),
    );
    if (candidate == null) {
      return apiError(404, 'not_found', 'Candidate $id not found');
    }
    return Response.json(body: candidate);
  } on CandidateRuleViolation catch (e) {
    return violationResponse(e);
  }
}
