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

/// GET /internal/candidate-of?sub=  mã hồ sơ ứng viên của một tài khoản.
/// notification dùng để biết thông báo trạng thái hồ sơ thuộc về ai, mà sự
/// kiện gửi lên Hub không phải mang thông tin tài khoản.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final sub = context.request.uri.queryParameters['sub'];
  if (sub == null || sub.isEmpty) {
    return apiError(400, 'sub_required', 'sub is required');
  }
  final candidate = await context.read<CandidateRepository>().findBySubject(
    sub,
  );
  return Response.json(body: {'candidateId': candidate?['id']});
}
