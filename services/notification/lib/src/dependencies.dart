/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:notification_service/src/data/notification_repository.dart';
import 'package:notification_service/src/event_consumer.dart';
import 'package:notification_service/src/fcm_sender.dart';
import 'package:notification_service/src/push_sender.dart';
import 'package:notification_service/src/recipients.dart';
import 'package:tbt_common/tbt_common.dart';

final _env = Platform.environment;

final database = Database.fromEnvironment();
final notificationRepository = PostgresNotificationRepository(database);

final recipientResolver = RecipientResolver(
  recruitmentLookup(
    InternalClient(
      'recruitment',
      Uri.parse(_env['RECRUITMENT_URL'] ?? 'http://recruitment:8080'),
    ),
  ),
);

final region = _env['REGION'] ?? 'vn';

/// Báo có sự kiện mới qua RabbitMQ; không cấu hình thì chỉ đọc định kỳ
final eventBus = RabbitEventBus.fromEnvironment();

final eventConsumer = EventConsumer(
  repository: notificationRepository,
  read: httpHubReader(
    Uri.parse(_env['HUB_AUDIT_URL'] ?? 'http://localhost:8195/events'),
    region: region,
    token: _env['SYNC_TOKEN'] ?? '',
  ),
  push:
      FcmPushSender.fromFile(
        _env['FCM_SERVICE_ACCOUNT'],
        notificationRepository,
      ) ??
      const LogPushSender(),
);
