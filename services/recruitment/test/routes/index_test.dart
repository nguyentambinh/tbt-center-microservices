/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  test('GET / trả về trạng thái ok', () async {
    final response = route.onRequest(_MockRequestContext());
    expect(response.statusCode, equals(HttpStatus.ok));
    expect(
      await response.json(),
      equals({
        'service': 'recruitment',
        'status': 'ok',
        'circuits': {'claude': 'closed'},
      }),
    );
  });
}
