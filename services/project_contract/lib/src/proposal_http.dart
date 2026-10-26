/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/data/project_repository.dart';
import 'package:project_contract_service/src/proposals.dart';
import 'package:tbt_common/tbt_common.dart';

/// Phía của người gọi: Ban lãnh đạo hoặc bên lập; không thuộc bên nào thì null
ProposalSide? sideOf(Claims claims) {
  if (claims.hasAnyRole(approverRoles)) return ProposalSide.executive;
  if (claims.hasAnyRole(proposerRoles)) return ProposalSide.proposer;
  return null;
}

/// Body JSON dạng object, sai thì null
Future<Map<String, dynamic>?> jsonObject(RequestContext context) async {
  try {
    final body = await context.request.json();
    return body is Map<String, dynamic> ? body : null;
  } on Object {
    return null;
  }
}

/// 422 kèm danh sách mã lỗi để app đánh dấu từng ô
Response invalidProposal(ProposalInvalid e) => Response.json(
  statusCode: 422,
  body: {
    'code': 'invalid_proposal',
    'message': 'Proposal breaks project rules',
    'errors': e.errors,
  },
);

Response ruleViolation(ProjectRuleViolation e) =>
    apiError(409, e.code, e.message);
