/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/storage/cv_storage.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /candidates/{id}/cv  HR lấy URL tải CV, hết hạn sau 5 phút.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  if (!context.read<Claims>().hasAnyRole(recruiterRoles)) {
    return apiError(403, 'forbidden', 'HR only');
  }
  final key = await context.read<CandidateRepository>().cvKey(id);
  if (key == null) return apiError(404, 'no_cv', 'Candidate has no CV');
  return Response.json(
    body: {
      'downloadUrl': context.read<CvStorage>().downloadUrl(key).toString(),
    },
  );
}
