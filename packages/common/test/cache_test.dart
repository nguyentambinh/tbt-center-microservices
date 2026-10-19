/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

class _MockContext extends Mock implements RequestContext {}

/// Redis giả trong bộ nhớ
class _MemoryStore implements CacheStore {
  final data = <String, String>{};
  bool broken = false;

  @override
  Future<String?> get(String key) async {
    if (broken) throw const RedisError('down');
    return data[key];
  }

  @override
  Future<void> set(String key, String value, Duration ttl) async =>
      data[key] = value;

  @override
  Future<int> incr(String key) async {
    final next = int.parse(data[key] ?? '0') + 1;
    data[key] = '$next';
    return next;
  }
}

void main() {
  late _MemoryStore store;
  late int calls;
  late Handler handler;

  setUp(() {
    store = _MemoryStore();
    calls = 0;
    handler = cachedGet(store, namespace: 'hr')((_) {
      calls++;
      return Response.json(body: {'lan': calls});
    });
  });

  Future<Response> get(String path) {
    final context = _MockContext();
    when(() => context.request)
        .thenReturn(Request.get(Uri.parse('http://localhost$path')));
    return Future.value(handler(context));
  }

  test('lần đầu MISS gọi service, lần sau HIT lấy từ cache', () async {
    final first = await get('/employees?page=1');
    final second = await get('/employees?page=1');
    expect(first.headers['x-cache'], 'MISS');
    expect(second.headers['x-cache'], 'HIT');
    expect(await second.json(), {'lan': 1});
    expect(calls, 1);
  });

  test('query khác là key khác', () async {
    await get('/employees?page=1');
    await get('/employees?page=2');
    expect(calls, 2);
  });

  test('invalidateCache thì lần sau đọc lại từ service', () async {
    await get('/employees');
    await invalidateCache(store, 'hr');
    final after = await get('/employees');
    expect(after.headers['x-cache'], 'MISS');
    expect(calls, 2);
  });

  test('Redis hỏng thì vẫn trả dữ liệu, không lỗi', () async {
    store.broken = true;
    final response = await get('/employees');
    expect(response.statusCode, 200);
    expect(calls, 1);
  });

  group('đọc RESP', () {
    Uint8List b(String s) => Uint8List.fromList(utf8.encode(s));

    test('chuỗi, số, null, OK', () {
      expect(parseResp(b('\$5\r\nhello\r\n'))?.value, 'hello');
      expect(parseResp(b(':42\r\n'))?.value, 42);
      expect(parseResp(b('\$-1\r\n'))?.value, isNull);
      expect(parseResp(b('+OK\r\n'))?.value, 'OK');
    });

    test('chưa đủ byte thì chờ thêm', () {
      expect(parseResp(b('\$5\r\nhel')), isNull);
      expect(parseResp(b(':4')), isNull);
    });

    test('lỗi từ Redis', () {
      expect(parseResp(b('-ERR sai\r\n'))?.value, isA<RedisError>());
    });
  });
}
