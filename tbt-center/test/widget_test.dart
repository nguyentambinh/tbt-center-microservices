/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbtcenter/core/locale/geo_service.dart';
import 'package:tbtcenter/core/theme/role_gem.dart';

import 'helpers.dart';

const _germany = GeoResult(country: 'DE', region: 'de', language: 'de');

void main() {
  testWidgets('chưa đăng nhập thì vào màn đăng nhập', (tester) async {
    await pumpApp(tester, language: 'vi');
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Ứng tuyển · tạo tài khoản'), findsOneWidget);
  });

  testWidgets('màn đăng nhập không có nút xem bộ màu', (tester) async {
    await pumpApp(tester, language: 'vi');
    expect(find.text('Xem các bộ màu đá quý'), findsNothing);
  });

  testWidgets('IP ở Đức thì app tự sang tiếng Đức và khu vực Đức', (tester) async {
    await pumpApp(tester, geo: _germany);
    expect(find.text('Anmelden'), findsOneWidget);
    expect(find.text('Ihre Daten werden in der Region Deutschland gespeichert'), findsOneWidget);
  });

  testWidgets('ngôn ngữ tự chọn được ưu tiên hơn IP', (tester) async {
    final gateway = FakeAuthGateway();
    await pumpApp(tester, language: 'pt', geo: _germany, gateway: gateway);
    expect(find.text('Entrar'), findsOneWidget);
    // Trang đăng nhập Keycloak mở bằng tiếng Bồ Đào Nha.
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(gateway.lastLocale, 'pt');
  });

  testWidgets('đăng nhập hr.vn thì vào màn chính với vai trò Nhân sự, đăng xuất thì quay lại', (tester) async {
    final gateway = FakeAuthGateway();
    final store = MemorySessionStore();
    await pumpApp(tester, language: 'vi', gateway: gateway, store: store);

    await tester.tap(find.text('Đăng nhập'));
    await tester.pumpAndSettle();
    // Trang đăng nhập Keycloak mở cùng ngôn ngữ với app.
    expect(gateway.lastLocale, 'vi');
    expect(find.text('Xin chào, Nhan'), findsOneWidget);
    expect(find.textContaining('Nhân sự'), findsOneWidget);
    expect(find.textContaining('Việt Nam'), findsOneWidget);
    expect(store.session, isNotNull);

    await tester.tap(find.byTooltip('Đăng xuất'));
    await tester.pumpAndSettle();
    expect(find.text('Đăng xuất khỏi TBT Center?'), findsOneWidget);
    await tester.tap(find.text('Đăng xuất').last);
    await tester.pumpAndSettle();
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(store.session, isNull);
    expect(gateway.signedOut, isTrue);
  });

  testWidgets('đã có phiên lưu trên máy thì vào thẳng màn chính', (tester) async {
    await pumpApp(tester, language: 'vi', store: MemorySessionStore(fakeSession()));
    expect(find.text('Xin chào, Nhan'), findsOneWidget);
  });

  testWidgets('phiên hết hạn và không làm mới được thì về màn đăng nhập', (tester) async {
    final expired = fakeSession(validFor: const Duration(minutes: -5));
    await pumpApp(tester, language: 'vi', store: MemorySessionStore(expired));
    expect(find.text('Đăng nhập'), findsOneWidget);
  });

  test('vai trò map đúng đá quý', () {
    expect(RoleGem.forRole('hr'), RoleGem.emerald);
    expect(RoleGem.forRole('finance'), RoleGem.ruby);
    expect(RoleGem.forRole('candidate'), RoleGem.diamond);
    expect(RoleGem.forRole('la'), RoleGem.gold);
  });

  test('đọc vai trò và khu vực từ token, chọn vai trò chính', () {
    final session = fakeSession(token: fakeJwt(roles: ['admin', 'executive'], region: 'de'));
    expect(session.roles, ['executive', 'admin']);
    expect(session.primaryRole, 'executive');
    expect(session.gem, RoleGem.gold);
    expect(session.region, 'de');
  });

  testWidgets('chọn giao diện Sáng, Tối trong Cài đặt thì đổi ngay và lưu trên máy', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await pumpApp(tester, language: 'vi');
    await tester.tap(find.byTooltip('Cài đặt'));
    await tester.pumpAndSettle();
    expect(find.text('Theo điện thoại'), findsOneWidget);

    await tester.ensureVisible(find.text('Sáng'));
    await tester.tap(find.text('Sáng'));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Sáng'))).brightness, Brightness.light);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'light');

    await tester.ensureVisible(find.text('Tối'));
    await tester.tap(find.text('Tối'));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Sáng'))).brightness, Brightness.dark);
    expect(prefs.getString('theme_mode'), 'dark');

    await tester.tap(find.text('Theo điện thoại'));
    await tester.pumpAndSettle();
    expect(prefs.getString('theme_mode'), isNull);
  });

  testWidgets('Change Manual IP ở màn đăng nhập: chọn IP nước khác thì lưu và dò lại khu vực', (tester) async {
    await pumpApp(tester, language: 'vi');
    await tester.tap(find.text('Change Manual IP'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('IP không hợp lệ'), findsOneWidget);

    await tester.tap(find.text('Đức'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '85.214.0.1');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('geo_simulated_ip'), '85.214.0.1');
    expect(find.text('Đang giả lập IP 85.214.0.1'), findsOneWidget);

    // Đợi thanh thông báo tắt rồi mới bấm lại nút ở góc dưới
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change Manual IP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dùng IP thật'));
    await tester.pumpAndSettle();
    expect(prefs.getString('geo_simulated_ip'), isNull);
  });
}
