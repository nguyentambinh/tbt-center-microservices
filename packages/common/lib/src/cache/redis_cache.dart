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
import 'dart:typed_data';

/// Kho key-value cho cache; tách interface để test không cần Redis
abstract interface class CacheStore {
  Future<String?> get(String key);

  Future<void> set(String key, String value, Duration ttl);

  Future<int> incr(String key);
}

/// Client Redis tối giản (giao thức RESP), chỉ GET, SET EX, INCR
class RedisCache implements CacheStore {
  RedisCache(this.host, {this.port = 6379});

  /// null khi không cấu hình REDIS_HOST
  static RedisCache? fromEnvironment() {
    final host = Platform.environment['REDIS_HOST'];
    if (host == null || host.isEmpty) return null;
    return RedisCache(
      host,
      port: int.tryParse(Platform.environment['REDIS_PORT'] ?? '') ?? 6379,
    );
  }

  final String host;
  final int port;
  static const _timeout = Duration(milliseconds: 300);

  Socket? _socket;
  // Lỗi thì nghỉ 10 giây, request không phải chờ timeout mỗi lần
  DateTime _downUntil = DateTime(2000);
  final _buffer = BytesBuilder();
  Completer<void>? _data;
  // Mỗi lần chỉ một lệnh trên socket, lệnh sau chờ lệnh trước
  Future<void> _queue = Future.value();

  @override
  Future<String?> get(String key) async {
    final reply = await _command(['GET', key]);
    return reply as String?;
  }

  @override
  Future<void> set(String key, String value, Duration ttl) async {
    await _command(['SET', key, value, 'EX', '${ttl.inSeconds}']);
  }

  @override
  Future<int> incr(String key) async => (await _command(['INCR', key]))! as int;

  Future<Object?> _command(List<String> args) {
    final result = _queue.then((_) => _send(args));
    _queue = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  Future<Object?> _send(List<String> args) async {
    if (DateTime.now().isBefore(_downUntil)) {
      throw const RedisError('tạm nghỉ sau lỗi');
    }
    try {
      final socket = _socket ??= await _connect();
      final out = BytesBuilder()..add(utf8.encode('*${args.length}\r\n'));
      for (final arg in args) {
        final bytes = utf8.encode(arg);
        out
          ..add(utf8.encode('\$${bytes.length}\r\n'))
          ..add(bytes)
          ..add(const [13, 10]);
      }
      socket.add(out.takeBytes());
      return await _read().timeout(_timeout);
    } on Object {
      // Lỗi thì bỏ kết nối, lần sau mở lại
      _socket?.destroy();
      _socket = null;
      _buffer.clear();
      _downUntil = DateTime.now().add(const Duration(seconds: 10));
      rethrow;
    }
  }

  Future<Socket> _connect() async {
    final socket = await Socket.connect(host, port, timeout: _timeout);
    socket.listen(
      (chunk) {
        _buffer.add(chunk);
        _data?.complete();
        _data = null;
      },
      onError: (Object _) => _socket = null,
      onDone: () => _socket = null,
      cancelOnError: true,
    );
    return socket;
  }

  Future<Object?> _read() async {
    while (true) {
      final parsed = parseResp(_buffer.toBytes());
      if (parsed != null) {
        final rest = _buffer.takeBytes().sublist(parsed.length);
        _buffer.add(rest);
        if (parsed.value is RedisError) throw parsed.value! as RedisError;
        return parsed.value;
      }
      await (_data ??= Completer<void>()).future;
    }
  }
}

class RedisError implements Exception {
  const RedisError(this.message);

  final String message;

  @override
  String toString() => 'Redis: $message';
}

/// Đọc một câu trả lời RESP; null nếu chưa nhận đủ byte
({Object? value, int length})? parseResp(Uint8List bytes) {
  final end = _lineEnd(bytes, 0);
  if (end < 0) return null;
  final line = utf8.decode(bytes.sublist(1, end));
  final next = end + 2;
  switch (bytes[0]) {
    case 0x2b: // +OK
      return (value: line, length: next);
    case 0x2d: // -ERR
      return (value: RedisError(line), length: next);
    case 0x3a: // :số
      return (value: int.parse(line), length: next);
    case 0x24: // $chuỗi
      final size = int.parse(line);
      if (size < 0) return (value: null, length: next);
      if (bytes.length < next + size + 2) return null;
      return (
        value: utf8.decode(bytes.sublist(next, next + size)),
        length: next + size + 2,
      );
    default:
      throw RedisError('Không đọc được kiểu ${bytes[0]}');
  }
}

int _lineEnd(Uint8List bytes, int from) {
  for (var i = from; i < bytes.length - 1; i++) {
    if (bytes[i] == 13 && bytes[i + 1] == 10) return i;
  }
  return -1;
}
