/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:attendance_service/src/data/attendance_repository.dart';
import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/leave-requests/[id]/decision.dart' as decision_route;
import '../../routes/leave-requests/index.dart' as leave_route;
import '../../routes/timesheets/index.dart' as timesheet_route;

class _MockContext extends Mock implements RequestContext {}

class _MockRepository extends Mock implements AttendanceRepository {}

Claims _claims(List<String> roles, {String? employeeId = 'E1'}) => Claims({
  'preferred_username': 'tester',
  'employee_id': ?employeeId,
  'realm_access': {'roles': roles},
});

final _leave = LeaveRequest(
  id: 'L1',
  employeeId: 'E1',
  fromDate: DateTime(2026, 11, 2),
  toDate: DateTime(2026, 11, 4),
  leaveType: 'Nghỉ phép năm',
  status: 'pending',
);

void main() {
  late _MockContext context;
  late _MockRepository repository;

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() {
    context = _MockContext();
    repository = _MockRepository();
    when(() => context.read<AttendanceRepository>()).thenReturn(repository);
  });

  void request(String method, String path, {Object? body, Claims? claims}) {
    when(() => context.request).thenReturn(
      Request(
        method,
        Uri.parse('http://localhost$path'),
        body: body == null ? null : jsonEncode(body),
      ),
    );
    when(() => context.read<Claims>())
        .thenReturn(claims ?? _claims(['employee']));
  }

  group('validateLeave', () {
    test('ngày kết thúc trước ngày bắt đầu', () {
      final v = validateLeave(
        fromDate: DateTime(2026, 11, 5),
        toDate: DateTime(2026, 11, 4),
        leaveType: 'x',
      );
      expect(v?.code, 'invalid_dates');
    });

    test('quá 30 ngày', () {
      final v = validateLeave(
        fromDate: DateTime(2026, 11),
        toDate: DateTime(2026, 12, 5),
        leaveType: 'x',
      );
      expect(v?.code, 'too_long');
    });

    test('chỉ ngày tương lai: hôm nay hoặc ngày đã qua bị từ chối', () {
      final today = DateTime(2026, 10, 26, 15, 30);
      expect(
        validateLeave(
          fromDate: DateTime(2026, 10, 26),
          toDate: DateTime(2026, 10, 27),
          leaveType: 'Nghỉ phép',
          today: today,
        )?.code,
        'past_date',
      );
      expect(
        validateLeave(
          fromDate: DateTime(2026, 10, 27),
          toDate: DateTime(2026, 10, 27),
          leaveType: 'Nghỉ phép',
          today: today,
        ),
        isNull,
      );
    });

    test('hợp lệ', () {
      final v = validateLeave(
        fromDate: DateTime(2026, 11, 2),
        toDate: DateTime(2026, 11, 2),
        leaveType: 'Nghỉ ốm',
      );
      expect(v, isNull);
      expect(_leave.days, 3);
    });
  });

  group('POST /leave-requests', () {
    test('tạo đơn cho chính mình, trả 201', () async {
      request(
        'POST',
        '/leave-requests',
        body: {
          'fromDate': '2026-11-02',
          'toDate': '2026-11-04',
          'leaveType': 'Nghỉ phép năm',
        },
      );
      when(
        () => repository.createLeave(
          employeeId: 'E1',
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
          leaveType: 'Nghỉ phép năm',
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => _leave);

      final response = await leave_route.onRequest(context);
      expect(response.statusCode, 201);
      expect((await response.json() as Map)['days'], 3);
    });

    test('trùng ngày với đơn khác thì 409', () async {
      request(
        'POST',
        '/leave-requests',
        body: {
          'fromDate': '2026-11-02',
          'toDate': '2026-11-02',
          'leaveType': 'x',
        },
      );
      when(
        () => repository.createLeave(
          employeeId: any(named: 'employeeId'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
          leaveType: any(named: 'leaveType'),
          reason: any(named: 'reason'),
        ),
      ).thenThrow(const LeaveRuleViolation('overlap', 'x'));

      final response = await leave_route.onRequest(context);
      expect(response.statusCode, 409);
    });

    test('tài khoản chưa gắn nhân viên thì 403', () async {
      request(
        'POST',
        '/leave-requests',
        body: const {},
        claims: _claims(['employee'], employeeId: null),
      );
      final response = await leave_route.onRequest(context);
      expect((await response.json() as Map)['code'], 'no_employee');
    });
  });

  group('quyền xem', () {
    test('nhân viên xem chấm công người khác thì 403', () async {
      request('GET', '/timesheets?employee=E2');
      final response = await timesheet_route.onRequest(context);
      expect(response.statusCode, 403);
    });

    test('HR xem chấm công người khác được', () async {
      request('GET', '/timesheets?employee=E2', claims: _claims(['hr']));
      when(
        () => repository.timesheets(
          'E2',
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer(
        (_) async => [
          {'workDate': '2026-10-01', 'totalHours': 9.0},
        ],
      );
      final response = await timesheet_route.onRequest(context);
      expect((await response.json() as Map)['totalHours'], 9.0);
    });
  });

  group('POST /leave-requests/{id}/decision', () {
    test('nhân viên thường không duyệt được', () async {
      request('POST', '/leave-requests/L1/decision', body: {'approve': true});
      final response = await decision_route.onRequest(context, 'L1');
      expect(response.statusCode, 403);
    });

    test('HR duyệt đơn đang chờ', () async {
      request(
        'POST',
        '/leave-requests/L1/decision',
        body: {'approve': true},
        claims: _claims(['hr'], employeeId: 'HR9'),
      );
      when(
        () => repository.decide(
          'L1',
          approve: true,
          decidedBy: 'tester',
          deciderEmployeeId: 'HR9',
        ),
      ).thenAnswer((_) async => _leave);
      final response = await decision_route.onRequest(context, 'L1');
      expect(response.statusCode, 200);
    });

    test('tự duyệt đơn của mình thì 403', () async {
      request(
        'POST',
        '/leave-requests/L1/decision',
        body: {'approve': true},
        claims: _claims(['hr']),
      );
      when(
        () => repository.decide(
          any(),
          approve: any(named: 'approve'),
          decidedBy: any(named: 'decidedBy'),
          deciderEmployeeId: any(named: 'deciderEmployeeId'),
        ),
      ).thenThrow(const LeaveRuleViolation('self_approval', 'x'));
      final response = await decision_route.onRequest(context, 'L1');
      expect((await response.json() as Map)['code'], 'self_approval');
    });
  });
}
