/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'e2e_helpers.dart';

// E2E: thao tác ghi dữ liệu thật qua giao diện
/// Chạm hai lần với mốc thời gian thật như ngón tay
Future<void> doubleTap(WidgetTester tester) async {
  final now = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);
  for (var i = 0; i < 2; i++) {
    final p = TestPointer(90 + i);
    final at = now + Duration(milliseconds: 160 * i);
    await tester.sendEventToBinding(p.down(const Offset(200, 500), timeStamp: at));
    await tester.sendEventToBinding(p.up(timeStamp: at + const Duration(milliseconds: 50)));
  }
  await waitLoaded(tester);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('nhân viên Đức chấm công bằng nút trên màn Chấm công', (tester) async {
    await pumpAs(tester, 'employee.de');
    await openHomeCard(tester, 'Chấm công & nghỉ phép');
    final button = find.byWidgetPredicate(
      (w) => w is FilledButton && w.onPressed != null,
      description: 'nút chấm công còn bấm được',
    );
    if (button.evaluate().isEmpty) {
      // Nút tắt: hoặc đã xong ca, hoặc hôm nay (Chủ nhật, ngày lễ) không có ca
      expect(
        find.textContaining(RegExp('Đã xong ca hôm nay|không có ca làm việc')),
        findsOneWidget,
      );
      return;
    }
    await tester.tap(button.first);
    await waitLoaded(tester);
    expect(
      find.textContaining(RegExp(r'Đã vào ca lúc|Đã ra ca lúc|chờ ít nhất')),
      findsWidgets,
      reason: 'phải báo đã vào ca hoặc ra ca',
    );
  });

  testWidgets('HR chuyển ứng viên sang mời nhận việc rồi nhận vào làm', (tester) async {
    await pumpAs(tester, const String.fromEnvironment('TBT_HIRE_USER', defaultValue: 'hr.vn'));
    await openHomeCard(tester, 'Ứng viên');
    final chips = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.right);
    // Lấy ứng viên ở bước bất kỳ trước Mời nhận việc, chạy lại nhiều lần vẫn còn người
    Finder? candidate;
    for (final stage in ['Phỏng vấn', 'Đang sàng lọc', 'AI đã tóm tắt', 'Đã nộp']) {
      final chip = find.widgetWithText(ChoiceChip, stage);
      // Kéo hàng chip về đầu rồi mới tìm, vòng trước có thể đã cuộn qua chip này
      await tester.drag(chips, const Offset(1000, 0));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(chip, 150, scrollable: chips);
      await tester.tap(chip);
      await waitLoaded(tester);
      final row = find.ancestor(of: find.text(stage), matching: find.byType(ListTile));
      if (row.evaluate().isNotEmpty) {
        candidate = row.first;
        break;
      }
    }
    expect(candidate, isNotNull, reason: 'hết ứng viên để thử');
    await tester.tap(candidate!);
    await waitLoaded(tester);

    final offer = find.widgetWithText(OutlinedButton, 'Mời nhận việc');
    await tester.scrollUntilVisible(offer, 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(offer);
    await waitLoaded(tester);

    final hire = find.widgetWithText(FilledButton, 'Nhận vào làm');
    await tester.scrollUntilVisible(hire, -200, scrollable: find.byType(Scrollable).last);
    final watch = Stopwatch()..start();
    await tester.tap(hire);
    await waitLoaded(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Nhận vào làm').last);
    await waitLoaded(tester);
    debugPrint('Nhận vào làm mất ${watch.elapsedMilliseconds} ms');

    expect(find.textContaining('Đã tạo nhân viên TBT'), findsOneWidget);
    expect(find.textContaining('Tên đăng nhập:'), findsOneWidget);
    expect(find.textContaining('Mật khẩu tạm:'), findsOneWidget, reason: 'hồ sơ HR nhập chưa có tài khoản');
    await tester.tap(find.widgetWithText(FilledButton, 'Đóng'));
    await waitLoaded(tester);
    expect(find.text('Đã nhận vào làm'), findsWidgets);
  });

  testWidgets('ứng viên vừa được nhận đăng nhập bằng email, thành Nhân viên', (tester) async {
    await pumpAs(tester, 'thu.le@example.com');
    expect(find.text('Nhân viên'), findsWidgets);
    expect(find.text('Hồ sơ ứng tuyển của tôi'), findsNothing);
    await openHomeCard(tester, 'Chấm công & nghỉ phép');
    expect(find.text('Vào ca'), findsWidgets);
  });

  testWidgets('ứng viên xem tiến trình hồ sơ của mình', (tester) async {
    await pumpAs(tester, 'ungvien.cv');
    await openHomeCard(tester, 'Hồ sơ ứng tuyển của tôi');
    expect(find.text('Tiến trình'), findsOneWidget);
  });

  testWidgets('đổi sang tiếng Anh ở Cài đặt thì màn chính đổi chữ', (tester) async {
    await pumpAs(tester, 'hr.us');
    await tester.tap(find.text('Cài đặt'));
    await waitLoaded(tester);
    await tester.tap(find.text('English'));
    await waitLoaded(tester);
    await tester.pageBack();
    await waitLoaded(tester);
    expect(find.textContaining('Hello'), findsOneWidget);
    expect(find.text('Candidates'), findsOneWidget);
  });

  testWidgets('nhân viên gõ không dấu tìm trong Kho tri thức rồi mở bài', (tester) async {
    await pumpAs(tester, 'employee.de');
    await openHomeCard(tester, 'Kho tri thức');
    await tester.tap(find.text('Tìm bài'));
    await waitLoaded(tester);
    await tester.enterText(find.byType(TextField), 'tang ca');
    await waitLoaded(tester);
    final article = find.text('Cách tính lương tăng ca');
    expect(article, findsOneWidget, reason: 'tìm không dấu vẫn phải ra bài tăng ca');
    await tester.tap(article);
    await waitLoaded(tester);
    expect(find.textContaining('Ví dụ lương tháng 17.600.000'), findsOneWidget);
  });

  testWidgets('nhân viên hỏi AI, câu trả lời có nguồn mở được, hỏi tiếp, chấm điểm', (tester) async {
    await pumpAs(tester, 'employee.vn');
    await openHomeCard(tester, 'Kho tri thức');
    await tester.enterText(find.byType(TextField), 'Ai duyệt đơn nghỉ phép của tôi?');
    await tester.tap(find.byTooltip('Gửi'));
    final waited = await waitLoaded(tester);
    debugPrint('Hỏi AI chờ ${waited.inMilliseconds} ms');
    expect(find.text('Nguồn'), findsOneWidget, reason: 'câu trả lời phải có nguồn');
    expect(find.text('Xin nghỉ phép'), findsOneWidget, reason: 'nguồn đúng là bài nghỉ phép');
    expect(find.textContaining(RegExp('Trả lời bởi (Claude|Gemini)|Không dùng AI')), findsOneWidget);

    await tester.tap(find.text('Xin nghỉ phép'));
    await waitLoaded(tester);
    // Câu trả lời AI cũng có thể chứa cụm này, nên chỉ tìm trong bảng bài viết
    final body = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.textContaining('không ai được tự duyệt đơn của chính mình'),
    );
    expect(body, findsOneWidget);
    Navigator.of(tester.element(body)).pop();
    await waitLoaded(tester);

    // Đóng bảng bài viết không được làm bàn phím bật lại
    expect(tester.view.viewInsets.bottom, 0);
    await Scrollable.ensureVisible(tester.element(find.byTooltip('Hữu ích')), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hữu ích'));
    await waitLoaded(tester);
    expect(find.text('Cảm ơn góp ý của bạn'), findsOneWidget);

    // Câu nối tiếp không nhắc lại chủ đề, server phải hiểu nhờ lượt trước
    // Như người dùng: chạm vào ô cho bàn phím mở rồi mới gõ
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Còn đơn tăng ca thì sao?');
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, 'Còn đơn tăng ca thì sao?');
    await tester.tap(find.byTooltip('Gửi'));
    await waitLoaded(tester);
    expect(find.text('Đăng ký tăng ca'), findsOneWidget, reason: 'câu nối tiếp phải ra bài đơn tăng ca');
  });

  testWidgets('HR xem đồ thị tri thức, đi theo liên kết sang nút khác', (tester) async {
    await pumpAs(tester, 'hr.vn');
    await openHomeCard(tester, 'Kho tri thức');
    await tester.tap(find.text('Đồ thị'));
    await waitLoaded(tester);
    expect(find.text('Chốt lương'), findsWidgets);
    expect(find.textContaining('Quy trình nhiều bước (Saga)'), findsOneWidget);

    final panel = find.descendant(of: find.byType(ListView).last, matching: find.byType(Scrollable)).first;
    final lock = find.text('1. Khóa kỳ → là bước của');
    await tester.scrollUntilVisible(lock, 120, scrollable: panel);
    await Scrollable.ensureVisible(tester.element(lock), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(lock);
    await waitLoaded(tester);
    expect(find.textContaining('Khóa kỳ ở chấm công'), findsOneWidget, reason: 'phải chuyển sang nút Khóa kỳ');
  });

  testWidgets('chạm hai lần trên màn Phiếu lương thì quay lại màn chính', (tester) async {
    await pumpAs(tester, 'employee.br');
    await openHomeCard(tester, 'Phiếu lương');
    expect(find.textContaining('Xin chào'), findsNothing);
    await doubleTap(tester);
    expect(find.textContaining('Xin chào'), findsOneWidget);
  });
}
