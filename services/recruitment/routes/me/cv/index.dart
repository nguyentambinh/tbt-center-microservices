/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:crypto/crypto.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/storage/cv_storage.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /me/cv  {"objectKey": "..."}  báo đã tải CV xong. Service tự đọc lại
/// file để kiểm tra đúng PDF, đúng dung lượng, rồi lưu mã băm SHA-256.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  final repository = context.read<CandidateRepository>();
  final candidate = await repository.findBySubject(claims.subject);
  if (candidate == null) {
    return apiError(409, 'not_applied', 'Submit your profile first');
  }
  // Đã vào phỏng vấn thì không đổi CV nữa, tránh đưa hồ sơ ngược về đầu.
  if (!editableStatuses.contains(candidate['status'])) {
    return apiError(409, 'profile_locked', 'CV can no longer be changed');
  }

  final Object? key;
  try {
    key = (await context.request.json() as Map<String, dynamic>)['objectKey'];
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be {"objectKey": "..."}');
  }
  // Chỉ nhận file nằm trong thư mục của chính ứng viên này.
  if (key is! String || !key.startsWith('cv/${candidate['id']}/')) {
    return apiError(400, 'invalid_object', 'Unknown CV object');
  }

  final List<int>? bytes;
  try {
    bytes = await context.read<CvStorage>().read(key);
  } on Exception {
    return apiError(413, 'cv_too_large', 'CV must be at most 10 MB');
  }
  if (bytes == null) {
    return apiError(400, 'cv_missing', 'CV was not uploaded');
  }
  // File PDF luôn bắt đầu bằng "%PDF".
  if (bytes.length < 4 || String.fromCharCodes(bytes.take(4)) != '%PDF') {
    return apiError(415, 'cv_not_pdf', 'CV must be a PDF file');
  }

  final updated = await repository.attachCv(
    claims.subject,
    objectKey: key,
    sha256: sha256.convert(bytes).toString(),
  );
  // HR đã xem hồ sơ thì không đổi CV được nữa
  if (updated == null) {
    return apiError(409, 'profile_locked', 'Profile was reviewed by HR');
  }
  return Response.json(body: updated);
}
