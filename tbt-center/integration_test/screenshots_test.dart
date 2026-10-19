/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/core/auth/auth_controller.dart';
import 'package:tbtcenter/core/locale/locale_providers.dart';

import 'e2e_helpers.dart';

// Đi qua từng màn để chụp hình cho báo cáo: in "SHOT:<tên>", script trên máy tính chụp bằng adb
Future<void> shot(WidgetTester tester, String name) async {
  await waitLoaded(tester);
  debugPrint('SHOT:$name');
  // Chờ script chụp xong rồi mới đi tiếp
  await Future<void>.delayed(const Duration(milliseconds: 3500));
  await tester.pump();
}

Future<void> back(WidgetTester tester) async {
  // Đang ở màn chính thì thôi, bấm Back ở đây là thoát app
  if (find.textContaining('Xin chào').evaluate().isNotEmpty) return;
  await tester.binding.handlePopRoute();
  await waitLoaded(tester);
}

Future<void> tapText(WidgetTester tester, String text) async {
  final f = find.text(text).last;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await waitLoaded(tester);
}

Future<void> tapTab(WidgetTester tester, int index) async {
  await tester.tap(find.byType(Tab).at(index));
  await waitLoaded(tester);
}

/// Chạm dòng thứ [index] trong danh sách đang hiện
Future<void> tapRow(WidgetTester tester, int index) async {
  final rows = find.byType(ListTile);
  await tester.tap(rows.at(index));
  await waitLoaded(tester);
}

