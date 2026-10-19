/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/core/error/app_failure.dart';
import 'package:tbtcenter/features/attendance/domain/entities/attendance.dart';
import 'package:tbtcenter/features/attendance/domain/entities/work_time.dart';
import 'package:tbtcenter/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:tbtcenter/features/attendance/domain/repositories/work_time_repository.dart';
import 'package:tbtcenter/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:tbtcenter/l10n/app_localizations_vi.dart';

import 'helpers.dart';

final _pending = LeaveRequest(
  id: 'L1',
  employeeId: 'Anh8715OP',
  fromDate: DateTime(2026, 12, 28),
  toDate: DateTime(2026, 12, 30),
  days: 3,
  leaveType: 'Nghỉ phép năm',
  status: LeaveStatus.pending,
);

class FakeAttendanceRepository implements AttendanceRepository {
  final decisions = <String, bool>{};

  @override
  Future<Timesheet> timesheet({required DateTime from, required DateTime to}) async => Timesheet(
        employeeId: 'E1',
        totalHours: 17.5,
        days: [
          TimesheetDay(date: DateTime(2026, 10, 1), checkIn: '08:00', checkOut: '17:30', totalHours: 9.5, overtimeHours: 1.5),
          TimesheetDay(date: DateTime(2026, 10, 2), checkIn: '08:00', checkOut: '17:00', totalHours: 8),
        ],
      );

  @override
  Future<List<LeaveRequest>> leaveRequests({bool pendingOnly = false}) async =>
      decisions.containsKey('L1') && pendingOnly ? [] : [_pending];

  @override
  Future<LeaveRequest> requestLeave({
    required DateTime fromDate,
    required DateTime toDate,
    required String leaveType,
    String? reason,
  }) async =>
      throw const AppFailure(FailureKind.validation, serverCode: 'overlap');

  @override
  Future<LeaveRequest> decide(String id, {required bool approve}) async {
    decisions[id] = approve;
    return _pending;
  }
}

/// Giả lập server chấm công: lượt đầu vào ca, lượt sau ra ca.
class FakeWorkTimeRepository implements WorkTimeRepository {
  FakeWorkTimeRepository({this.hasShift = true});

  final bool hasShift;
  String? checkIn;
  String? checkOut;
  final decisions = <String, bool>{};

  final _pendingOvertime = OvertimeRequest(
    id: 'O1',
    employeeId: 'NHU00192SG',
    workDate: DateTime(2026, 10, 16),
    hours: 2.5,
    status: LeaveStatus.pending,
    reason: 'Đổ bê tông sàn tầng 3',
  );

  @override
  Future<ClockToday> today() async => ClockToday(
        workDate: DateTime(2026, 10, 15),
        hasShift: hasShift,
        shiftNote: hasShift ? 'Thi công công trình' : null,
        coefficient: 1,
        checkIn: checkIn,
        checkOut: checkOut,
        totalHours: checkOut == null ? null : 8.75,
      );

  @override
  Future<ClockPunch> clock() async {
    if (checkIn == null) {
      checkIn = '07:45';
      return const ClockPunch(checkedIn: true, time: '07:45');
    }
    checkOut = '17:30';
    return const ClockPunch(checkedIn: false, time: '17:30', totalHours: 8.75, overtimeHours: 0.75);
  }

  @override
  Future<List<OvertimeRequest>> overtimeRequests({bool pendingOnly = false}) async =>
      pendingOnly && decisions.isNotEmpty ? [] : [_pendingOvertime];

  @override
  Future<OvertimeRequest> requestOvertime({required DateTime workDate, required double hours, String? reason}) async =>
      throw const AppFailure(FailureKind.validation, serverCode: 'overlap');

  @override
  Future<OvertimeRequest> decideOvertime(String id, {required bool approve}) async {
    decisions[id] = approve;
    return _pendingOvertime;
  }
}

