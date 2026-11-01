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
import 'package:tbtcenter/core/auth/work_region.dart';
import 'package:tbtcenter/core/config/env.dart';
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

Future<void> tapText(WidgetTester tester, String text) async {
  final f = find.text(text).first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await waitLoaded(tester);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('HR bổ sung', (tester) async {
    await pumpAs(tester, 'hr.vn');
    await visit(tester, Routes.changeRequests, '47_yeu_cau_sua_ho_so');
    await visit(tester, Routes.attendance, '50_duyet_don_hr');
    await visit(tester, Routes.projectNew, '77_tao_du_an');
    await visit(tester, Routes.candidates, '57_ung_vien_phong_van', after: () async {
      try {
        await tapText(tester, 'Đang sàng lọc');
        await tester.tap(find.byType(ListTile).first);
        await waitLoaded(tester);
        await shot(tester, '57_ung_vien_sang_loc');
        await tapText(tester, 'Hẹn phỏng vấn');
        await shot(tester, '57_hen_phong_van');
      } on Object catch (e) {
        debugPrint('BO QUA hen: $e');
      }
    });
    await visit(tester, Routes.candidates, '57_ung_vien_cho_xac_nhan', after: () async {
      try {
        await tapText(tester, 'Phỏng vấn');
        await tester.tap(find.byType(ListTile).first);
        await waitLoaded(tester);
        await shot(tester, '57_ung_vien_da_hen');
      } on Object catch (e) {
        debugPrint('BO QUA da hen: $e');
      }
    });
  });

  testWidgets('ứng viên xác nhận giờ', (tester) async {
    await pumpAs(tester, 'ungvien.cv');
    await visit(tester, Routes.myApplication, '35_ho_so_ung_tuyen_moi');
  });

  testWidgets('nhân viên bổ sung', (tester) async {
    await pumpAs(tester, 'employee.vn');
    await visit(tester, Routes.attendance, '41_cham_cong_nhan_vien');
  });

  testWidgets('ứng viên màn chính', (tester) async {
    await pumpAs(tester, 'ungvien.cv');
    await visit(tester, Routes.home, '34_man_chinh_ung_vien');
  });

  testWidgets('HR xếp lịch', (tester) async {
    await pumpAs(tester, 'hr.vn');
    await visit(tester, Routes.scheduleManage, '90_xep_lich');
  });

  testWidgets('tập đoàn xem tất cả', (tester) async {
    await pumpAs(tester, 'anonymous1606');
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(workRegionProvider.notifier).select(Env.allRegions);
    await visit(tester, Routes.home, '91_tat_ca_man_chinh');
    await visit(tester, Routes.employees, '91_tat_ca_nhan_vien');
    await visit(tester, Routes.projects, '91_tat_ca_du_an');
  });

  testWidgets('quản trị vào tài khoản', (tester) async {
    await pumpAs(tester, 'admin.vn');
    await visit(tester, Routes.adminConsole, '92_quan_tri_tong_quan', after: () async {
      try {
        await tapText(tester, 'Tài khoản');
        await shot(tester, '92_tai_khoan');
        await tester.tap(find.byIcon(Icons.arrow_forward).first);
        await tester.pumpAndSettle();
        await shot(tester, '92_xac_nhan_vao_tai_khoan');
        await tapText(tester, 'Vào tài khoản này');
        await waitLoaded(tester);
        await shot(tester, '93_dang_xem_voi_tu_cach');
      } on Object catch (e) {
        debugPrint('BO QUA vao thay: $e');
      }
    });
  });
}
