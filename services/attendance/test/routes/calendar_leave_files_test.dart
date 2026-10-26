/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';

import 'package:attendance_service/src/data/calendar_repository.dart';
import 'package:attendance_service/src/domain/clock.dart';
import 'package:attendance_service/src/leave_files.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/leave-requests/[id]/files/index.dart' as files;
import '../../routes/timesheets/stats.dart' as stats;

class _MockContext extends Mock implements RequestContext {}

class _MockCalendar extends Mock implements CalendarRepository {}

class _MockFiles extends Mock implements LeaveFileRepository {}

Claims _claims(List<String> roles, {String? employee = 'E1'}) => Claims({
  'sub': 'sub-1',
  'preferred_username': 'tester',
  'employee_id': ?employee,
  'realm_access': {'roles': roles},
});

void main() {
  late _MockContext context;

  setUp(() => context = _MockContext());

  void request(String method, String path, Claims claims, {Object? body}) {
    when(() => context.request).thenReturn(
      Request(
        method,
        Uri.parse('http://localhost$path'),
        body: body == null ? null : jsonEncode(body),
      ),
    );
    when(() => context.read<Claims>()).thenReturn(claims);
  }

  group('chấm công theo giờ ca', () {
    test('vào ca được tới đúng giờ kết thúc ca', () {
      expect(canCheckIn('08:05:00', '17:00:00'), isTrue);
      expect(canCheckIn('17:00:00', '17:00:00'), isTrue);
    });

    test('qua giờ kết thúc ca thì không vào ca nữa', () {
      expect(canCheckIn('17:00:01', '17:00:00'), isFalse);
      expect(canCheckIn('22:30:00', '17:00:00'), isFalse);
    });
  });

  group('tần suất chấm công', () {
    late _MockCalendar calendar;

    setUp(() {
      calendar = _MockCalendar();
      when(() => context.read<CalendarRepository>()).thenReturn(calendar);
      when(
        () => calendar.stats(
          from: any(named: 'from'),
          to: any(named: 'to'),
          employeeId: any(named: 'employeeId'),
        ),
      ).thenAnswer(
        (_) async => {
          'byWeekday': [5, 5, 4, 5, 5, 1, 0],
          'lateDays': 2,
        },
      );
    });

    test('HR không truyền nhân viên thì xem cả khu vực', () async {
      request('GET', '/timesheets/stats?months=6', _claims(['hr']));
      final body = await (await stats.onRequest(context)).json() as Map;
      expect(body['months'], 6);
      verify(
        () => calendar.stats(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).called(1);
    });

    test('nhân viên chỉ xem của mình, xem người khác thì 403', () async {
      request('GET', '/timesheets/stats', _claims(['employee']));
      final body = await (await stats.onRequest(context)).json() as Map;
      expect(body['employeeId'], 'E1');

      request('GET', '/timesheets/stats?employee=E2', _claims(['employee']));
      expect((await stats.onRequest(context)).statusCode, 403);
    });
  });

  group('minh chứng đơn nghỉ', () {
    late _MockFiles repository;

    setUp(() {
      repository = _MockFiles();
      when(() => context.read<LeaveFileRepository>()).thenReturn(repository);
      when(() => context.read<ObjectStore?>()).thenReturn(null);
      when(() => repository.leave('L1')).thenAnswer(
        (_) async => {'employeeId': 'E1', 'leaveType': 'sick'},
      );
      when(() => repository.files('L1')).thenAnswer((_) async => []);
    });

    test('đồng nghiệp không xem được minh chứng của người khác', () async {
      request(
        'GET',
        '/leave-requests/L1/files',
        _claims(['employee'], employee: 'E2'),
      );
      expect((await files.onRequest(context, 'L1')).statusCode, 403);
    });

    test('HR xem được minh chứng để đối chiếu', () async {
      request(
        'GET',
        '/leave-requests/L1/files',
        _claims(['hr'], employee: 'H1'),
      );
      final response = await files.onRequest(context, 'L1');
      expect(response.statusCode, 200);
    });

    test('HR không thêm tệp vào đơn của người khác', () async {
      request(
        'POST',
        '/leave-requests/L1/files',
        _claims(['hr'], employee: 'H1'),
        body: {'objectKey': 'leaves/L1/x.pdf', 'fileName': 'x.pdf'},
      );
      expect((await files.onRequest(context, 'L1')).statusCode, 403);
    });
  });

  test('nhận diện loại tệp theo byte đầu, không theo đuôi', () {
    expect(sniffMimeType('%PDF-1.7'.codeUnits), 'application/pdf');
    expect(sniffMimeType([0xFF, 0xD8, 0xFF, 0xE0]), 'image/jpeg');
    expect(sniffMimeType([0x89, 0x50, 0x4E, 0x47]), 'image/png');
    expect(sniffMimeType([0x50, 0x4B, 0x03, 0x04]), contains('wordprocessing'));
    expect(sniffMimeType('MZ executable'.codeUnits), isNull);
  });
}
