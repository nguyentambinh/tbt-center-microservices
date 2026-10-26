/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<Inbox> inbox();

  /// Đánh dấu đã đọc mọi thông báo của mình.
  Future<void> markAllRead();

  /// Đánh dấu đã đọc các thông báo vừa mở
  Future<void> markRead(List<String> ids);
}
