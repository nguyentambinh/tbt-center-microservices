/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// Lỗi do dữ liệu gửi lên thì 400, sai luồng tuyển dụng thì 409
Response violationResponse(CandidateRuleViolation e) => apiError(
  e.code.startsWith('use_') ||
          e.code.startsWith('time_') ||
          e.code.startsWith('invalid_file')
      ? 400
      : 409,
  e.code,
  e.message,
);

/// Body JSON dạng object, sai thì null
Future<Map<String, dynamic>?> jsonObject(RequestContext context) async {
  try {
    final body = await context.request.json();
    return body is Map<String, dynamic> ? body : null;
  } on Object {
    return null;
  }
}

/// Giờ ISO 8601 có múi giờ; sai định dạng thì null
DateTime? parseTime(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toUtc() : null;
