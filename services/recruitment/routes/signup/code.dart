/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/identity/signup.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /signup/code (qua Kong: /recruitment/public/signup/code)  {email, fullName, phone, language}
/// gửi mã 6 số về email; chưa cần đăng nhập
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  try {
    await context.read<Signup>().sendCode(
      email: body['email'],
      fullName: body['fullName'],
      phone: body['phone'],
      language: body['language'] as String? ?? 'en',
    );
    return Response.json(body: {'sent': true});
  } on SignupViolation catch (e) {
    return apiError(e.statusCode, e.code, e.message);
  }
}
