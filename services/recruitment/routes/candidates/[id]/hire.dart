/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/identity/hiring.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /candidates/{id}/hire: nhận vào làm
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(recruiterRoles)) {
    return apiError(403, 'forbidden', 'HR only');
  }

  HireOffer? offer;
  try {
    final body = await context.request.body();
    if (body.trim().isNotEmpty) {
      final json = jsonDecode(body) as Map<String, dynamic>;
      offer = (
        departmentId: json['departmentId'] as String?,
        baseSalary: (json['baseSalary'] as num?)?.toDouble(),
        currency: (json['currency'] as String?)?.toUpperCase(),
        employmentType: json['employmentType'] as String? ?? 'FT',
      );
    }
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }

  try {
    final result = await context.read<Hiring>().hire(
      id,
      hiredBy: claims.username,
      offer: offer,
    );
    if (result == null) {
      return apiError(404, 'not_found', 'Candidate $id not found');
    }
    return Response.json(
      body: {
        'candidate': result.candidate,
        'employeeId': result.employeeId,
        'login': result.login,
        'temporaryPassword': ?result.temporaryPassword,
        'salarySet': result.salarySet,
      },
    );
  } on HiringRuleViolation catch (e) {
    return apiError(e.statusCode, e.code, e.message);
  } on InternalCallException catch (e) {
    return apiError(502, 'hr_unavailable', e.message);
  }
}
