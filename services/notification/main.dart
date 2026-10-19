/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:notification_service/src/dependencies.dart';

/// Chạy bộ đọc sự kiện nền rồi mới mở HTTP server.
Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  final bus = eventBus;
  eventConsumer.start(
    idle: bus == null
        ? const Duration(seconds: 5)
        : const Duration(seconds: 60),
  );
  // Hàng đợi riêng của khu vực, chỉ nhận sự kiện của khu vực mình
  bus?.subscribe('notification.$region', [
    '$region.#',
  ], (_, _) => eventConsumer.kick());
  return serve(handler, ip, port);
}
