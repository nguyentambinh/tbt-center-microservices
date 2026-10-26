/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /me  hồ sơ và tiến trình của chính ứng viên (404 nếu chưa nộp).
/// PUT /me  nộp hồ sơ lần đầu hoặc sửa hồ sơ.
Future<Response> onRequest(RequestContext context) async {
  final claims = context.read<Claims>();
  final repository = context.read<CandidateRepository>();

  switch (context.request.method) {
    case HttpMethod.get:
      final profile = await repository.findBySubject(claims.subject);
      if (profile == null) {
        return apiError(404, 'not_applied', 'No application yet');
      }
      return Response.json(body: profile);

    case HttpMethod.put:
      final Map<String, dynamic> body;
      try {
        body = await context.request.json() as Map<String, dynamic>;
      } on Object {
        return apiError(400, 'invalid_json', 'Body must be a JSON object');
      }
      // Tài khoản đã xác nhận email: thông tin cá nhân lấy từ lúc đăng ký
      final fullName =
          (claims.fullName ?? body['fullName'] as String?)?.trim() ?? '';
      if (fullName.isEmpty) {
        return apiError(400, 'invalid_name', 'fullName required');
      }
      try {
        await repository.saveOwnProfile(
          claims.subject,
          // Hồ sơ thuộc nước của khu vực nhận, không theo token.
          Platform.environment['COUNTRY_CODE'] ?? 'VN',
          CandidateProfileInput(
            fullName: fullName,
            email: (claims.email ?? body['email'] as String?)?.trim(),
            phone: (claims.phone ?? body['phone'] as String?)?.trim(),
            appliedPosition: (body['appliedPosition'] as String?)?.trim(),
            consentAi: body['consentAi'] == true,
            positionIds: switch (body['positionIds']) {
              final List<dynamic> ids => [
                for (final id in ids)
                  if (int.tryParse('$id') case final n?) n,
              ],
              _ => null,
            },
          ),
        );
      } on CandidateRuleViolation catch (e) {
        return apiError(409, e.code, e.message);
      }
      final profile = await repository.findBySubject(claims.subject);
      return Response.json(body: profile);

    case HttpMethod.post ||
        HttpMethod.patch ||
        HttpMethod.delete ||
        HttpMethod.head ||
        HttpMethod.options:
      return apiError(405, 'method_not_allowed', 'GET, PUT only');
  }
}
