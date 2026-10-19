/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/core/auth/auth_controller.dart';
import 'package:tbtcenter/core/auth/auth_gateway.dart';
import 'package:tbtcenter/core/auth/session.dart';
import 'package:tbtcenter/core/locale/geo_service.dart';
import 'package:tbtcenter/core/locale/locale_providers.dart';
import 'package:tbtcenter/core/network/connection_monitor.dart';
import 'package:tbtcenter/core/push/push_service.dart';
import 'package:tbtcenter/features/notification/domain/entities/app_notification.dart';
import 'package:tbtcenter/features/notification/domain/repositories/notification_repository.dart';
import 'package:tbtcenter/features/notification/presentation/providers/notification_providers.dart';

/// Tạo access token giả có cùng dạng với token Keycloak (không có chữ ký thật).
String fakeJwt({
  String username = 'hr.vn',
  List<String> roles = const ['hr', 'employee'],
  String region = 'vn',
  String givenName = 'Nhan',
}) {
  String part(Map<String, dynamic> json) => base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'RS256'})}.${part({
    'sub': 'id-$username',
    'preferred_username': username,
    'given_name': givenName,
    'region': region,
    'country_code': region.toUpperCase(),
    'realm_access': {'roles': [...roles, 'default-roles-tbt']},
  })}.chu-ky';
}

Session fakeSession({String token = '', Duration validFor = const Duration(minutes: 15), List<String>? roles}) {
  return Session(
    accessToken: token.isEmpty ? fakeJwt(roles: roles ?? const ['hr', 'employee']) : token,
    refreshToken: 'refresh',
    idToken: 'id',
    expiresAt: DateTime.now().add(validFor),
  );
}

class MemorySessionStore implements SessionStore {
  MemorySessionStore([this.session]);

  Session? session;

  @override
  Future<Session?> read() async => session;

  @override
  Future<void> write(Session value) async => session = value;

  @override
  Future<void> clear() async => session = null;
}

class FakeAuthGateway implements AuthGateway {
  Session Function() onSignIn = fakeSession;
  Session Function(Session)? onRefresh;
  int refreshCount = 0;
  bool signedOut = false;

  /// Ngôn ngữ app gửi kèm lần đăng nhập gần nhất.
  String? lastLocale;

  @override
  Future<Session> signIn({bool register = false, String? locale}) async {
    lastLocale = locale;
    return onSignIn();
  }

  @override
  Future<Session> refresh(Session session) async {
    refreshCount++;
    final handler = onRefresh;
    if (handler == null) throw const SessionExpired();
    return handler(session);
  }

  @override
  Future<void> signOut(Session session) async => signedOut = true;
}

class FakeProbe extends ConnectionProbe {
  bool internetUp = false;
  bool serverUp = false;

  @override
  Future<bool> internet() async => internetUp;

  @override
  Future<bool> server() async => serverUp;
}

/// Hộp thông báo giả; mặc định trống để màn chính không gọi mạng.
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository([this.items = const []]);

  List<AppNotification> items;
  int markAllCalls = 0;

  @override
  Future<Inbox> inbox() async => Inbox(items: items, unread: items.where((n) => !n.read).length);

  @override
  Future<void> markAllRead() async {
    markAllCalls++;
    items = [
      for (final n in items) AppNotification(id: n.id, kind: n.kind, params: n.params, createdAt: n.createdAt, read: true),
    ];
  }
}

/// Các override để app chạy trong test mà không gọi mạng, không cần plugin Android.
Future<List<Override>> testOverrides({
  String? language,
  GeoResult? geo,
  SessionStore? store,
  AuthGateway? gateway,
  ConnectionProbe? probe,
  NotificationRepository? notifications,
}) async {
  SharedPreferences.setMockInitialValues({'language': ?language});
  final prefs = await SharedPreferences.getInstance();
  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    geoProvider.overrideWith((ref) async => geo),
    sessionStoreProvider.overrideWithValue(store ?? MemorySessionStore()),
    authGatewayProvider.overrideWithValue(gateway ?? FakeAuthGateway()),
    connectionProbeProvider.overrideWithValue(probe ?? FakeProbe()),
    notificationRepositoryProvider.overrideWithValue(notifications ?? FakeNotificationRepository()),
    pushServiceProvider.overrideWithValue(const NoPushService()),
  ];
}

Future<void> pumpApp(
  WidgetTester tester, {
  String? language,
  GeoResult? geo,
  SessionStore? store,
  AuthGateway? gateway,
  ConnectionProbe? probe,
}) async {
  final overrides = await testOverrides(
      language: language, geo: geo, store: store, gateway: gateway, probe: probe);
  await tester.pumpWidget(ProviderScope(overrides: overrides, child: const TbtApp()));
  await tester.pumpAndSettle();
}

/// Bấm một thẻ ở màn chính; cuộn tới thẻ trước vì danh sách thẻ dài hơn màn hình test.
Future<void> openHomeCard(WidgetTester tester, String title) async {
  final card = find.widgetWithText(ListTile, title);
  await tester.scrollUntilVisible(card, 200, scrollable: find.byType(Scrollable).first);
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  await tester.tap(card);
  await tester.pumpAndSettle();
}
