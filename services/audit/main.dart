/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:io';

import 'package:audit_service/src/dependencies.dart';
import 'package:dart_frog/dart_frog.dart';

/// Bật bộ phát sự kiện lên RabbitMQ rồi mới mở HTTP server
Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  eventRelay?.start();
  return serve(handler, ip, port);
}
