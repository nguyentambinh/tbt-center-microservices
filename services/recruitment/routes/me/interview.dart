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

const _actions = {'confirm'};

/// POST /me/interview  {action: confirm}: ứng viên xác nhận giờ HR hẹn
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  final me = await context.read<CandidateRepository>().findBySubject(
    claims.subject,
  );
  if (me == null) {
    return apiError(404, 'not_applied', 'No application yet');
  }
  final body = await jsonObject(context);
  final action = body?['action'];
  if (action is! String || !_actions.contains(action)) {
    return apiError(400, 'invalid_action', 'Unknown action');
  }
  try {
    final candidate = await context.read<InterviewRepository>().respond(
      me['id'] as String,
      party: Party.candidate,
      action: action,
      by: claims.subject,
      at: parseTime(body?['scheduledAt']),
      note: (body?['note'] as String?)?.trim(),
    );
    return Response.json(body: candidate ?? me);
  } on CandidateRuleViolation catch (e) {
    return violationResponse(e);
  }
}
