/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:notification_service/src/domain/notification_rules.dart';

/// Gửi thông báo đẩy, lỗi không ảnh hưởng hộp thông báo
// ignore: one_member_abstracts
abstract interface class PushSender {
  Future<void> send(NewNotification notification);
}

/// Chưa có khóa Firebase thì chỉ ghi log
class LogPushSender implements PushSender {
  const LogPushSender();

  @override
  Future<void> send(NewNotification notification) async {
    stdout.writeln(
      'FCM chưa cấu hình, bỏ qua đẩy ${notification.kind} '
      'tới ${notification.recipient}',
    );
  }
}
