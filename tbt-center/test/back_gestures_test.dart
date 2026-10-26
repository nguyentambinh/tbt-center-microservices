/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/core/widgets/back_gestures.dart';

Future<GlobalKey<NavigatorState>> _pumpTwoPages(WidgetTester tester) async {
  final key = GlobalKey<NavigatorState>();
  await tester.pumpWidget(MaterialApp(
    navigatorKey: key,
    builder: (context, child) => BackGestures(navigatorKey: key, child: child!),
    home: const Scaffold(body: Text('Trang 1')),
  ));
  key.currentState!.push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Center(child: Text('Trang 2')))));
  await tester.pumpAndSettle();
  return key;
}

Future<void> _tapAt(WidgetTester tester, int pointer, Duration at) async {
  final p = TestPointer(pointer);
  const position = Offset(200, 300);
  await tester.sendEventToBinding(p.down(position, timeStamp: at));
  await tester.sendEventToBinding(p.up(timeStamp: at + const Duration(milliseconds: 60)));
}

void main() {
  testWidgets('chạm hai lần nhanh không quay lại', (tester) async {
    await _pumpTwoPages(tester);
    await _tapAt(tester, 1, const Duration(seconds: 10));
    await _tapAt(tester, 2, const Duration(seconds: 10, milliseconds: 180));
    await tester.pumpAndSettle();
    expect(find.text('Trang 2'), findsOneWidget);
  });

  testWidgets('vuốt sang phải giữa màn hình thì quay lại', (tester) async {
    await _pumpTwoPages(tester);
    await tester.flingFrom(const Offset(150, 300), const Offset(250, 0), 1200);
    await tester.pumpAndSettle();
    expect(find.text('Trang 1'), findsOneWidget);
  });

  testWidgets('vuốt sang trái thì không quay lại', (tester) async {
    await _pumpTwoPages(tester);
    await tester.flingFrom(const Offset(400, 300), const Offset(-250, 0), 1200);
    await tester.pumpAndSettle();
    expect(find.text('Trang 2'), findsOneWidget);
  });
}
