/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/interviews.dart';
import 'package:recruitment_service/src/responses.dart';
import 'package:recruitment_service/src/storage/cv_storage.dart';
import 'package:tbt_common/tbt_common.dart';

/// Word, Excel mới là tệp zip; bản cũ (.doc, .xls) là tệp OLE
bool looksLikeOffice(List<int> bytes) {
  if (bytes.length < 4) return false;
  final zip = bytes[0] == 0x50 && bytes[1] == 0x4B;
  final ole = bytes[0] == 0xD0 && bytes[1] == 0xCF && bytes[2] == 0x11;
  return zip || ole;
}

/// GET: URL tạm mở biên bản. POST {objectKey, fileName}: báo đã tải xong,
/// hồ sơ chuyển sang "đã phỏng vấn"
Future<Response> onRequest(RequestContext context, String id) async {
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(recruiterRoles)) {
    return apiError(403, 'forbidden', 'HR only');
  }
  final interviews = context.read<InterviewRepository>();
  final storage = context.read<CvStorage>();
  if (context.request.method == HttpMethod.get) {
    final found = await interviews.minutes(id);
    if (found == null) {
      return apiError(404, 'no_minutes', 'No interview minutes yet');
    }
    return Response.json(
      body: {
        'downloadUrl': storage.downloadUrl(found.key).toString(),
        'fileName': found.name,
      },
    );
  }
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'GET or POST');
  }

  final body = await jsonObject(context);
  final key = body?['objectKey'];
  final name = body?['fileName'];
  if (key is! String || !key.startsWith('minutes/$id/') || name is! String) {
    return apiError(400, 'invalid_object', 'Unknown minutes object');
  }
  final List<int>? bytes;
  try {
    bytes = await storage.read(key);
  } on Exception {
    return apiError(413, 'file_too_large', 'Minutes must be at most 10 MB');
  }
  if (bytes == null) {
    return apiError(400, 'file_missing', 'Minutes were not uploaded');
  }
  if (!looksLikeOffice(bytes)) {
    return apiError(415, 'invalid_file', 'Minutes must be Word or Excel');
  }
  try {
    final candidate = await interviews.attachMinutes(
      id,
      objectKey: key,
      fileName: name.trim(),
      by: claims.username,
    );
    if (candidate == null) {
      return apiError(404, 'not_found', 'Candidate $id not found');
    }
    return Response.json(body: candidate);
  } on CandidateRuleViolation catch (e) {
    return violationResponse(e);
  }
}
