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
import 'package:tbtcenter/features/attendance/domain/entities/work_calendar.dart';
import 'package:tbtcenter/features/attendance/domain/entities/work_time.dart';
import 'package:tbtcenter/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:tbtcenter/features/attendance/domain/repositories/work_time_repository.dart';
import 'package:tbtcenter/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:tbtcenter/features/payroll/domain/entities/payroll.dart';
import 'package:tbtcenter/features/payroll/presentation/providers/payroll_providers.dart';
import 'package:tbtcenter/features/project_contract/domain/entities/project.dart';
import 'package:tbtcenter/features/project_contract/presentation/providers/project_providers.dart';
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
  fileCount: 1,
  aiSummary: const {
    'summary': 'Giấy khám bệnh ghi nghỉ 3 ngày do sốt xuất huyết',
    'keyPoints': ['Bệnh viện quận 1', 'Nghỉ từ 28/12 tới 30/12'],
    'matchesRequest': true,
  },
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

  @override
  Future<List<CalendarDay>> calendar({required DateTime from, required DateTime to}) async => [
        for (var d = from; !d.isAfter(to); d = d.add(const Duration(days: 1)))
          d.day == 5
              ? CalendarDay(date: d, shiftStart: '08:00', shiftEnd: '17:00', checkIn: '08:00', checkOut: '17:30', workHours: 8, overtimeHours: 0.5, totalHours: 8.5)
              : CalendarDay(date: d),
      ];

  @override
  Future<ClockStats> stats({int months = 3}) async => ClockStats(
        byWeekday: const [20, 19, 21, 20, 18, 2, 0],
        byCheckInHour: [for (var h = 0; h < 24; h++) h == 7 ? 60 : (h == 8 ? 20 : 0)],
        byMonth: const [(month: '2026-10', days: 80, hours: 640, late: 6)],
        totalDays: 80,
        lateDays: 6,
      );

  @override
  Future<List<LeaveFile>> leaveFiles(String leaveId) async => const [LeaveFile(id: 'F1', fileName: 'giay-kham-benh.jpg', mimeType: 'image/jpeg')];

  final uploads = <String>[];

  @override
  Future<List<LeaveFile>> uploadLeaveFile(String leaveId, {required String fileName, required List<int> bytes, required String language}) async {
    uploads.add(fileName);
    return leaveFiles(leaveId);
  }
}

/// Giả lập server chấm công: lượt đầu vào ca, lượt sau ra ca.
class FakeWorkTimeRepository implements WorkTimeRepository {
  FakeWorkTimeRepository({this.hasShift = true, this.approvedOvertime = 0, this.pendingOvertime = 0});

  final bool hasShift;
  final double approvedOvertime;
  final double pendingOvertime;
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
        shiftStart: '08:00',
        shiftEnd: '17:00',
        approvedOvertime: approvedOvertime,
        pendingOvertime: pendingOvertime,
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
      myPayrollProvider.overrideWith((ref) async => const PayrollSummary(baseSalary: 20800000, currency: 'VND')),
      myProjectsProvider.overrideWith((ref) async => [MyProject(projectId: 'DA1', name: 'Cầu Rạch Chiếc', hours: 40, startDate: DateTime(2026), endDate: DateTime(2027))]),
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
    expect(find.textContaining('Thi công công trình'), findsOneWidget);

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

  testWidgets('tăng ca chỉ tính theo đơn đã duyệt: thẻ chấm công báo trước', (tester) async {
    await pumpAttendance(tester, ['employee'], workTime: FakeWorkTimeRepository(pendingOvertime: 2));
    expect(find.text('Đơn tăng ca 2 giờ đang chờ duyệt: chưa được tính cho tới khi duyệt'), findsOneWidget);
  });

  testWidgets('có đơn tăng ca đã duyệt thì báo giờ được tính tới', (tester) async {
    await pumpAttendance(tester, ['employee'], workTime: FakeWorkTimeRepository(approvedOvertime: 1.5));
    expect(find.text('Tăng ca đã duyệt 1,5 giờ: làm tới 18:30 vẫn được tính'), findsOneWidget);
  });

  testWidgets('không có ca thì báo rõ và không cho bấm chấm công', (tester) async {
    await pumpAttendance(tester, ['employee'], workTime: FakeWorkTimeRepository(hasShift: false));
    expect(find.text('Hôm nay bạn không có ca làm việc, không chấm công được'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Vào ca'));
    expect(button.onPressed, isNull);
  });

  testWidgets('HR thấy AI tóm tắt minh chứng và nút xem đơn gốc', (tester) async {
    await pumpAttendance(tester, ['hr']);
    await tester.tap(find.text('Duyệt đơn'));
    await tester.pumpAndSettle();
    expect(find.text('AI tóm tắt minh chứng'), findsOneWidget);
    expect(find.text('Khớp lý do nghỉ'), findsOneWidget);
    expect(find.text('• Bệnh viện quận 1'), findsOneWidget);
    await tester.tap(find.text('Xem đơn gốc (1)'));
    await tester.pumpAndSettle();
    expect(find.text('giay-kham-benh.jpg'), findsOneWidget);
  });

  testWidgets('người gửi thêm minh chứng cho đơn đang chờ, không thấy bản AI tóm tắt', (tester) async {
    await pumpAttendance(tester, ['employee']);
    await tester.tap(find.text('Nghỉ phép'));
    await tester.pumpAndSettle();
    expect(find.text('Thêm minh chứng'), findsOneWidget);
    expect(find.text('AI tóm tắt minh chứng'), findsNothing);
  });

  testWidgets('lịch làm việc: bấm ngày xem giờ vào ra, dự án, tiền ước tính', (tester) async {
    await pumpAttendance(tester, ['employee']);
    await tester.tap(find.byTooltip('Lịch làm việc'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    expect(find.text('Vào 08:00 · Ra 17:30'), findsOneWidget);
    expect(find.text('Cầu Rạch Chiếc'), findsOneWidget);
    // 20.800.000 / 26 / 8 = 100.000 đ/giờ: 8 giờ + 0,5 giờ × 150%
    expect(find.textContaining('875.000'), findsOneWidget);
  });

  testWidgets('biểu đồ chấm công của HR là cả khu vực', (tester) async {
    await pumpAttendance(tester, ['hr']);
    await tester.tap(find.byTooltip('Biểu đồ chấm công'));
    await tester.pumpAndSettle();
    expect(find.text('Cả khu vực'), findsOneWidget);
    expect(find.text('80'), findsWidgets);
    expect(find.text('6 · 8%'), findsOneWidget);
  });

  test('tiền một ngày: giờ thường + tăng ca 150%, nhân hệ số ngày lễ', () {
    final day = CalendarDay(date: DateTime(2026, 9, 2), workHours: 8, overtimeHours: 2, coefficient: 3);
    expect(estimatedDayPay(day, 20800000), (800000 + 300000) * 3);
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
