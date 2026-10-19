/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'e2e_helpers.dart';

// E2E: bản thể học, suy luận, SPARQL, đề xuất AI trên server thật
Future<void> _openMenu(WidgetTester tester, String item) async {
  await tester.tap(find.byTooltip('Thêm'));
  await waitLoaded(tester);
  await tester.tap(find.text(item));
  await waitLoaded(tester);
}

Future<void> _tapVisible(WidgetTester tester, Finder target, Finder scrollable, {double step = 120}) async {
  await tester.scrollUntilVisible(target, step, scrollable: scrollable);
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await waitLoaded(tester);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('nhân viên xem bản thể học, chạy câu SPARQL mẫu', (tester) async {
    await pumpAs(tester, 'employee.vn');
    await openHomeCard(tester, 'Kho tri thức');
    await _openMenu(tester, 'Bản thể học');
    expect(find.textContaining('cạnh suy ra'), findsOneWidget);
    expect(find.textContaining('Lần suy luận gần nhất'), findsOneWidget);
    expect(find.text('Đơn yêu cầu'), findsOneWidget, reason: 'cây lớp phải có lớp con của Khái niệm');
    expect(find.text('Chạy lại suy luận'), findsNothing, reason: 'nhân viên không được chạy lại suy luận');
    // App không có nút quay lại trên thanh tiêu đề: dùng nút Back của hệ thống
    await tester.binding.handlePopRoute();
    await waitLoaded(tester);

    await _openMenu(tester, 'Truy vấn SPARQL');
    final watch = Stopwatch()..start();
    await tester.tap(find.text('Chốt lương cần service nào'));
    await waitLoaded(tester);
    debugPrint('SPARQL chạy mất ${watch.elapsedMilliseconds} ms');
    expect(find.textContaining('6 dòng'), findsOneWidget, reason: 'chốt lương cần 6 service (suy ra qua 2 luật)');
    expect(find.text('bank_mock'), findsOneWidget);
    expect(find.text('kg:svc-bank-mock'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'SELECT ?x WHERE { ?x kgo:uses ');
    await tester.tap(find.text('Chạy'));
    await waitLoaded(tester);
    expect(find.textContaining('Câu truy vấn lỗi'), findsOneWidget);
  });

  testWidgets('đồ thị: cạnh suy ra có giải thích, tìm đường nối hai khái niệm', (tester) async {
    await pumpAs(tester, 'hr.vn');
    await openHomeCard(tester, 'Kho tri thức');
    await tester.tap(find.text('Đồ thị'));
    await waitLoaded(tester);
    final panel = find.descendant(of: find.byType(ListView).last, matching: find.byType(Scrollable)).first;
    await _tapVisible(tester, find.text('có sự tham gia của → bank_mock'), panel);
    expect(find.textContaining('Máy suy ra bằng luật'), findsOneWidget);
    expect(find.textContaining('gọi tới→ bank_mock'), findsOneWidget, reason: 'phải nêu cạnh tiền đề');
    await tester.tap(find.text('Mở nút này'));
    await waitLoaded(tester);
    expect(find.textContaining('Ngân hàng giả lập'), findsOneWidget);

    await _tapVisible(tester, find.text('Nối tới…'), panel, step: -120);
    await tester.enterText(find.byType(TextField).last, 'luong thuc nhan');
    // Ô tìm chờ người gõ dừng 300 ms mới gọi server
    await tester.pump(const Duration(milliseconds: 400));
    await waitLoaded(tester);
    await tester.tap(find.text('Lương thực nhận').last);
    await waitLoaded(tester);
    expect(find.text('Từ bank_mock tới Lương thực nhận'), findsOneWidget);
    expect(find.text('Lương thực nhận'), findsWidgets);
  });

  testWidgets('HR duyệt đề xuất AI, cạnh mới hiện trên đồ thị kèm câu trích', (tester) async {
    await pumpAs(tester, 'hr.vn');
    await openHomeCard(tester, 'Kho tri thức');
    await _openMenu(tester, 'Đề xuất từ AI');
    final card = find.text('Công nợ nhà cung cấp  —tính từ→  Mua vật liệu');
    final list = find.byType(Scrollable).last;
    // Chạy lại nhiều lần: lần trước đã duyệt thì tìm trong tab Đã duyệt
    var pending = true;
    try {
      await tester.scrollUntilVisible(card, 300, scrollable: list, maxScrolls: 40);
    } on StateError {
      pending = false;
    }
    if (pending) {
      final approve = find.descendant(
        of: find.ancestor(of: card, matching: find.byType(Card)),
        matching: find.widgetWithText(FilledButton, 'Duyệt'),
      );
      await Scrollable.ensureVisible(tester.element(approve), alignment: 0.5);
      await tester.pumpAndSettle();
      await tester.tap(approve);
      await waitLoaded(tester);
      expect(find.text('Đã thêm vào đồ thị, máy đang suy luận lại'), findsOneWidget);
    } else {
      await tester.tap(find.text('Đã duyệt'));
      await waitLoaded(tester);
      await tester.scrollUntilVisible(card, 300, scrollable: find.byType(Scrollable).last, maxScrolls: 40);
    }
    // App không có nút quay lại trên thanh tiêu đề: dùng nút Back của hệ thống
    await tester.binding.handlePopRoute();
    await waitLoaded(tester);

    await tester.tap(find.text('Đồ thị'));
    await waitLoaded(tester);
    await tester.enterText(find.byType(TextField), 'cong no');
    await tester.pump(const Duration(milliseconds: 400));
    await waitLoaded(tester);
    await tester.tap(find.text('Công nợ nhà cung cấp').last);
    await waitLoaded(tester);
    final panel = find.descendant(of: find.byType(ListView).last, matching: find.byType(Scrollable)).first;
    await _tapVisible(tester, find.text('tính từ → Mua vật liệu'), panel);
    expect(find.text('AI trích từ bài viết, HR đã duyệt:'), findsOneWidget);
    expect(find.textContaining('tổng tiền mua vật liệu trừ tổng tiền đã trả'), findsOneWidget);
  });
}
