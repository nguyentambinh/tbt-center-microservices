// Nguyễn Tâm Bình - 2324801030003
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/core/auth/auth_controller.dart';
import 'package:tbtcenter/core/locale/locale_providers.dart';
import 'package:tbtcenter/core/router/app_router.dart';

import 'e2e_helpers.dart';

// Chụp màn xếp lịch có thành viên, lịch tháng trước, đăng ký và vào thay tài khoản; in "SHOT:<tên>"
Future<void> shot(WidgetTester tester, String name) async {
  await waitLoaded(tester);
  debugPrint('SHOT:$name');
  await Future<void>.delayed(const Duration(milliseconds: 3500));
  await tester.pump();
}

GoRouter _router(WidgetTester tester) => ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(appRouterProvider);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('đăng ký ứng viên', (tester) async {
    SharedPreferences.setMockInitialValues({'language': 'vi'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sessionStoreProvider.overrideWithValue(MemoryStore(null)),
      ],
      child: const TbtApp(),
    ));
    await waitLoaded(tester);
    _router(tester).go(Routes.signup);
    await waitLoaded(tester);
    await shot(tester, '40_dang_ky');
  });

  testWidgets('lịch tháng trước', (tester) async {
    await pumpAs(tester, 'employee.vn');
    _router(tester).go(Routes.workCalendar);
    await waitLoaded(tester);
    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await waitLoaded(tester);
    await shot(tester, '41_lich_lam_viec');
  });

  testWidgets('xếp lịch có thành viên', (tester) async {
    await pumpAs(tester, 'hr.vn');
    _router(tester).go(Routes.scheduleManage);
    await waitLoaded(tester);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownMenuItem<String>).last);
    await waitLoaded(tester);
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await shot(tester, '90_xep_lich');
  });

  testWidgets('vào thay tài khoản nhân viên', (tester) async {
    await pumpAs(tester, 'admin.vn');
    _router(tester).go(Routes.adminConsole);
    await waitLoaded(tester);
    await tester.tap(find.text('Tài khoản').first);
    await waitLoaded(tester);
    await tester.drag(find.byType(ListView).last, const Offset(0, -200));
    await tester.pumpAndSettle();
    await shot(tester, '92_tai_khoan');
    final row = find.ancestor(of: find.textContaining('employee.vn@').first, matching: find.byType(ListTile));
    await tester.tap(find.descendant(of: row, matching: find.byIcon(Icons.arrow_forward)));
    await tester.pumpAndSettle();
    await shot(tester, '92_xac_nhan_vao_tai_khoan');
    await tester.tap(find.text('Vào tài khoản này'));
    await waitLoaded(tester);
    await shot(tester, '93_dang_xem_voi_tu_cach');
  });
}
