/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dart_amqp/dart_amqp.dart';

/// Exchange chung của mọi sự kiện nghiệp vụ, kiểu topic
const eventsExchange = 'tbt.events';

/// Khóa định tuyến `<khu vực>.<service>.<loại sự kiện>`, ví dụ
/// `vn.attendance.LeaveApproved`; consumer chọn bằng mẫu như `vn.#`
String routingKeyFor(String region, String service, String eventType) =>
    [region, service, eventType].map(_segment).join('.');

String _segment(String s) =>
    s.isEmpty ? 'unknown' : s.replaceAll(RegExp('[^A-Za-z0-9_-]'), '_');

typedef BusMessage = ({String routingKey, Map<String, dynamic> body});

typedef EventHandler = Future<void> Function(
  String routingKey,
  Map<String, dynamic> body,
);

abstract interface class EventBus {
  /// Gửi cả lô, chỉ trả về khi RabbitMQ xác nhận đã nhận hết (publisher confirm)
  Future<void> publishAll(List<BusMessage> messages);

  /// Nhận sự kiện qua hàng đợi bền [queue]; RabbitMQ mất thì tự nối lại
  void subscribe(String queue, List<String> bindings, EventHandler onEvent);

  Future<void> close();
}

class RabbitEventBus implements EventBus {
  RabbitEventBus(this._settings);

  /// null khi không cấu hình RABBITMQ_HOST
  static RabbitEventBus? fromEnvironment([Map<String, String>? env]) {
    final e = env ?? Platform.environment;
    final host = e['RABBITMQ_HOST'];
    if (host == null || host.isEmpty) return null;
    return RabbitEventBus(
      ConnectionSettings(
        host: host,
        port: int.tryParse(e['RABBITMQ_PORT'] ?? '') ?? 5672,
        authProvider: PlainAuthenticator(
          e['RABBITMQ_DEFAULT_USER'] ?? 'guest',
          e['RABBITMQ_DEFAULT_PASS'] ?? 'guest',
        ),
        connectTimeout: const Duration(seconds: 5),
        connectionName: e['SERVICE_NAME'],
      ),
    );
  }

  final ConnectionSettings _settings;
  Client? _publisher;
  Exchange? _exchange;
  final _confirms = StreamController<bool>.broadcast();
  final _subscribers = <Client>[];
  var _closed = false;

  Future<Exchange> _publishExchange() async {
    if (_exchange case final exchange?) return exchange;
    final client = Client(settings: _settings);
    client.errorListener((_) => _resetPublisher());
    final channel = await client.channel();
    await channel.confirmPublishedMessages();
    channel.publishNotifier((n) => _confirms.add(n.published));
    final exchange = await channel.exchange(
      eventsExchange,
      ExchangeType.TOPIC,
      durable: true,
    );
    _publisher = client;
    return _exchange = exchange;
  }

  // Đóng ở lượt sau: đóng ngay trong lúc thư viện đang báo lỗi làm nó hỏng
  void _resetPublisher() {
    final client = _publisher;
    _publisher = null;
    _exchange = null;
    if (client != null) {
      scheduleMicrotask(() => unawaited(client.close().catchError((_) {})));
    }
  }

  @override
  Future<void> publishAll(List<BusMessage> messages) {
    if (messages.isEmpty) return Future.value();
    return _guarded(() async {
      try {
        final exchange = await _publishExchange();
        // Gửi từng tin, đợi xác nhận rồi mới gửi tin sau: dart_amqp 0.3.1
        // hỏng khi RabbitMQ xác nhận gộp nhiều tin một lần
        for (final m in messages) {
          final ack = _confirms.stream.first;
          exchange.publish(
            jsonEncode(m.body),
            m.routingKey,
            properties: MessageProperties.persistentMessage()
              ..contentType = 'application/json',
          );
          if (!await ack.timeout(const Duration(seconds: 5))) {
            throw const SocketException('RabbitMQ từ chối sự kiện');
          }
        }
      } on Object {
        _resetPublisher();
        rethrow;
      }
    }, onCrash: _resetPublisher);
  }

  @override
  void subscribe(String queue, List<String> bindings, EventHandler onEvent) {
    var failures = 0;
    Future<void> run() async {
      while (!_closed) {
        final lost = Completer<void>();
        void markLost() {
          if (!lost.isCompleted) lost.complete();
        }

        Client? client;
        try {
          await _guarded(() async {
            final c = client = Client(settings: _settings);
            c.errorListener((_) => markLost());
            final channel = await c.channel();
            // Mỗi lần nhận tối đa 20 sự kiện chưa xác nhận
            await channel.qos(0, 20);
            final exchange = await channel.exchange(
              eventsExchange,
              ExchangeType.TOPIC,
              durable: true,
            );
            final q = await channel.queue(queue, durable: true);
            for (final key in bindings) {
              await q.bind(exchange, key);
            }
            // Mặc định dart_amqp tự xác nhận; ack thêm lần nữa làm kênh bị đóng
            final consumer = await q.consume(noAck: false);
            _subscribers.add(c);
            failures = 0;
            stdout.writeln('Đã nghe hàng đợi $queue (${bindings.join(', ')})');
            consumer.listen((message) async {
              try {
                await onEvent(
                  message.routingKey ?? '',
                  message.payloadAsJson as Map<String, dynamic>,
                );
              } on Object catch (e) {
                stderr.writeln('Xử lý sự kiện ${message.routingKey} lỗi: $e');
              }
              // Bên nhận luôn đọc lại sổ gốc, nên lỗi một tin không cần gửi lại
              message.ack();
            });
          }, onCrash: markLost);
          await lost.future;
        } on Object catch (e) {
          stderr.writeln('RabbitMQ ($queue) lỗi: $e');
        }
        final c = client;
        if (c != null) {
          _subscribers.remove(c);
          await c.close().catchError((_) {});
        }
        if (_closed) break;
        failures++;
        await Future<void>.delayed(
          Duration(seconds: min(60, 2 << min(failures, 5))),
        );
      }
    }

    unawaited(run());
  }

  /// Chạy trong Zone có bắt lỗi: lỗi chưa xử lý của thư viện (kể cả về sau,
  /// trong luồng đọc socket) chỉ làm mất kết nối, không làm sập service
  Future<T> _guarded<T>(
    Future<T> Function() body, {
    required void Function() onCrash,
  }) {
    final done = Completer<T>();
    runZonedGuarded(
      () async {
        try {
          final value = await body();
          if (!done.isCompleted) done.complete(value);
        } on Object catch (e, st) {
          if (!done.isCompleted) done.completeError(e, st);
        }
      },
      (e, st) {
        stderr.writeln('RabbitMQ lỗi ngoài dự kiến, nối lại: $e');
        onCrash();
        if (!done.isCompleted) done.completeError(e, st);
      },
    );
    return done.future;
  }

  @override
  Future<void> close() async {
    _closed = true;
    _resetPublisher();
    for (final c in [..._subscribers]) {
      await c.close().catchError((_) {});
    }
  }
}
