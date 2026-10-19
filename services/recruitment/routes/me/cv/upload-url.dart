/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/storage/cv_storage.dart';
import 'package:tbt_common/tbt_common.dart';

final _random = Random.secure();

/// POST /me/cv/upload-url  cấp URL ký sẵn để app tải thẳng CV (PDF) lên kho
/// của khu vực, file không đi qua Kong hay service.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  final candidate = await context.read<CandidateRepository>().findBySubject(
    claims.subject,
  );
  if (candidate == null) {
    return apiError(409, 'not_applied', 'Submit your profile first');
  }
  // Đã vào phỏng vấn thì không đổi CV nữa, tránh đưa hồ sơ ngược về đầu.
  if (!editableStatuses.contains(candidate['status'])) {
    return apiError(409, 'profile_locked', 'CV can no longer be changed');
  }

  // Tên object ngẫu nhiên, nằm dưới thư mục của chính ứng viên.
  final suffix = List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  final key = 'cv/${candidate['id']}/$suffix.pdf';
  return Response.json(
    body: {
      'uploadUrl': context.read<CvStorage>().uploadUrl(key).toString(),
      'objectKey': key,
      'contentType': 'application/pdf',
      'maxBytes': maxCvBytes,
    },
  );
}
