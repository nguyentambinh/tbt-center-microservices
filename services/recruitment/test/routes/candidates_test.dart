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
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/candidates/[id]/status.dart' as status_route;
import '../../routes/candidates/index.dart' as list_route;
import '../../routes/me/index.dart' as me_route;

class _MockContext extends Mock implements RequestContext {}

class _MockRepository extends Mock implements CandidateRepository {}

Claims _claims(List<String> roles) => Claims({
  'sub': 'sub-1',
  'preferred_username': 'tester',
  'realm_access': {'roles': roles},
});

void main() {
  late _MockContext context;
  late _MockRepository repository;

  setUpAll(
    () => registerFallbackValue(const CandidateProfileInput(fullName: 'x')),
  );

  setUp(() {
    context = _MockContext();
    repository = _MockRepository();
    when(() => context.read<CandidateRepository>()).thenReturn(repository);
  });

  void request(String method, String path, {Object? body, Claims? claims}) {
    when(() => context.request).thenReturn(
      Request(
        method,
        Uri.parse('http://localhost$path'),
        body: body == null ? null : jsonEncode(body),
      ),
    );
    when(
      () => context.read<Claims>(),
    ).thenReturn(claims ?? _claims(['candidate']));
  }

  test('chưa nộp hồ sơ thì GET /me trả 404 not_applied', () async {
    request('GET', '/me');
    when(() => repository.findBySubject('sub-1')).thenAnswer((_) async => null);
    final response = await me_route.onRequest(context);
    expect((await response.json() as Map)['code'], 'not_applied');
  });

  test('PUT /me thiếu họ tên thì 400', () async {
    request('PUT', '/me', body: {'fullName': '  '});
    final response = await me_route.onRequest(context);
    expect(response.statusCode, 400);
  });

  test('hồ sơ đã khóa thì PUT /me trả 409 profile_locked', () async {
    request('PUT', '/me', body: {'fullName': 'Lê Minh Thư'});
    when(
      () => repository.saveOwnProfile(any(), any(), any()),
    ).thenThrow(const CandidateRuleViolation('profile_locked', 'x'));
    final response = await me_route.onRequest(context);
    expect(response.statusCode, 409);
  });

  test('ứng viên không xem được danh sách ứng viên', () async {
    request('GET', '/candidates');
    final response = await list_route.onRequest(context);
    expect(response.statusCode, 403);
  });

  test('HR chuyển bước không hợp lệ thì 400', () async {
    request(
      'POST',
      '/candidates/C1/status',
      body: {'status': 'promoted'},
      claims: _claims(['hr']),
    );
    final response = await status_route.onRequest(context, 'C1');
    expect((await response.json() as Map)['code'], 'invalid_status');
  });

  test('HR chuyển sang phỏng vấn', () async {
    request(
      'POST',
      '/candidates/C1/status',
      body: {'status': 'interview', 'note': 'Hẹn 20/10'},
      claims: _claims(['hr']),
    );
    when(
      () => repository.changeStatus(
        'C1',
        status: 'interview',
        changedBy: 'tester',
        note: 'Hẹn 20/10',
      ),
    ).thenAnswer((_) async => {'id': 'C1', 'status': 'interview'});
    final response = await status_route.onRequest(context, 'C1');
    expect((await response.json() as Map)['status'], 'interview');
  });
  test('không chuyển thẳng sang hired qua /status', () async {
    request(
      'POST',
      '/candidates/x/status',
      body: {'status': 'hired'},
      claims: _claims(['hr']),
    );
    final response = await status_route.onRequest(context, 'x');
    expect((await response.json() as Map)['code'], 'use_hire');
  });
}
