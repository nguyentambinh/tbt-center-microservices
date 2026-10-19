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

/// GET /notifications?limit=  hộp thông báo của mình, kèm số chưa đọc.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final claims = context.read<Claims>();
  final limitText = context.request.uri.queryParameters['limit'] ?? '';
  final limit = (int.tryParse(limitText) ?? 50).clamp(1, 200);

  final recipients = await context.read<RecipientResolver>().of(claims);
  final inbox = await context.read<NotificationRepository>().inbox(
    recipients,
    userSub: claims.subject,
    limit: limit,
  );
  return Response.json(body: {'items': inbox.items, 'unread': inbox.unread});
}
