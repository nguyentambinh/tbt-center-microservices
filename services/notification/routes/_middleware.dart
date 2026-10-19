/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:notification_service/src/data/notification_repository.dart';
import 'package:notification_service/src/dependencies.dart';
import 'package:notification_service/src/recipients.dart';
import 'package:tbt_common/tbt_common.dart';

/// Ai đăng nhập cũng có hộp thông báo, kể cả ứng viên chưa có khu vực.
Handler middleware(Handler handler) {
  final protected = handler
      .use(idempotency(database))
      .use(
        requireClaims(
          region: Platform.environment['REGION'],
          allowNoRegion: true,
        ),
      );

  return ((RequestContext context) {
        if (context.request.uri.path == '/') return handler(context);
        return protected(context);
      })
      .use(provider<NotificationRepository>((_) => notificationRepository))
      .use(provider<RecipientResolver>((_) => recipientResolver))
      .use(correlationAndErrors())
      .use(metrics('notification'))
      .use(serviceRegistry('notification'));
}
