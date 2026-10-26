/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/proposal_ai.dart';
import 'package:project_contract_service/src/proposal_http.dart';
import 'package:project_contract_service/src/proposals.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /project-proposals/{id}: nội dung, lịch sử sửa qua lại, URL tạm mở
/// hợp đồng gốc
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  if (sideOf(context.read<Claims>()) == null) {
    return apiError(403, 'forbidden', 'Not allowed');
  }
  final number = int.tryParse(id);
  final proposals = context.read<ProposalRepository>();
  final found = number == null ? null : await proposals.find(number);
  if (found == null) return apiError(404, 'not_found', 'No proposal $id');
  final keys = await proposals.fileKeys(number!);
  final files = context.read<ProjectFiles?>();
  return Response.json(
    body: {
      ...found,
      if (files != null && keys.contract != null)
        'contractUrl': files.downloadUrl(keys.contract!).toString(),
      if (files != null && keys.image != null)
        'imageUrl': files.downloadUrl(keys.image!).toString(),
    },
  );
}