Future<void> step(String name, Future<void> Function() body) async {
  try {
    await body();
  } on Object catch (e) {
    debugPrint('BO QUA $name: $e');
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('màn đăng nhập', (tester) async {
    SharedPreferences.setMockInitialValues({'language': 'vi'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sessionStoreProvider.overrideWithValue(MemoryStore(null)),
      ],
      child: const TbtApp(),
    ));
    await shot(tester, '01_dang_nhap');
  });

  testWidgets('ban điều hành: màn chính, kiểm toán', (tester) async {
    await pumpAs(tester, 'anonymous1606');
    await shot(tester, '02_man_chinh_ban_dieu_hanh');
    await step('cuon', () async {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
      await shot(tester, '03_man_chinh_ban_dieu_hanh_cuon');
    });
    await step('kiem toan', () async {
      await openHomeCard(tester, 'Sổ kiểm toán');
      await shot(tester, '30_so_kiem_toan');
      await back(tester);
    });
  });

  testWidgets('nhân viên: chấm công, phiếu lương, dự án, thông báo, cài đặt', (tester) async {
    await pumpAs(tester, 'employee.vn');
    await shot(tester, '04_man_chinh_nhan_vien');
    await step('cham cong', () async {
      await openHomeCard(tester, 'Chấm công & nghỉ phép');
      await shot(tester, '05_cham_cong');
      await tapTab(tester, 1);
      await shot(tester, '06_nghi_phep');
      await tapTab(tester, 2);
      await shot(tester, '07_tang_ca');
      await back(tester);
    });
    await step('phieu luong', () async {
      await openHomeCard(tester, 'Phiếu lương');
      await shot(tester, '08_phieu_luong');
      await back(tester);
    });
    await step('du an cua toi', () async {
      await openHomeCard(tester, 'Dự án của tôi');
      await shot(tester, '10_du_an_cua_toi');
      await back(tester);
    });
    await step('thong bao', () async {
      await tester.tap(find.text('Thông báo').last);
      await shot(tester, '11_thong_bao');
      await back(tester);
    });
    await step('cai dat', () async {
      await tester.tap(find.text('Cài đặt').last);
      await shot(tester, '12_cai_dat');
      await back(tester);
    });
  });

  testWidgets('HR: nhân viên, ứng viên, dự án', (tester) async {
    await pumpAs(tester, 'hr.vn');
    await shot(tester, '13_man_chinh_hr');
    await step('ho so nhan vien', () async {
      await openHomeCard(tester, 'Hồ sơ nhân viên');
      await shot(tester, '14_ho_so_nhan_vien');
      await tapRow(tester, 0);
      await shot(tester, '15_ho_so_nhan_vien_chi_tiet');
      await back(tester);
      await back(tester);
    });
    await step('ung vien', () async {
      await openHomeCard(tester, 'Ứng viên');
      await shot(tester, '16_ung_vien');
      await tapRow(tester, 0);
      await shot(tester, '17_ung_vien_chi_tiet');
      await back(tester);
      await back(tester);
    });
    await step('du an', () async {
      await openHomeCard(tester, 'Dự án và hợp đồng');
      await shot(tester, '18_du_an_hop_dong');
      await tapRow(tester, 0);
      await shot(tester, '19_du_an_chi_tiet');
      await back(tester);
      await back(tester);
    });
  });

  testWidgets('tài chính: thu chi, nhà cung cấp, báo cáo, chốt lương', (tester) async {
    await pumpAs(tester, 'finance.vn');
    await shot(tester, '20_man_chinh_tai_chinh');
    await step('tai chinh', () async {
      await openHomeCard(tester, 'Tài chính');
      await shot(tester, '21_tai_chinh');
      for (var i = 1; i < find.byType(Tab).evaluate().length && i < 4; i++) {
        await tapTab(tester, i);
        await shot(tester, '22_tai_chinh_tab_$i');
      }
      await back(tester);
    });
    await step('bao cao', () async {
      await openHomeCard(tester, 'Báo cáo tập đoàn');
      await shot(tester, '23_bao_cao_tap_doan');
      await back(tester);
    });
    await step('chot luong', () async {
      await openHomeCard(tester, 'Chốt lương');
      await shot(tester, '24_chot_luong');
      await tapRow(tester, 0);
      await shot(tester, '25_chot_luong_cac_buoc');
      await back(tester);
      await back(tester);
    });
  });

  testWidgets('chuyển lương: chọn người, cảnh báo đã nhận, nhật ký, các bước', (tester) async {
    await pumpAs(tester, 'finance.vn');
    await openHomeCard(tester, 'Chốt lương');
    await step('chon nguoi', () async {
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byType(CheckboxListTile).at(i));
        await tester.pump(const Duration(milliseconds: 300));
      }
      await shot(tester, '24_chot_luong');
    });
    await step('canh bao', () async {
      await tester.tap(find.text('Chuyển cho 2 người'));
      await tester.pump(const Duration(milliseconds: 600));
      // Chỉ chụp hộp cảnh báo rồi bấm Hủy: không chuyển tiền
      await tester.tap(find.widgetWithText(FilledButton, 'Chuyển'));
      for (var i = 0; i < 100 && find.text('Có người đã nhận lương kỳ này').evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pump(const Duration(milliseconds: 500));
      debugPrint('SHOT:24_chot_luong_canh_bao');
      await Future<void>.delayed(const Duration(milliseconds: 3500));
      await tester.tap(find.text('Hủy').last);
      await waitLoaded(tester);
    });
    await step('nhat ky', () async {
      await tester.tap(find.text('Nhật ký'));
      await waitLoaded(tester);
      await shot(tester, '24_chot_luong_nhat_ky');
    });
    await step('cac buoc', () async {
      await tester.tap(find.text('Các đợt'));
      await waitLoaded(tester);
      await tapRow(tester, 0);
      await shot(tester, '25_chot_luong_cac_buoc');
    });
  });

  testWidgets('kho tri thức: hỏi AI, tìm bài, đồ thị, bản thể học, SPARQL, đề xuất', (tester) async {
    await pumpAs(tester, 'hr.vn');
    await openHomeCard(tester, 'Kho tri thức');
    await shot(tester, '26_hoi_ai');
    await step('hoi ai', () async {
      await tester.tap(find.text('Ai duyệt đơn nghỉ phép của tôi?').first);
      await waitLoaded(tester);
      await shot(tester, '27_hoi_ai_tra_loi');
    });
    await step('tim bai', () async {
      await tester.tap(find.text('Tìm bài'));
      await shot(tester, '28_tim_bai');
    });
    await step('do thi', () async {
      await tester.tap(find.text('Đồ thị'));
      await shot(tester, '29_do_thi_tri_thuc');
    });
    await step('ban the hoc', () async {
      await tester.tap(find.byTooltip('Thêm'));
      await waitLoaded(tester);
      await tester.tap(find.text('Bản thể học'));
      await shot(tester, '31_ban_the_hoc');
      await back(tester);
    });
    await step('sparql', () async {
      await tester.tap(find.byTooltip('Thêm'));
      await waitLoaded(tester);
      await tester.tap(find.text('Truy vấn SPARQL'));
      await waitLoaded(tester);
      await tester.tap(find.text('Chốt lương cần service nào'));
      await shot(tester, '32_sparql');
      await back(tester);
    });
    await step('de xuat', () async {
      await tester.tap(find.byTooltip('Thêm'));
      await waitLoaded(tester);
      await tester.tap(find.text('Đề xuất từ AI'));
      await shot(tester, '33_de_xuat_ai');
      await back(tester);
    });
  });

  testWidgets('ứng viên: hồ sơ ứng tuyển của tôi', (tester) async {
    await pumpAs(tester, 'ungvien.cv');
    await shot(tester, '34_man_chinh_ung_vien');
    await step('ho so', () async {
      await openHomeCard(tester, 'Hồ sơ ứng tuyển của tôi');
      await shot(tester, '35_ho_so_ung_tuyen');
    });
  });
}