Future<FakeAttendanceRepository> pumpAttendance(
  WidgetTester tester,
  List<String> roles, {
  FakeWorkTimeRepository? workTime,
}) async {
  final repository = FakeAttendanceRepository();
  final overrides = await testOverrides(
    language: 'vi',
    store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles))),
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...overrides,
      attendanceRepositoryProvider.overrideWithValue(repository),
      workTimeRepositoryProvider.overrideWithValue(workTime ?? FakeWorkTimeRepository()),
    ],
    child: const TbtApp(),
  ));
  await tester.pumpAndSettle();
  await openHomeCard(tester, 'Chấm công & nghỉ phép');
  return repository;
}

void main() {
  testWidgets('nhân viên xem chấm công, có tăng ca, không có tab duyệt', (tester) async {
    await pumpAttendance(tester, ['employee']);
    expect(find.text('Tổng 17,5 giờ trong 2 ngày'), findsOneWidget);
    expect(find.text('Vào 08:00 · Ra 17:30'), findsOneWidget);
    expect(find.text('Tăng ca 1,5 giờ'), findsOneWidget);
    expect(find.text('Duyệt đơn'), findsNothing);

    await tester.tap(find.text('Nghỉ phép'));
    await tester.pumpAndSettle();
    expect(find.text('Chờ duyệt'), findsOneWidget);
    expect(find.text('Xin nghỉ'), findsOneWidget);
  });

  testWidgets('HR duyệt đơn nghỉ và đơn tăng ca đang chờ', (tester) async {
    final workTime = FakeWorkTimeRepository();
    final repository = await pumpAttendance(tester, ['hr'], workTime: workTime);
    await tester.tap(find.text('Duyệt đơn'));
    await tester.pumpAndSettle();
    expect(find.text('Anh8715OP'), findsOneWidget);
    expect(find.text('Đổ bê tông sàn tầng 3'), findsOneWidget);

    await tester.tap(find.text('Duyệt').first);
    await tester.pumpAndSettle();
    expect(repository.decisions, {'L1': true});
    await tester.tap(find.text('Duyệt'));
    await tester.pumpAndSettle();
    expect(workTime.decisions, {'O1': true});
    expect(find.text('Không có đơn nào chờ duyệt'), findsOneWidget);
  });

  testWidgets('một nút chấm công: lần đầu vào ca, lần hai ra ca và hiện tổng giờ', (tester) async {
    await pumpAttendance(tester, ['employee']);
    expect(find.text('Thi công công trình'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Vào ca'));
    await tester.pumpAndSettle();
    expect(find.text('Đã vào ca lúc 07:45'), findsOneWidget);
    expect(find.text('Vào 07:45 · Ra --:--'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Ra ca'));
    await tester.pumpAndSettle();
    expect(find.text('Đã ra ca lúc 17:30, làm 8,75 giờ'), findsOneWidget);
    expect(find.text('Hôm nay làm 8,75 giờ'), findsOneWidget);
    final done = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Đã xong ca hôm nay'));
    expect(done.onPressed, isNull);
  });

  testWidgets('không có ca thì báo rõ và không cho bấm chấm công', (tester) async {
    await pumpAttendance(tester, ['employee'], workTime: FakeWorkTimeRepository(hasShift: false));
    expect(find.text('Hôm nay bạn không có ca làm việc, không chấm công được'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Vào ca'));
    expect(button.onPressed, isNull);
  });

  testWidgets('ứng viên không thấy thẻ chấm công', (tester) async {
    final overrides = await testOverrides(
      language: 'vi',
      store: MemorySessionStore(fakeSession(token: fakeJwt(roles: ['candidate']))),
    );
    await tester.pumpWidget(ProviderScope(overrides: overrides, child: const TbtApp()));
    await tester.pumpAndSettle();
    expect(find.text('Chấm công & nghỉ phép'), findsNothing);
  });

  test('mã lỗi nghiệp vụ từ server đổi thành câu báo tiếng Việt', () {
    final l10n = AppLocalizationsVi();
    expect(const AppFailure(FailureKind.validation, serverCode: 'overlap').message(l10n),
        'Khoảng thời gian này trùng với một đơn nghỉ khác');
    expect(const AppFailure(FailureKind.forbidden, serverCode: 'self_approval').message(l10n),
        'Bạn không thể tự duyệt đơn của mình');
    expect(const AppFailure(FailureKind.server).message(l10n), 'Máy chủ đang gặp sự cố, vui lòng thử lại sau.');
  });
}
