/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:notification_service/src/data/notification_repository.dart';
import 'package:notification_service/src/domain/notification_rules.dart';
import 'package:notification_service/src/push_sender.dart';

/// Lấy các sự kiện của khu vực có id lớn hơn `after` từ sổ audit ở Hub.
typedef HubReader = Future<List<HubEvent>> Function(int after);

/// Đọc dòng sự kiện ở Hub như một consumer: nhớ đã đọc tới đâu, đọc lại
/// không sinh thông báo trùng (khóa event_id + người nhận).
class EventConsumer {
  EventConsumer({
    required this.repository,
    required this.read,
    required this.push,
  });

  final NotificationRepository repository;
  final HubReader read;
  final PushSender push;
  bool _running = false;
  bool _again = false;

  /// RabbitMQ báo có sự kiện mới thì đọc ngay, không chờ lượt định kỳ
  Future<void> kick() async {
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    try {
      do {
        _again = false;
        final n = await consumeOnce();
        if (n > 0) stdout.writeln('Đã đọc $n sự kiện từ Hub (RabbitMQ báo)');
      } while (_again);
    } on Object catch (e) {
      stderr.writeln('Đọc sự kiện ở Hub lỗi: $e');
    } finally {
      _running = false;
    }
  }

  /// Xử lý một lô; trả số sự kiện đã đọc.
  Future<int> consumeOnce() async {
    final events = await read(await repository.checkpoint());
    if (events.isEmpty) return 0;

    final added = await repository.saveBatch(
      [
        // Không có mã sự kiện thì không chống trùng được, bỏ qua cho an toàn.
        for (final e in events)
          if (e.eventId case final eventId?)
            for (final n in notificationsFor(e))
              (eventId: eventId, at: e.occurredAt, notification: n),
      ],
      lastEventId: events.last.id,
    );
    // Thông báo đẩy chỉ là phụ: lỗi gửi không làm mất thông báo trong hộp.
    for (final n in added) {
      try {
        await push.send(n);
      } on Exception catch (e) {
        stderr.writeln('Không gửi được thông báo đẩy: $e');
      }
    }
    return events.length;
  }

  /// Chạy nền; Hub lỗi thì chờ lâu dần (tối đa 1 phút). Có RabbitMQ báo
  /// thì [idle] để dài, lượt định kỳ chỉ là dự phòng.
  void start({Duration idle = const Duration(seconds: 5)}) {
    var failures = 0;
    Future<void> loop() async {
      while (true) {
        var wait = idle.inSeconds;
        if (!_running) {
          _running = true;
          try {
            final n = await consumeOnce();
            if (n > 0) stdout.writeln('Đã đọc $n sự kiện từ Hub');
            failures = 0;
            if (n > 0) wait = 1;
            // Bắt cả lỗi dữ liệu (không chỉ Exception) để bộ đọc không chết.
          } on Object catch (e) {
            failures++;
            wait = min(60, 5 << min(failures, 4));
            stderr.writeln('Đọc sự kiện ở Hub lỗi, thử lại sau ${wait}s: $e');
          } finally {
            _running = false;
          }
        }
        await Future<void>.delayed(Duration(seconds: wait));
      }
    }

    unawaited(loop());
  }
}

/// Đọc qua HTTP từ service audit ở Hub, kèm `X-Sync-Token`.
HubReader httpHubReader(
  Uri events, {
  required String region,
  required String token,
}) {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  return (after) async {
    final url = events.replace(
      queryParameters: {'region': region, 'after': '$after', 'limit': '200'},
    );
    final request = await client.getUrl(url)
      ..headers.set('x-sync-token', token);
    final response = await request.close().timeout(const Duration(seconds: 15));
    final body = await utf8.decodeStream(response);
    if (response.statusCode != 200) {
      throw HttpException('Hub audit trả ${response.statusCode}', uri: url);
    }
    return [
      for (final e
          in (jsonDecode(body) as Map<String, dynamic>)['items'] as List)
        HubEvent.fromJson(e as Map<String, dynamic>),
    ];
  };
}
