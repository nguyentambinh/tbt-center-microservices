/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter_test/flutter_test.dart';
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
}
