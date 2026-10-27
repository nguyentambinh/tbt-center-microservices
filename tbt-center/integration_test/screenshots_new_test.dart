/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-27
 */

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

// Chụp các màn thêm sau đợt đầu; in "SHOT:<tên>", script trên máy tính chụp bằng adb
Future<void> shot(WidgetTester tester, String name) async {
  await waitLoaded(tester);
  debugPrint('SHOT:$name');
  await Future<void>.delayed(const Duration(milliseconds: 3500));
  await tester.pump();
}

GoRouter _router(WidgetTester tester) => ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(appRouterProvider);

Future<void> visit(WidgetTester tester, String route, String name, {Future<void> Function()? after}) async {
  try {
    _router(tester).go(route);
    await waitLoaded(tester);
    await shot(tester, name);
    if (after != null) await after();
  } on Object catch (e) {
    debugPrint('BO QUA $name: $e');
  }
}

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
    await visit(tester, Routes.signup, '40_dang_ky');
  });

  testWidgets('nhân viên', (tester) async {
    await pumpAs(tester, 'employee.vn');
    await visit(tester, Routes.workCalendar, '41_lich_lam_viec');
    await visit(tester, Routes.clockStats, '42_bieu_do_cham_cong');
    await visit(tester, Routes.raiseRequests, '43_de_xuat_tang_luong');
    await visit(tester, Routes.resignations, '44_thoi_viec');
    await visit(tester, Routes.orgTree, '45_so_do_to_chuc');
    await visit(tester, Routes.profile, '46_ho_so_ca_nhan');
    await visit(tester, Routes.changeRequests, '47_yeu_cau_sua_ho_so');
  });

  testWidgets('HR', (tester) async {
    await pumpAs(tester, 'hr.vn');
    await visit(tester, Routes.approvals, '50_duyet_don');
    await visit(tester, Routes.resignations, '51_thoi_viec_hr');
    await visit(tester, Routes.nominations, '52_de_cu');
    await visit(tester, Routes.rankings, '53_xep_hang');
    await visit(tester, Routes.departments, '54_phong_ban');
    await visit(tester, Routes.jobPositions, '55_vi_tri_tuyen');
    await visit(tester, Routes.reportSubmissions, '56_bao_cao_gui_cap_tren_hr');
    await visit(tester, Routes.candidates, '57_ung_vien_phong_van');
    await visit(tester, Routes.raiseRequests, '58_tang_luong_hr');
  });

  testWidgets('tài chính', (tester) async {
    await pumpAs(tester, 'finance.vn');
    await visit(tester, Routes.finance, '60_phan_tich_tai_chinh', after: () async {
      final tabs = find.byType(Tab);
      for (var i = 1; i < tabs.evaluate().length && i < 4; i++) {
        await tester.tap(tabs.at(i));
        await shot(tester, '60_phan_tich_tai_chinh_tab_$i');
      }
    });
    await visit(tester, Routes.reportSubmissions, '61_bao_cao_gui_cap_tren_tc');
    await visit(tester, Routes.suppliers, '62_nha_cung_cap');
    await visit(tester, Routes.payrollRuns, '63_chot_luong');
    await visit(tester, Routes.payslips, '64_phieu_luong');
  });

  testWidgets('cấp tập đoàn', (tester) async {
    await pumpAs(tester, 'anonymous1606');
    await visit(tester, Routes.home, '70_man_chinh_tap_doan');
    await visit(tester, Routes.groupOverview, '71_tong_quan_tap_doan');
    await visit(tester, Routes.groupReport, '72_bao_cao_tap_doan');
    await visit(tester, Routes.approvals, '73_hop_duyet_chung');
    await visit(tester, Routes.projects, '74_du_an');
    await visit(tester, Routes.projectCharts, '75_bieu_do_du_an');
    await visit(tester, Routes.projectProposals, '76_de_xuat_du_an');
    await visit(tester, Routes.projectNew, '77_tao_du_an');
    await visit(tester, Routes.auditLog, '78_nhat_ky_kiem_toan');
    await visit(tester, Routes.orgTree, '79_so_do_to_chuc_tap_doan');
  });

  testWidgets('quản trị', (tester) async {
    await pumpAs(tester, 'admin.vn');
    await visit(tester, Routes.home, '80_man_chinh_quan_tri');
    await visit(tester, Routes.adminConsole, '81_quan_tri_du_lieu');
  });
}
