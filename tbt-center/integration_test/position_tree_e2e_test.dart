// Nguyễn Tâm Bình - 2324801030003
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tbtcenter/core/router/app_router.dart';
import 'package:tbtcenter/features/organization/presentation/pages/position_tree_page.dart';

import 'e2e_helpers.dart';

// Cây chức vụ, chốt lương, thưởng phạt với dữ liệu thật; in "SHOT:<tên>" để chụp màn hình
Future<void> shot(String name) async {
  debugPrint('SHOT:$name');
  await Future<void>.delayed(const Duration(milliseconds: 3000));
}

GoRouter _router(WidgetTester tester) => ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(appRouterProvider);

Future<void> settle(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  expect(finder, findsWidgets);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('văn phòng quản lý xem cây, mở người giữ chức vụ', (tester) async {
    await pumpAs(tester, 'executive.vn');
    _router(tester).go(Routes.positionTree);
    await settle(tester, find.byType(PositionSceneView));
    await tester.pump(const Duration(seconds: 2));
    final positions = tester.state<PositionSceneViewState>(find.byType(PositionSceneView).first);
    debugPrint('CAY: ${positions.nodes.where((n) => n.kind == TreeNodeKind.position).length} chức vụ');
    await shot('cay_chuc_vu');

    await tester.tap(find.text('Người giữ chức vụ'));
    await tester.pump(const Duration(seconds: 2));
    final finder = find.byWidgetPredicate((w) => w is PositionSceneView && w.withPeople);
    final people = tester.state<PositionSceneViewState>(finder);
    debugPrint('CAY: ${people.nodes.where((n) => n.kind == TreeNodeKind.person).length} người');
    await shot('cay_nguoi_giu');

    // Kéo xoay rồi bấm một người
    await tester.dragFrom(tester.getCenter(finder), const Offset(120, 40));
    await tester.pump(const Duration(milliseconds: 500));
    final person = people.nodes.firstWhere((n) => n.kind == TreeNodeKind.person && n.screen.dy > 60 && n.screen.dy < 300 && n.screen.dx > 60 && n.screen.dx < 300);
    await tester.tapAt(tester.getTopLeft(finder) + person.screen);
    await settle(tester, find.text('Thăng chức, đổi chức vụ'));
    await tester.pump(const Duration(milliseconds: 600));
    await shot('cay_sheet_nguoi');
  });

  testWidgets('tài chính thấy tên, phòng ban ở chốt lương', (tester) async {
    await pumpAs(tester, 'finance.vn');
    _router(tester).go(Routes.payrollRuns);
    await settle(tester, find.byType(CheckboxListTile));
    await tester.pump(const Duration(seconds: 3));
    final title = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile).first).title! as Text;
    debugPrint('LUONG: ${title.data}');
    expect(title.data, isNot(startsWith('VN')));
    await shot('chot_luong');
  });

  testWidgets('nhân sự có mục thưởng phạt trên hồ sơ', (tester) async {
    await pumpAs(tester, 'hr.vn');
    _router(tester).go(Routes.employees);
    await settle(tester, find.byType(ListTile));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byType(ListTile).first);
    await settle(tester, find.byType(PopupMenuButton<String>));
    await tester.tap(find.byType(PopupMenuButton<String>).last);
    await settle(tester, find.text('Thưởng, phạt'));
    await tester.tap(find.text('Thưởng, phạt'));
    await tester.pump(const Duration(seconds: 1));
    await shot('hr_thuong_phat');
  });
}
