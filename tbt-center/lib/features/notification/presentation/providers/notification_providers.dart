/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/config/env.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return NotificationRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

/// Chưa có Firebase nên chưa có thông báo đẩy: app tự hỏi lại mỗi 30 giây
/// khi đang mở màn có chuông thông báo.
const inboxRefreshEvery = Duration(seconds: 30);

final inboxProvider = FutureProvider.autoDispose<Inbox>((ref) {
  final timer = Timer(inboxRefreshEvery, ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return ref.watch(notificationRepositoryProvider).inbox();
});
