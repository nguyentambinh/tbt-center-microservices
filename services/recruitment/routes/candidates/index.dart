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

/// GET /candidates?status=&q=  danh sách ứng viên cho HR.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  if (!context.read<Claims>().hasAnyRole(recruiterRoles)) {
    return apiError(403, 'forbidden', 'HR only');
  }
  final query = context.request.uri.queryParameters;
  final items = await context.read<CandidateRepository>().list(
    status: query['status'],
    query: query['q']?.trim(),
  );
  return Response.json(body: {'items': items});
}
