/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:attendance_service/src/data/clock_repository.dart';
import 'package:attendance_service/src/data/overtime_repository.dart';
import 'package:attendance_service/src/domain/clock.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/clock.dart' as clock;
import '../../routes/overtime-requests/[id]/decision.dart' as decision;
import '../../routes/overtime-requests/index.dart' as overtime;

class _MockContext extends Mock implements RequestContext {}

class _MockClock extends Mock implements ClockRepository {}

class _MockOvertime extends Mock implements OvertimeRepository {}

Claims _claims(List<String> roles, {String? employeeId = 'E1'}) => Claims({
  'preferred_username': 'nv1',
  'employee_id': ?employeeId,
  'realm_access': {'roles': roles},
});

void main() {
  late _MockContext context;
  late _MockClock clockRepository;
  late _MockOvertime overtimeRepository;

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() {
    context = _MockContext();
    clockRepository = _MockClock();
    overtimeRepository = _MockOvertime();
    when(() => context.read<ClockRepository>()).thenReturn(clockRepository);
    when(
      () => context.read<OvertimeRepository>(),
    ).thenReturn(overtimeRepository);
  });

  void request(String method, String path, Claims claims, [Object? body]) {
    when(() => context.request).thenReturn(
      Request(
        method,
        Uri.parse('http://localhost$path'),
        body: body == null ? null : jsonEncode(body),
      ),
    );
    when(() => context.read<Claims>()).thenReturn(claims);
  }

  group('tính giờ công', () {
    test('ca ngắn không trừ nghỉ trưa', () {
      final h = splitHours(const Duration(hours: 4, minutes: 30));
      expect(h, (work: 4.5, overtime: 0.0, total: 4.5));
    });

    test('làm quá 8 tiếng mà chưa có đơn tăng ca duyệt thì không tính', () {
      // 07:45 → 17:30 = 9 giờ 45 phút, trừ nghỉ trưa còn 8,75 giờ.
      final h = splitHours(const Duration(hours: 9, minutes: 45));
      expect(h, (work: 8.0, overtime: 0.0, total: 8.0));
    });

    test('có đơn tăng ca duyệt thì tính phần làm thêm', () {
      final h = splitHours(
        const Duration(hours: 9, minutes: 45),
        approvedOvertime: 2,
      );
      expect(h, (work: 8.0, overtime: 0.75, total: 8.75));
    });

    test('tăng ca chỉ tính tới số giờ đã duyệt', () {
      // 07:30 → 20:30 = 13 giờ, trừ nghỉ trưa còn 12 giờ: làm thêm 4 giờ.
      final h = splitHours(const Duration(hours: 13), approvedOvertime: 2);
      expect(h, (work: 8.0, overtime: 2.0, total: 10.0));
    });
  });

  test('không có ca hôm nay thì báo rõ và không ghi (R32)', () async {
    when(() => clockRepository.clock('E1')).thenThrow(
      const ClockRuleViolation('no_shift', 'No shift'),
    );
    request('POST', '/clock', _claims(['employee']));
    final response = await clock.onRequest(context);
    expect(response.statusCode, 409);
    expect((await response.json() as Map)['code'], 'no_shift');
  });

  test('chấm công trả lượt vào ca', () async {
    when(() => clockRepository.clock('E1')).thenAnswer(
      (_) async => {'action': 'checkIn', 'checkIn': '07:58'},
    );
    request('POST', '/clock', _claims(['employee']));
    final response = await clock.onRequest(context);
    expect(response.statusCode, 201);
    expect((await response.json() as Map)['action'], 'checkIn');
  });

  test('tài khoản chưa gắn nhân viên không chấm công được', () async {
    request('POST', '/clock', _claims(['admin'], employeeId: null));
    expect((await clock.onRequest(context)).statusCode, 403);
    verifyNever(() => clockRepository.clock(any()));
  });

  test('xin tăng ca quá 12 tiếng thì 400', () async {
    request('POST', '/overtime-requests', _claims(['employee']), {
      'workDate': '2026-10-20',
      'hours': 13,
    });
    final body = await (await overtime.onRequest(context)).json() as Map;
    expect(body['code'], 'invalid_hours');
  });

  test('gửi đơn tăng ca của chính mình', () async {
    when(
      () => overtimeRepository.create(
        employeeId: 'E1',
        workDate: DateTime(2026, 10, 20),
        hours: 2,
        reason: 'Đổ bê tông',
      ),
    ).thenAnswer((_) async => {'id': 'O1', 'status': 'pending'});
    request('POST', '/overtime-requests', _claims(['employee']), {
      'workDate': '2026-10-20',
      'hours': 2,
      'reason': 'Đổ bê tông',
    });
    expect((await overtime.onRequest(context)).statusCode, 201);
  });

  test('nhân viên không duyệt được đơn tăng ca', () async {
    request('POST', '/overtime-requests/O1/decision', _claims(['employee']), {
      'approve': true,
    });
    expect((await decision.onRequest(context, 'O1')).statusCode, 403);
  });

  test('HR tự duyệt đơn của mình thì 403', () async {
    when(
      () => overtimeRepository.decide(
        'O1',
        approve: true,
        decidedBy: 'nv1',
        deciderEmployeeId: 'E1',
      ),
    ).thenThrow(const LeaveRuleViolation('self_approval', 'own request'));
    request('POST', '/overtime-requests/O1/decision', _claims(['hr']), {
      'approve': true,
    });
    expect((await decision.onRequest(context, 'O1')).statusCode, 403);
  });
}
