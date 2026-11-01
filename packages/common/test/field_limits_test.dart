/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-11-01
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

class _MockContext extends Mock implements RequestContext {}

Future<Response> _post(String path, Map<String, dynamic> body) async {
  final context = _MockContext();
  when(() => context.request).thenReturn(
    Request.post(
      Uri.parse('http://localhost$path'),
      body: jsonEncode(body),
      headers: {'content-type': 'application/json'},
    ),
  );
  final handler = correlationAndErrors()((_) => Response(body: 'ok'));
  return handler(context);
}

void main() {
  test('chuỗi quá dài trả 422 kèm tên trường', () async {
    final response = await _post('/candidates', {'phone': '0' * 21});
    expect(response.statusCode, 422);
    expect((await response.json() as Map)['code'], 'field_too_long');
  });

  test('trường lồng trong danh sách vẫn bị kiểm', () async {
    final response = await _post('/x', {
      'items': [
        {'note': 'a' * 4001},
      ],
    });
    expect(response.statusCode, 422);
  });

  test('đúng giới hạn thì đi tiếp, body vẫn đọc lại được', () async {
    final context = _MockContext();
    when(() => context.request).thenReturn(
      Request.post(
        Uri.parse('http://localhost/x'),
        body: jsonEncode({'email': 'a' * 120}),
        headers: {'content-type': 'application/json'},
      ),
    );
    final handler = correlationAndErrors()((c) async {
      final body = await c.request.json() as Map;
      return Response(body: '${(body['email'] as String).length}');
    });
    expect(await (await handler(context)).body(), '120');
  });

  test('đường nội bộ và nhập tệp không giới hạn', () async {
    expect((await _post('/internal/x', {'note': 'a' * 5000})).statusCode, 200);
    expect((await _post('/candidate-imports', {'file': 'a' * 5000})).statusCode, 200);
  });
}
