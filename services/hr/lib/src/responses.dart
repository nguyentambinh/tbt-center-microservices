/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// Lỗi nghiệp vụ phòng ban → mã HTTP
Response violationResponse(OrganizationViolation e) {
  final status = switch (e.code) {
    'not_found' => HttpStatus.notFound,
    'invalid_reason' ||
    'invalid_raise' ||
    'unknown_company' ||
    'invalid_body' => HttpStatus.badRequest,
    _ => HttpStatus.conflict,
  };
  return apiError(status, e.code, e.message);
}

Response methodNotAllowed(String allowed) =>
    apiError(HttpStatus.methodNotAllowed, 'method_not_allowed', allowed);

Response badBody(String message) =>
    apiError(HttpStatus.badRequest, 'invalid_body', message);

Future<Map<String, dynamic>> jsonBody(RequestContext context) async {
  final body = await context.request.body();
  if (body.trim().isEmpty) return {};
  return Map<String, dynamic>.from(await context.request.json() as Map);
}

String actor(RequestContext context) {
  final claims = context.read<Claims>();
  return claims.employeeId ?? claims.subject;
}
