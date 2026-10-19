/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/core/auth/auth_controller.dart';
import 'package:tbtcenter/core/config/env.dart';
import 'package:tbtcenter/core/error/app_failure.dart';
import 'package:tbtcenter/core/network/api_client.dart';
import 'package:tbtcenter/core/network/connection_monitor.dart';
import 'package:tbtcenter/core/network/response_cache.dart';

import 'helpers.dart';

/// Server giả: ghi lại header nhận được, trả 401 nếu token chưa đúng, hoặc giả mất mạng.
class FakeServer implements HttpClientAdapter {
  bool online = true;
  String? acceptedToken;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    if (!online) throw DioException.connectionError(requestOptions: options, reason: 'mất mạng');
    if (acceptedToken != null && options.headers['Authorization'] != 'Bearer $acceptedToken') {
      return ResponseBody.fromString('{"message":"invalid token"}', 401, headers: _json);
    }
    return ResponseBody.fromString(jsonEncode({'name': 'Lena Koch'}), 200, headers: _json);
  }

  static const _json = {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  };

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ApiClient', () {
    late ProviderContainer container;
    late FakeServer server;
    late Directory cacheDir;
    late FakeAuthGateway gateway;
    late MemorySessionStore store;
    final kong = Env.kongUrl('vn');

    setUp(() async {
      cacheDir = Directory.systemTemp.createTempSync('tbt_cache_test');
      server = FakeServer();
      gateway = FakeAuthGateway();
      store = MemorySessionStore(fakeSession(token: fakeJwt()));
      container = ProviderContainer(overrides: [
        ...await testOverrides(store: store, gateway: gateway),
        responseCacheProvider.overrideWithValue(ResponseCache(cacheDir)),
      ]);
      await container.read(authControllerProvider.future);
      container.read(apiClientProvider).httpClientAdapter = server;
    });

    tearDown(() {
      container.dispose();
      if (cacheDir.existsSync()) cacheDir.deleteSync(recursive: true);
    });

    test('mất mạng thì trả dữ liệu đã lưu và báo offline', () async {
      final dio = container.read(apiClientProvider);
      await dio.get<Object?>('$kong/hr/employees/1');

      server.online = false;
      final response = await dio.get<Map<String, dynamic>>('$kong/hr/employees/1');
      await Future<void>.delayed(Duration.zero);

      expect(response.data, {'name': 'Lena Koch'});
      expect(response.extra[fromCache], isTrue);
      expect(container.read(connectionMonitorProvider).status, ConnectionStatus.offline);
    });

    test('ghi khi mất mạng thì báo lỗi cần có mạng', () async {
      server.online = false;
      await expectLater(
        container.read(apiClientProvider).post<void>('$kong/hr/employees', data: {'name': 'x'}),
        throwsA(isA<DioException>().having((e) => (e.error! as AppFailure).kind, 'kind', FailureKind.offlineWrite)),
      );
    });

    test('token chỉ gắn cho request tới Kong, request ghi có Idempotency-Key', () async {
      final dio = container.read(apiClientProvider);
      await dio.get<Object?>('$kong/hr/');
      await dio.get<Object?>('https://api.ipify.org');
      await dio.post<Object?>('$kong/hr/employees', data: const {});

      expect(server.requests[0].headers['Authorization'], startsWith('Bearer '));
      expect(server.requests[1].headers.containsKey('Authorization'), isFalse);
      expect(server.requests[2].headers['Idempotency-Key'], isNotNull);
      expect(server.requests.every((r) => r.headers['X-Correlation-Id'] != null), isTrue);
    });

    test('bị 401 thì làm mới token một lần rồi gửi lại', () async {
      final newToken = fakeJwt(givenName: 'Moi');
      server.acceptedToken = newToken;
      gateway.onRefresh = (_) => fakeSession(token: newToken);

      final response = await container.read(apiClientProvider).get<Map<String, dynamic>>('$kong/hr/');

      expect(response.statusCode, 200);
      expect(gateway.refreshCount, 1);
      expect(store.session?.accessToken, newToken);
    });

    test('làm mới không được thì kết thúc phiên', () async {
      server.acceptedToken = 'khong-bao-gio-dung';
      await expectLater(
        container.read(apiClientProvider).get<Object?>('$kong/hr/'),
        throwsA(isA<DioException>()),
      );
      expect(container.read(authControllerProvider).value, isNull);
      expect(store.session, isNull);
    });
  });

  testWidgets('thanh báo mất mạng, bấm Kết nối lại thì báo đã kết nối', (tester) async {
    final probe = FakeProbe();
    await pumpApp(tester, language: 'vi', probe: probe);
    final container = ProviderScope.containerOf(tester.element(find.byType(TbtApp)));

    await container.read(connectionMonitorProvider.notifier).reportConnectionFailure();
    await tester.pumpAndSettle();
    expect(find.textContaining('Không có kết nối mạng'), findsOneWidget);

    probe.serverUp = true;
    await tester.tap(find.text('Kết nối lại'));
    await tester.pumpAndSettle();
    expect(find.text('Đã kết nối lại'), findsOneWidget);

    await tester.pump(ConnectionMonitor.recoveredVisible);
    await tester.pumpAndSettle();
    expect(find.text('Đã kết nối lại'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });
}
