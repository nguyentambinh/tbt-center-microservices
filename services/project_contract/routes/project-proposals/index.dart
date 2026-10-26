/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/proposal_http.dart';
import 'package:project_contract_service/src/proposals.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /project-proposals?status=: đề xuất dự án của khu vực.
/// POST {data, contractKey, contractName, imageKey}: gửi Ban lãnh đạo duyệt
Future<Response> onRequest(RequestContext context) async {
  final side = sideOf(context.read<Claims>());
  if (side == null) return apiError(403, 'forbidden', 'Not allowed');
  final proposals = context.read<ProposalRepository>();
  if (context.request.method == HttpMethod.get) {
    final status = context.request.uri.queryParameters['status'];
    return Response.json(
      body: {'items': await proposals.list(status: status)},
    );
  }
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'GET or POST');
  }
  if (side != ProposalSide.proposer) {
    return apiError(403, 'forbidden', 'HR, finance or admin only');
  }
  final body = await jsonObject(context);
  final raw = body?['data'];
  if (raw is! Map<String, dynamic>) {
    return apiError(400, 'invalid_json', 'Body needs a data object');
  }
  String? key(String name, String prefix) {
    final v = body?[name];
    return v is String && v.startsWith(prefix) ? v : null;
  }

  try {
    final created = await proposals.create(
      ProposalData.fromJson(raw),
      by: context.read<Claims>().username,
      contractKey: key('contractKey', 'proposals/contract/'),
      contractName: body?['contractName'] as String?,
      imageKey: key('imageKey', 'proposals/image/'),
    );
    return Response.json(statusCode: 201, body: created);
  } on ProposalInvalid catch (e) {
    return invalidProposal(e);
  }
}
