/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/change_request_repository.dart';
import 'package:hr_service/src/data/employee_repository.dart';
import 'package:hr_service/src/domain/employee.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/change-requests/[id]/decision.dart' as decision_route;
import '../../routes/me/change-requests.dart' as mine_route;
import '../../routes/me/index.dart' as me_route;

class _MockContext extends Mock implements RequestContext {}

class _MockEmployees extends Mock implements EmployeeRepository {}

class _MockRequests extends Mock implements ChangeRequestRepository {}

Claims _claims({
  String? employeeId = 'E1',
  List<String> roles = const ['employee'],
}) => Claims({
  'sub': 'u1',
  'employee_id': ?employeeId,
  'realm_access': {'roles': roles},
});

void main() {
  late _MockContext context;
  late _MockEmployees employees;
  late _MockRequests requests;

  setUp(() {
    context = _MockContext();
    employees = _MockEmployees();
    requests = _MockRequests();
    when(() => context.read<EmployeeRepository>()).thenReturn(employees);
    when(() => context.read<ChangeRequestRepository>()).thenReturn(requests);
  });

  void request(String method, String path, {Object? body, Claims? claims}) {
    when(() => context.request).thenReturn(
      Request(
        method,
        Uri.parse('http://localhost$path'),
        body: body == null ? null : jsonEncode(body),
      ),
    );
    when(() => context.read<Claims>()).thenReturn(claims ?? _claims());
  }

  test('GET /me trả hồ sơ của chính mình', () async {
    when(() => employees.find('E1')).thenAnswer(
      (_) async => const EmployeeDetail(
        summary: EmployeeSummary(
          id: 'E1',
          familyName: 'Nguyễn',
          givenName: 'An',
        ),
        work: {},
      ),
    );
    request('GET', '/me');
    final response = await me_route.onRequest(context);
    expect(response.statusCode, HttpStatus.ok);
    expect(await response.json(), containsPair('id', 'E1'));
  });

  test('tài khoản chưa gắn nhân viên thì 403', () async {
    request('GET', '/me', claims: _claims(employeeId: null));
    expect(
      (await me_route.onRequest(context)).statusCode,
      HttpStatus.forbidden,
    );
  });

  test('gửi đề xuất sửa số điện thoại thì 201', () async {
    when(() => requests.create('E1', {'phone': '0901'}, reason: 'Đổi số'))
        .thenAnswer(
          (_) async => {'id': 1, 'status': 'pending'},
        );
    request(
      'POST',
      '/me/change-requests',
      body: {
        'changes': {'phone': '0901'},
        'reason': 'Đổi số',
      },
    );
    final response = await mine_route.onRequest(context);
    expect(response.statusCode, HttpStatus.created);
  });

  test('đã có đề xuất đang chờ thì 409', () async {
    when(() => requests.create(any(), any(), reason: any(named: 'reason')))
        .thenThrow(
          const ChangeRequestViolation('pending_exists', 'waiting'),
        );
    request(
      'POST',
      '/me/change-requests',
      body: {
        'changes': {'phone': '0901'},
      },
    );
    expect(
      (await mine_route.onRequest(context)).statusCode,
      HttpStatus.conflict,
    );
  });

  test('HR duyệt đề xuất', () async {
    when(() => requests.decide(7, approve: true, decidedBy: 'H1')).thenAnswer(
      (_) async => {'id': 7, 'status': 'approved'},
    );
    request(
      'POST',
      '/change-requests/7/decision',
      body: {'approve': true},
      claims: _claims(employeeId: 'H1', roles: ['hr']),
    );
    final response = await decision_route.onRequest(context, '7');
    expect(response.statusCode, HttpStatus.ok);
    expect(await response.json(), containsPair('status', 'approved'));
  });

  test('đề xuất đã xử lý thì 409, không có đề xuất thì 404', () async {
    when(() => requests.decide(8, approve: false, decidedBy: 'H1', note: 'Sai'))
        .thenThrow(
          const ChangeRequestViolation('already_decided', 'done'),
        );
    request(
      'POST',
      '/change-requests/8/decision',
      body: {'approve': false, 'note': 'Sai'},
      claims: _claims(employeeId: 'H1', roles: ['hr']),
    );
    expect(
      (await decision_route.onRequest(context, '8')).statusCode,
      HttpStatus.conflict,
    );

    when(() => requests.decide(9, approve: true, decidedBy: 'H1'))
        .thenAnswer((_) async => null);
    request(
      'POST',
      '/change-requests/9/decision',
      body: {'approve': true},
      claims: _claims(employeeId: 'H1', roles: ['hr']),
    );
    expect(
      (await decision_route.onRequest(context, '9')).statusCode,
      HttpStatus.notFound,
    );
  });

  group('validateChanges', () {
    test('chỉ nhận trường cho phép, số đo đổi sang số nguyên', () {
      expect(validateChanges({'phone': ' 0901 ', 'heightCm': '170'}), {
        'phone': '0901',
        'heightCm': 170,
      });
    });

    test('trường không cho sửa, số đo âm, email sai đều bị từ chối', () {
      expect(
        () => validateChanges({'salary': 1}),
        throwsA(isA<ChangeRequestViolation>()),
      );
      expect(
        () => validateChanges({'weightKg': -3}),
        throwsA(isA<ChangeRequestViolation>()),
      );
      expect(
        () => validateChanges({'email': 'abc'}),
        throwsA(isA<ChangeRequestViolation>()),
      );
      expect(() => validateChanges({}), throwsA(isA<ChangeRequestViolation>()));
    });
  });
}
