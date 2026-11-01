/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-11-01
 */

import 'dart:convert';

import 'package:attendance_service/src/data/work_config.dart';
import 'package:attendance_service/src/domain/clock.dart';
import 'package:attendance_service/src/region_time.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/schedules/index.dart' as route;

class _MockContext extends Mock implements RequestContext {}

class _MockConfig extends Mock implements WorkConfig {}

void main() {
  group('khung giờ chấm công', () {
    test('chấm vào mở trước ca 30 phút, không lùi qua nửa đêm', () {
      expect(clockInFrom('08:00:00'), '07:30');
      expect(clockInFrom('00:10:00'), '00:00');
      expect(isBefore('07:29:59', clockInFrom('08:00:00')), isTrue);
      expect(isBefore('07:30:00', clockInFrom('08:00:00')), isFalse);
    });

    test('chấm ra tới 30 phút sau ca, cộng tăng ca đã duyệt', () {
      expect(clockOutUntil('17:00:00', 0), '17:30');
      expect(clockOutUntil('17:00:00', 2), '19:30');
      expect(clockOutUntil('23:50:00', 0), '23:59');
      expect(isAfter('17:30:59', clockOutUntil('17:00:00', 0)), isFalse);
      expect(isAfter('17:31:00', clockOutUntil('17:00:00', 0)), isTrue);
    });
  });

  group('PUT /schedules', () {
    late _MockConfig config;

    RequestContext contextFor(List<String> roles, Map<String, dynamic> body) {
      final context = _MockContext();
      when(() => context.request).thenReturn(
        Request.put(
          Uri.parse('http://localhost/schedules'),
          body: jsonEncode(body),
          headers: {'content-type': 'application/json'},
        ),
      );
      when(() => context.read<Claims>()).thenReturn(
        Claims({
          'preferred_username': 'hr.vn',
          'realm_access': {'roles': roles},
        }),
      );
      when(() => context.read<WorkConfig>()).thenReturn(config);
      when(() => context.read<RegionClock?>()).thenReturn(null);
      return context;
    }

    const body = {
      'employeeIds': ['E1', 'E1', 'E2'],
      'from': '2026-11-02',
      'to': '2026-11-06',
      'weekdays': [1, 2, 3, 4, 5],
      'start': '08:00',
      'end': '17:00',
    };

    setUp(() {
      config = _MockConfig();
      registerFallbackValue(DateTime(2026));
    });

    test('nhân viên không đặt được lịch', () async {
      final response = await route.onRequest(contextFor(['employee'], body));
      expect(response.statusCode, 403);
    });

    test('HR đặt lịch, mã nhân viên trùng chỉ tính một lần', () async {
      when(
        () => config.setSchedules(
          employeeIds: any(named: 'employeeIds'),
          from: any(named: 'from'),
          to: any(named: 'to'),
          today: any(named: 'today'),
          weekdays: any(named: 'weekdays'),
          start: any(named: 'start'),
          end: any(named: 'end'),
          by: any(named: 'by'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((i) async {
        expect(i.namedArguments[#employeeIds], ['E1', 'E2']);
        return 10;
      });
      final response = await route.onRequest(contextFor(['hr'], body));
      expect(response.statusCode, 200);
      expect((await response.json() as Map)['schedules'], 10);
    });
  });
}
