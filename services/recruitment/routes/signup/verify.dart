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

/// POST /signup/verify (qua Kong: /recruitment/public/signup/verify)  {email, code, password}
/// đúng mã thì tạo tài khoản ứng viên, app chuyển sang đăng nhập
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
    await context.read<Signup>().verify(
      email: body['email'],
      code: body['code'],
      password: body['password'],
    );
    return Response.json(statusCode: 201, body: {'created': true});
  } on SignupViolation catch (e) {
    return apiError(e.statusCode, e.code, e.message);
  }
}
