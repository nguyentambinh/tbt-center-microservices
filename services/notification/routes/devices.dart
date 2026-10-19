/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:notification_service/src/data/notification_repository.dart';
import 'package:notification_service/src/recipients.dart';
import 'package:tbt_common/tbt_common.dart';

const _languages = {'vi', 'en', 'de', 'pt'};

/// POST /devices {"token", "language"}: lưu mã FCM; DELETE /devices: gỡ
Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  if (method != HttpMethod.post && method != HttpMethod.delete) {
    return apiError(405, 'method_not_allowed', 'POST or DELETE only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be {"token": "..."}');
  }
  final token = body['token'];
  if (token is! String || token.isEmpty || token.length > 4096) {
    return apiError(400, 'invalid_token', 'token is required');
  }
  final repository = context.read<NotificationRepository>();
  if (method == HttpMethod.delete) {
    await repository.removeDevice(token);
    return Response.json(body: {'ok': true});
  }

  final claims = context.read<Claims>();
  final language = body['language'];
  await repository.registerDevice(
    token,
    userSub: claims.subject,
    recipients: await context.read<RecipientResolver>().of(claims),
    language: _languages.contains(language) ? language as String : 'en',
  );
  return Response.json(statusCode: 201, body: {'ok': true});
}
