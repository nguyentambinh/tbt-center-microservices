/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tbtcenter/features/home/presentation/pages/home_page.dart';

import 'attendance_test.dart' show pumpAttendance;
import 'helpers.dart';

void main() {
  testWidgets('màn có tab: vuốt từ mép trái vẫn quay lại màn chính', (tester) async {
    await pumpAttendance(tester, ['employee']);
    expect(find.byType(TabBarView), findsOneWidget);
    await tester.flingFrom(const Offset(4, 400), const Offset(300, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.textContaining('Xin chào'), findsOneWidget);
  });

  testWidgets('màn không có tab: vuốt từ mép trái quay lại', (tester) async {
    await pumpApp(tester, language: 'vi', store: MemorySessionStore(fakeSession(token: fakeJwt(roles: ['employee']))));
    await tester.tap(find.text('Cài đặt'));
    await tester.pumpAndSettle();
    await tester.flingFrom(const Offset(4, 400), const Offset(300, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.textContaining('Xin chào'), findsOneWidget);
  });

  testWidgets('chuyển giữa các tab vẫn giữ thanh điều hướng, quay lại là về màn chính', (tester) async {
    await pumpApp(tester, language: 'vi', store: MemorySessionStore(fakeSession(token: fakeJwt(roles: ['employee']))));
    final nav = find.byType(TbtBottomNav);
    for (final tab in ['Thông báo', 'Cài đặt', 'Cá nhân']) {
      await tester.tap(find.descendant(of: nav, matching: find.text(tab)));
      await tester.pumpAndSettle();
      expect(nav, findsOneWidget, reason: tab);
    }
    await tester.flingFrom(const Offset(4, 400), const Offset(300, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.textContaining('Xin chào'), findsOneWidget);
  });
}
