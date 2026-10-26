/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/data/project_repository.dart';
import 'package:project_contract_service/src/proposal_http.dart';
import 'package:project_contract_service/src/proposals.dart';
import 'package:tbt_common/tbt_common.dart';

const _actions = {'approve', 'counter', 'reject', 'withdraw'};

/// POST /project-proposals/{id}/respond  {action, data, note}: một bên đồng ý
/// bản hiện tại, sửa lại (counter) hoặc từ chối; đồng ý bản cuối thì tạo dự án
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  final side = sideOf(claims);
  if (side == null) return apiError(403, 'forbidden', 'Not allowed');
  final number = int.tryParse(id);
  final body = await jsonObject(context);
  final action = body?['action'];
  if (number == null || action is! String || !_actions.contains(action)) {
    return apiError(400, 'invalid_action', 'Unknown action');
  }
  final raw = body?['data'];
  try {
    final updated = await context.read<ProposalRepository>().respond(
      number,
      side: side,
      action: action,
      by: claims.username,
      data: raw is Map<String, dynamic> ? ProposalData.fromJson(raw) : null,
      note: (body?['note'] as String?)?.trim(),
    );
    if (updated == null) {
      return apiError(404, 'not_found', 'No proposal $id');
    }
    return Response.json(body: updated);
  } on ProposalInvalid catch (e) {
    return invalidProposal(e);
  } on ProjectRuleViolation catch (e) {
    return ruleViolation(e);
  }
}
