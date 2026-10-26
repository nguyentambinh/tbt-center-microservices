/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:typed_data';

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/proposal_ai.dart';
import 'package:project_contract_service/src/proposal_http.dart';
import 'package:project_contract_service/src/proposals.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /project-proposals/extract  {objectKey, fileName}: AI đọc hợp đồng đã
/// tải lên thành các ô của đề xuất; không đọc được thì HR nhập tay
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  if (sideOf(context.read<Claims>()) != ProposalSide.proposer) {
    return apiError(403, 'forbidden', 'HR, finance or admin only');
  }
  final files = context.read<ProjectFiles?>();
  final body = await jsonObject(context);
  final key = body?['objectKey'];
  if (files == null ||
      key is! String ||
      !key.startsWith('proposals/contract/')) {
    return apiError(400, 'invalid_object', 'Unknown contract object');
  }
  final Uint8List? bytes;
  try {
    bytes = await files.read(key);
  } on Exception {
    return apiError(413, 'file_too_large', 'Contract must be at most 10 MB');
  }
  if (bytes == null) {
    return apiError(400, 'file_missing', 'Contract was not uploaded');
  }
  final result = await context.read<ProposalAdvisor>().readContract(
    bytes,
    fileName: body?['fileName'] as String? ?? 'contract',
  );
  return Response.json(body: result);
}
