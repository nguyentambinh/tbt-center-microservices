/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

String _token(Map<String, dynamic> payload) {
  String part(Map<String, dynamic> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return 'Bearer ${part({'alg': 'RS256'})}.${part(payload)}.sig';
}

final _hrVn = _token({
  'preferred_username': 'hr.vn',
  'region': 'vn',
  'realm_access': {
    'roles': ['hr', 'employee'],
  },
});

class _MockContext extends Mock implements RequestContext {}

/// Chạy middleware với một request giả; handler bên trong trả về username
/// của Claims mà middleware đã gắn vào context.
Future<Response> _call(Middleware middleware, {String? authorization}) async {
  final context = _MockContext();
  Claims? provided;
  when(() => context.request).thenReturn(
    Request.get(
      Uri.parse('http://localhost/employees'),
      headers: {'authorization': ?authorization},
    ),
  );
  when(() => context.provide<Claims>(any())).thenAnswer((invocation) {
    final create = invocation.positionalArguments.first as Claims Function();
    provided = create();
    return context;
  });

  final handler = middleware((_) => Response(body: provided?.username ?? ''));
  return handler(context);
}

void main() {
  setUpAll(() => registerFallbackValue(() => Claims(const {})));

  test('đọc vai trò và khu vực từ token', () {
    final claims = Claims.fromAuthorization(_hrVn)!;
    expect(claims.username, 'hr.vn');
    expect(claims.region, 'vn');
    expect(claims.hasAnyRole({'hr'}), isTrue);
    expect(claims.hasAnyRole({'admin'}), isFalse);
  });

  test('header sai dạng thì không có claims', () {
    expect(Claims.fromAuthorization(null), isNull);
    expect(Claims.fromAuthorization('Basic abc'), isNull);
    expect(Claims.fromAuthorization('Bearer abc'), isNull);
  });

  group('requireClaims', () {
    final middleware = requireClaims(anyRole: {'hr'}, region: 'vn');

    test('không có token thì 401', () async {
      expect((await _call(middleware)).statusCode, 401);
    });

    test('khác khu vực thì 403 region_mismatch', () async {
      final response = await _call(
        requireClaims(anyRole: {'hr'}, region: 'de'),
        authorization: _hrVn,
      );
      expect(response.statusCode, 403);
      expect((await response.json() as Map)['code'], 'region_mismatch');
    });

    test('vai trò cấp tập đoàn gọi được khu vực khác', () async {
      final response = await _call(
        requireClaims(region: 'de', anyRegionRoles: {'hr'}),
        authorization: _hrVn,
      );
      expect(response.statusCode, 200);
    });

    test('tài khoản cấp tập đoàn (vai trò group) vào mọi khu vực, executive nước khác thì không', () async {
      final groupHr = _token({
        'preferred_username': 'hr.group',
        'region': 'vn',
        'realm_access': {
          'roles': ['hr', 'group'],
        },
      });
      final executiveVn = _token({
        'preferred_username': 'executive.vn',
        'region': 'vn',
        'realm_access': {
          'roles': ['executive'],
        },
      });
      final guard = requireClaims(anyRole: {'hr', 'executive'}, region: 'de');
      expect((await _call(guard, authorization: groupHr)).statusCode, 200);
      expect((await _call(guard, authorization: executiveVn)).statusCode, 403);
    });

    test('không đủ vai trò thì 403 forbidden', () async {
      final response = await _call(
        requireClaims(anyRole: {'finance'}),
        authorization: _hrVn,
      );
      expect((await response.json() as Map)['code'], 'forbidden');
    });

    test('đúng vai trò, đúng khu vực thì đi tiếp và có Claims', () async {
      final response = await _call(middleware, authorization: _hrVn);
      expect(response.statusCode, 200);
      expect(await response.body(), 'hr.vn');
    });
  });
}
