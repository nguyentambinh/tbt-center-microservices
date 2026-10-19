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
import 'package:tbtcenter/features/notification/domain/entities/app_notification.dart';

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
}
