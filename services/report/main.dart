/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:report_service/src/dependencies.dart';
import 'package:tbt_common/tbt_common.dart';

/// Tạo bảng đọc trong Doris rồi chạy bộ chiếu nền. Doris chưa sẵn sàng thì
/// thử lại sau, service vẫn mở HTTP để báo trạng thái.
Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  unawaited(_startProjection());
  return serve(handler, ip, port);
}

Future<void> _startProjection() async {
  for (var attempt = 1; ; attempt++) {
    try {
      await ensureReportSchema();
      final bus = RabbitEventBus.fromEnvironment();
      // Có RabbitMQ thì chiếu ngay khi có sự kiện, lượt định kỳ chỉ dự phòng
      projector.start(
        every: bus == null
            ? const Duration(seconds: 10)
            : const Duration(seconds: 60),
      );
      bus?.subscribe('report.projector', [
        '#',
      ], (_, _) async => projector.kick());
      stdout.writeln('Đã sẵn sàng chiếu sự kiện audit vào Doris');
      return;
    } on Exception catch (e) {
      stderr.writeln('Doris chưa sẵn sàng (lần $attempt): $e');
      await Future<void>.delayed(const Duration(seconds: 10));
    }
  }
}
