/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/core/auth/auth_controller.dart';
import 'package:tbtcenter/core/auth/auth_gateway.dart';
import 'package:tbtcenter/core/auth/session.dart';
import 'package:tbtcenter/core/locale/locale_providers.dart';
import 'package:tbtcenter/core/widgets/motion.dart';

// E2E: đăng nhập thật qua Keycloak, app gọi Kong thật
const e2ePassword = String.fromEnvironment('TBT_TEST_PASSWORD');

Future<Session> login(String username, {String? password}) async {
  final http = HttpClient();
  final request = await http.postUrl(Uri.parse('http://localhost:8180/realms/tbt/protocol/openid-connect/token'));
  request.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
  request.write(Uri(queryParameters: {
    'grant_type': 'password',
    'client_id': 'tbt-dev-cli',
    'username': username,
    'password': password ?? e2ePassword,
  }).query);
  final response = await request.close();
  final json = jsonDecode(await utf8.decodeStream(response)) as Map<String, dynamic>;
  http.close();
  if (response.statusCode != 200) throw StateError('Không đăng nhập được $username: ${json['error']}');
  return Session(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String?,
    expiresAt: DateTime.now().add(Duration(seconds: json['expires_in'] as int)),
  );
}

class MemoryStore implements SessionStore {
  MemoryStore(this.session);

  Session? session;

  @override
  Future<Session?> read() async => session;

  @override
  Future<void> write(Session value) async => session = value;

  @override
  Future<void> clear() async => session = null;
}

class PasswordGateway implements AuthGateway {
  PasswordGateway(this.username);

  final String username;

  @override
  Future<Session> signIn({bool register = false, String? locale}) => login(username);

  @override
  Future<Session> refresh(Session session) => login(username);

  @override
  Future<void> signOut(Session session) async {}
}

/// Chờ tới khi hết skeleton, vòng xoay; trả thời gian chờ
Future<Duration> waitLoaded(WidgetTester tester) async {
  final watch = Stopwatch()..start();
  while (watch.elapsed < const Duration(seconds: 25)) {
    await tester.pump(const Duration(milliseconds: 100));
    final loading = find.byType(SkeletonList).evaluate().isNotEmpty ||
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    if (!loading) break;
  }
  await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 10));
  return watch.elapsed;
}

/// Tiêu đề các thẻ chức năng trên màn chính
List<String> homeCards(WidgetTester tester) => [
      for (final tile in tester.widgetList<ListTile>(find.descendant(of: find.byType(Card), matching: find.byType(ListTile))))
        if (tile.title case Text(:final data?)) data,
    ];

Future<void> pumpAs(WidgetTester tester, String username, {String language = 'vi', List extraOverrides = const []}) async {
  SharedPreferences.setMockInitialValues({'language': language});
  final prefs = await SharedPreferences.getInstance();
  final session = await login(username);
  await tester.pumpWidget(ProviderScope(
    // Key mới để mỗi tài khoản dựng lại app từ đầu
    key: UniqueKey(),
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      sessionStoreProvider.overrideWithValue(MemoryStore(session)),
      authGatewayProvider.overrideWithValue(PasswordGateway(username)),
      ...extraOverrides,
    ],
    child: const TbtApp(),
  ));
  await waitLoaded(tester);
}


/// Cuộn thẻ ra giữa màn rồi bấm
Future<void> openHomeCard(WidgetTester tester, String title) async {
  final card = find.widgetWithText(ListTile, title);
  await tester.scrollUntilVisible(card, 300, scrollable: find.byType(Scrollable).first);
  await Scrollable.ensureVisible(tester.element(card), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(card);
  await waitLoaded(tester);
}

/// In chữ đang hiện trên màn, để xem khi test hỏng
void dumpTexts(WidgetTester tester, String label) {
  final texts = [
    for (final t in tester.widgetList<Text>(find.byType(Text)))
      if (t.data != null && t.data!.trim().isNotEmpty) t.data!,
  ];
  debugPrint('[$label] ${texts.join(' | ')}');
}
