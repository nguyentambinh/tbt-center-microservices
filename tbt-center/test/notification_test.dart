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
import 'package:tbtcenter/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:tbtcenter/features/hr/presentation/providers/employee_providers.dart';
import 'package:tbtcenter/features/notification/domain/entities/app_notification.dart';

import 'attendance_test.dart' show FakeAttendanceRepository;

import 'helpers.dart';

Future<FakeNotificationRepository> _pump(WidgetTester tester, {String language = 'vi', List<String> roles = const ['employee']}) async {
  final notifications = FakeNotificationRepository([
    AppNotification(
      id: 'N1',
      kind: 'leave_approved',
      params: const {'fromDate': '2026-12-28', 'days': 3},
      createdAt: DateTime(2026, 10, 15, 9, 30),
    ),
    AppNotification(
      id: 'N2',
      kind: 'payroll_paid',
      params: const {'period': '2026-10'},
      createdAt: DateTime(2026, 10, 15, 8),
    ),
    AppNotification(
      id: 'N3',
      kind: 'candidate_status',
      params: const {'status': 'interview'},
      createdAt: DateTime(2026, 10, 14),
      read: true,
    ),
  ]);
  final overrides = await testOverrides(
    language: language,
    store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles))),
    notifications: notifications,
  );
  await tester.pumpWidget(ProviderScope(overrides: overrides, child: const TbtApp()));
  await tester.pumpAndSettle();
  return notifications;
}

void main() {
  testWidgets('chuông hiện số chưa đọc, mở ra thấy câu theo ngôn ngữ, đọc hết thì mất số', (tester) async {
    final notifications = await _pump(tester);
    expect(find.descendant(of: find.byType(Badge), matching: find.text('2')), findsOneWidget);

    await tester.tap(find.byTooltip('Thông báo'));
    await tester.pumpAndSettle();
    expect(find.text('Đơn nghỉ từ 28 thg 12, 2026 đã được duyệt'), findsOneWidget);
    expect(find.text('Lương kỳ 2026-10 đã được chi'), findsOneWidget);
    expect(find.text('Hồ sơ của bạn đã chuyển sang bước: Phỏng vấn'), findsOneWidget);

    await tester.tap(find.text('Đọc hết'));
    await tester.pumpAndSettle();
    expect(notifications.markAllCalls, 1);
    expect(find.text('Đọc hết'), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(Badge), matching: find.text('2')), findsNothing);
  });

  testWidgets('cùng thông báo hiện bằng tiếng Đức khi chọn tiếng Đức', (tester) async {
    await _pump(tester, language: 'de');
    await tester.tap(find.byTooltip('Benachrichtigungen'));
    await tester.pumpAndSettle();
    expect(find.text('Gehalt für 2026-10 wurde ausgezahlt'), findsOneWidget);
  });

  testWidgets('HR bấm thông báo xin nghỉ: đánh dấu đã đọc, mở thẳng đơn để duyệt', (tester) async {
    final notifications = FakeNotificationRepository([
      AppNotification(id: 'N9', kind: 'leave_requested', params: const {'employeeId': 'NV001', 'fromDate': '2026-12-28', 'days': 3, 'ref': 'L1'}, createdAt: DateTime(2026, 10, 26, 9)),
      AppNotification(id: 'N8', kind: 'raise_requested', params: const {'employeeId': 'NV002', 'ref': '7'}, createdAt: DateTime(2026, 10, 26, 8)),
    ]);
    final attendance = FakeAttendanceRepository();
    final overrides = await testOverrides(language: 'vi', store: MemorySessionStore(fakeSession(token: fakeJwt(roles: ['hr']))), notifications: notifications);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        ...overrides,
        attendanceRepositoryProvider.overrideWithValue(attendance),
        employeeDetailProvider.overrideWith((ref, id) => Future.error(StateError('offline'))),
      ],
      child: const TbtApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thông báo'));
    await tester.pumpAndSettle();
    // Loại mới có câu riêng, không còn câu chung chung
    expect(find.text('NV002 gửi đề xuất tăng lương'), findsOneWidget);
    expect(find.text('Bạn có thông báo mới'), findsNothing);

    await tester.tap(find.textContaining('xin nghỉ'));
    await tester.pumpAndSettle();
    expect(notifications.readIds, ['N9']);
    expect(find.text('Người gửi · Anh8715OP'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Duyệt'));
    await tester.pumpAndSettle();
    expect(attendance.decisions, {'L1': true});
  });
}
