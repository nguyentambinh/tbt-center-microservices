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

import 'package:tbtcenter/features/organization/presentation/widgets/head_tag.dart';

import 'helpers.dart';

Future<void> _pump(WidgetTester tester, List<String> roles, FakeOrganizationRepository organization) async {
  final overrides = await testOverrides(
    language: 'vi',
    store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles))),
    organization: organization,
  );
  await tester.pumpWidget(ProviderScope(overrides: overrides, child: const TbtApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('trưởng phòng đứng đầu, không có mục chuyển đi cho trưởng phòng', (tester) async {
    final organization = FakeOrganizationRepository();
    await _pump(tester, ['hr'], organization);
    await openHomeCard(tester, 'Phòng ban');
    expect(find.text('Phòng Kỹ thuật'), findsOneWidget);
    expect(find.text('1 người mới chưa có phòng ban'), findsOneWidget);

    await tester.tap(find.text('Phòng Kỹ thuật'));
    await tester.pumpAndSettle();
    final names = tester.widgetList<Text>(find.textContaining(RegExp(r'^(Nguyễn Văn A|Trần Thị B|Lê Văn C)$'))).map((t) => t.data).toList();
    expect(names, ['Nguyễn Văn A', 'Trần Thị B', 'Lê Văn C']);
    expect(find.widgetWithText(HeadTag, 'Trưởng phòng'), findsOneWidget);

    final headRow = find.widgetWithText(ListTile, 'Nguyễn Văn A');
    expect(find.descendant(of: headRow, matching: find.byType(PopupMenuButton<String>)), findsNothing);
    await tester.tap(find.descendant(of: find.widgetWithText(ListTile, 'Trần Thị B'), matching: find.byType(PopupMenuButton<String>)));
    await tester.pumpAndSettle();
    expect(find.text('Giao làm trưởng phòng'), findsOneWidget);
  });

  testWidgets('AI gợi ý phòng cho người mới, HR đồng ý thì chuyển vào', (tester) async {
    final organization = FakeOrganizationRepository();
    await _pump(tester, ['hr'], organization);
    await openHomeCard(tester, 'Phòng ban');
    await tester.tap(find.text('1 người mới chưa có phòng ban'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AI gợi ý xếp phòng'));
    await tester.pumpAndSettle();
    expect(find.text('Gợi ý: Phòng Kỹ thuật'), findsOneWidget);

    await tester.tap(find.text('Đồng ý'));
    await tester.pumpAndSettle();
    expect(organization.transfers.single.$1, 'PB1');
    expect(organization.transfers.single.$2, ['N1']);
  });

  testWidgets('Ban lãnh đạo duyệt đề cử thăng chức', (tester) async {
    final organization = FakeOrganizationRepository();
    await _pump(tester, ['executive'], organization);
    await openHomeCard(tester, 'Đề cử thăng chức');
    expect(find.text('Kỹ sư  →  Trưởng nhóm'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Duyệt'));
    await tester.pumpAndSettle();
    expect(find.textContaining('tăng 10% lương cơ bản'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Duyệt').last);
    await tester.pumpAndSettle();
    expect(organization.decisions.single, (1, true));
  });

  testWidgets('nhân viên thường không vào được màn phòng ban', (tester) async {
    await _pump(tester, ['employee'], FakeOrganizationRepository());
    expect(find.text('Phòng ban'), findsNothing);
  });

  testWidgets('sơ đồ tổ chức: thu gọn phòng ban, tìm không dấu, xem người, xoay 3D', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await _pump(tester, ['hr'], FakeOrganizationRepository());
    await openHomeCard(tester, 'Phòng ban');
    await tester.tap(find.byTooltip('Sơ đồ tổ chức'));
    await tester.pumpAndSettle();
    expect(find.text('2 phòng ban · 3 người'), findsOneWidget);
    expect(find.widgetWithText(HeadTag, 'Trưởng phòng'), findsOneWidget);

    // Gõ không dấu vẫn ra "Lê Minh Thư"
    await tester.enterText(find.byType(TextField), 'minh thu');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lê Minh Thư'));
    await tester.pumpAndSettle();
    expect(find.text('Chuyên viên, kỹ sư'), findsWidgets);
    expect(find.text('Xem hồ sơ'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    // Thu gọn phòng thì ẩn người trong phòng
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    await tester.tap(find.text('▾ Phòng Tài chính'));
    await tester.pumpAndSettle();
    expect(find.text('Phạm Quốc Huy'), findsNothing);

    await tester.tap(find.text('3D'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter.runtimeType.toString() == '_Tree3dPainter'), findsOneWidget);
  });

  testWidgets('sơ đồ tổ chức: tìm người chỉ sáng phòng của họ, tick chọn phòng ban, 3D đứng yên có nút điều chỉnh', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await _pump(tester, ['hr'], FakeOrganizationRepository());
    await openHomeCard(tester, 'Phòng ban');
    await tester.tap(find.byTooltip('Sơ đồ tổ chức'));
    await tester.pumpAndSettle();

    double opacityOf(String text) => tester.widget<Opacity>(find.ancestor(of: find.text(text), matching: find.byType(Opacity)).last).opacity;
    await tester.enterText(find.byType(TextField), 'minh thu');
    await tester.pumpAndSettle();
    expect(opacityOf('▾ Phòng Kỹ thuật'), 1);
    expect(opacityOf('▾ Phòng Tài chính'), lessThan(1));

    // Bỏ tick Phòng Tài chính thì sơ đồ chỉ còn 1/2 phòng
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('2/2'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxMenuButton, 'Phòng Tài chính'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 300));
    await tester.pumpAndSettle();
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('Phạm Quốc Huy'), findsNothing);
    expect(find.text('Lê Minh Thư'), findsOneWidget);

    // 3D không tự quay nên pumpAndSettle dừng được; nút phóng to, nghiêng đổi góc nhìn
    await tester.tap(find.text('3D'));
    await tester.pumpAndSettle();
    _Tree3dView view() {
      final painter = tester.widget<CustomPaint>(find.byWidgetPredicate((w) => w is CustomPaint && w.painter.runtimeType.toString() == '_Tree3dPainter')).painter! as dynamic;
      return (zoom: painter.zoom as double, tilt: painter.tilt as double);
    }
    final start = view();
    await tester.tap(find.byTooltip('Phóng to'));
    await tester.tap(find.byTooltip('Nhìn từ dưới lên'));
    await tester.pumpAndSettle();
    expect(view().zoom, greaterThan(start.zoom));
    expect(view().tilt, lessThan(start.tilt));
    await tester.tap(find.byTooltip('Về góc nhìn ban đầu'));
    await tester.pumpAndSettle();
    expect(view(), start);
  });

  testWidgets('đề cử thăng chức chỉ chọn được chức vụ cấp cao hơn', (tester) async {
    final organization = FakeOrganizationRepository();
    await _pump(tester, ['hr'], organization);
    await openHomeCard(tester, 'Nhân viên xuất sắc');
    await tester.tap(find.text('Trần Thị B'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đề cử thăng chức').last);
    await tester.pumpAndSettle();
    // Không còn ô gõ tay chức vụ, chỉ chọn trong danh sách cấp cao hơn
    await tester.tap(find.text('Chức vụ đề xuất'));
    await tester.pumpAndSettle();
    expect(find.text('Phó phòng · Chỉ huy, phó phòng'), findsWidgets);
    expect(find.text('Trưởng phòng · Trưởng phòng, quản lý'), findsWidgets);
  });
}

typedef _Tree3dView = ({double zoom, double tilt});
