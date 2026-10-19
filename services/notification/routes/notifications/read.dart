/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:notification_service/src/data/notification_repository.dart';
import 'package:notification_service/src/recipients.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /notifications/read  {"ids": ["..."]}  hoặc {} để đánh dấu đọc hết.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final List<String> ids;
  try {
    final text = await context.request.body();
    final body = text.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(text) as Map<String, dynamic>;
    ids = [for (final id in body['ids'] as List? ?? const []) id as String];
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be {"ids": [...]}');
  }

  final claims = context.read<Claims>();
  await context.read<NotificationRepository>().markRead(
    await context.read<RecipientResolver>().of(claims),
    userSub: claims.subject,
    ids: ids,
  );
  return Response.json(body: {'ok': true});
}
