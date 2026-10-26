/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/offer.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /candidates/{id}/offer?language=vi: AI gợi ý phòng ban, lương cơ bản
/// để HR xác nhận hoặc sửa trước khi nhận việc
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(recruiterRoles)) {
    return apiError(403, 'forbidden', 'HR only');
  }
  final candidate = await context.read<CandidateRepository>().findById(id);
  if (candidate == null) {
    return apiError(404, 'not_found', 'Candidate $id not found');
  }
  if (candidate['status'] != 'interviewed') {
    return apiError(409, 'not_interviewed', 'Upload interview minutes first');
  }
  final language = switch (context.request.uri.queryParameters['language']) {
    'de' => 'German',
    'pt' => 'Brazilian Portuguese',
    'en' => 'English',
    _ => 'Vietnamese',
  };
  try {
    return Response.json(
      body: await context.read<OfferAdvisor>().suggest(
        candidate,
        language: language,
      ),
    );
  } on InternalCallException catch (e) {
    return apiError(502, 'placement_unavailable', e.message);
  }
}
