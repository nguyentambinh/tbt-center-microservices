/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/features/notification/domain/entities/app_notification.dart';
import 'package:tbtcenter/features/profile/domain/change_request.dart';

import 'helpers.dart';

Future<void> _pump(WidgetTester tester, List<String> roles, {FakeProfileRepository? profile, FakeNotificationRepository? notifications}) async {
  final overrides = await testOverrides(
    language: 'vi',
    store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles, employeeId: 'Anh8715OP'))),
    profile: profile,
    notifications: notifications,
  );
  await tester.pumpWidget(ProviderScope(overrides: overrides, child: const TbtApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('nhân viên mở mục Cá nhân, sửa số điện thoại rồi gửi đề xuất cho HR', (tester) async {
    final profile = FakeProfileRepository();
    await _pump(tester, ['employee'], profile: profile);
    await tester.tap(find.text('Cá nhân'));
    await tester.pumpAndSettle();
    expect(find.text('Thông tin cá nhân'), findsOneWidget);

    await tester.tap(find.text('Đề xuất sửa thông tin'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Điện thoại'), '0988000111');
    await tester.scrollUntilVisible(find.text('Gửi đề xuất'), 200, scrollable: find.descendant(of: find.byType(Form), matching: find.byType(Scrollable)).first);
    await tester.ensureVisible(find.text('Gửi đề xuất'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gửi đề xuất'));
    await tester.pumpAndSettle();

    // Chỉ trường đã đổi được gửi lên
    expect(profile.submitted, [
      {'phone': '0988000111'},
    ]);
    expect(find.text('Bạn đang có một đề xuất chờ HR duyệt'), findsOneWidget);
  });

  testWidgets('không sửa ô nào thì không gửi đề xuất', (tester) async {
    final profile = FakeProfileRepository();
    await _pump(tester, ['employee'], profile: profile);
    await tester.tap(find.text('Cá nhân'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đề xuất sửa thông tin'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Gửi đề xuất'), 200, scrollable: find.descendant(of: find.byType(Form), matching: find.byType(Scrollable)).first);
    await tester.ensureVisible(find.text('Gửi đề xuất'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gửi đề xuất'));
    await tester.pumpAndSettle();
    expect(profile.submitted, isEmpty);
    expect(find.text('Bạn chưa sửa ô nào'), findsOneWidget);
  });

  testWidgets('HR thấy đề xuất trong Việc cần xử lý và duyệt', (tester) async {
    final profile = FakeProfileRepository(items: [
      ChangeRequest(id: 5, employeeId: 'Binh0001', employeeName: 'Nguyễn Anh', changes: const {'address': 'Bình Dương'}, status: 'pending', requestedAt: DateTime(2026, 10, 25, 9)),
    ]);
    await _pump(tester, ['hr', 'employee'], profile: profile);
    await tester.tap(find.text('1 đề xuất sửa hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.text('Nguyễn Anh'), findsOneWidget);
    expect(find.text('Bình Dương'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Duyệt'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();
    expect(profile.decided, [(5, true)]);
  });

  testWidgets('HR không tự duyệt đề xuất sửa hồ sơ của chính mình', (tester) async {
    final profile = FakeProfileRepository(items: [
      ChangeRequest(id: 6, employeeId: 'Anh8715OP', employeeName: 'Nguyễn Văn Anh', changes: const {'address': 'Thủ Dầu Một'}, status: 'pending', requestedAt: DateTime(2026, 10, 26, 9)),
    ]);
    await _pump(tester, ['hr', 'employee'], profile: profile);
    await tester.tap(find.text('1 đề xuất sửa hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.text('Chờ cấp trên duyệt'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Duyệt'), findsNothing);
  });

  testWidgets('có thông báo mới thì hiện thẻ nổi trên cùng màn hình', (tester) async {
    final notifications = FakeNotificationRepository();
    await _pump(tester, ['employee'], notifications: notifications);
    expect(find.byIcon(Icons.notifications_active), findsNothing);

    notifications.items = [
      AppNotification(id: 'n1', kind: 'profile_change_approved', createdAt: DateTime.now()),
    ];
    // Hỏi hộp thư lần kế tiếp (30 giây)
    await tester.pump(const Duration(seconds: 31));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('HR đã duyệt đề xuất sửa thông tin của bạn'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('HR đã duyệt đề xuất sửa thông tin của bạn'), findsNothing);
  });
}
