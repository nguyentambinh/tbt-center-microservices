/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session.dart';
import '../config/env.dart';
import '../network/api_client.dart';

/// Thông báo đẩy: đăng ký máy với server, nhận tin khi đang mở app
abstract interface class PushService {
  /// Gửi mã FCM của máy lên notification của khu vực
  Future<void> register(Session session, String language);

  /// Đăng xuất thì bỏ mã cũ, máy không nhận tin của người trước
  Future<void> unregister();

  /// Tin tới khi app đang mở (nội dung để hiện snackbar)
  Stream<String> get foreground;

  /// Người dùng bấm vào thông báo ngoài app
  Stream<void> get opened;
}

/// Dùng trong test, không gọi Firebase
class NoPushService implements PushService {
  const NoPushService();

  @override
  Future<void> register(Session session, String language) async {}

  @override
  Future<void> unregister() async {}

  @override
  Stream<String> get foreground => const Stream.empty();

  @override
  Stream<void> get opened => const Stream.empty();
}

class FcmPushService implements PushService {
  FcmPushService(this._dio);

  final Dio _dio;
  StreamSubscription<String>? _refresh;

  // Firebase chưa khởi tạo (test, máy không có Google Play) thì bỏ qua
  bool get _ready => Firebase.apps.isNotEmpty;

  @override
  Future<void> register(Session session, String language) async {
    if (!_ready) return;
    try {
      final messaging = FirebaseMessaging.instance;
      // Không chờ người dùng bấm hộp thoại quyền, lấy token vẫn được
      unawaited(messaging.requestPermission());
      // Token FCM cổ điển: API gửi v1 ở server nhận chắc chắn
      // ignore: deprecated_member_use
      final token = await messaging.getToken();
      if (token == null) return;
      Future<void> send(String value) => _dio.post<void>(
            '${Env.kongUrl(session.region)}/notification/devices',
            data: {'token': value, 'language': language},
          );
      await send(token);
      await _refresh?.cancel();
      // ignore: deprecated_member_use
      _refresh = messaging.onTokenRefresh.listen(send);
    } on Object catch (e) {
      // Thông báo đẩy là phụ, lỗi không chặn người dùng
      debugPrint('Không đăng ký được FCM: $e');
    }
  }

  @override
  Future<void> unregister() async {
    await _refresh?.cancel();
    _refresh = null;
    if (!_ready) return;
    try {
      // ignore: deprecated_member_use
      await FirebaseMessaging.instance.deleteToken();
    } on Object catch (e) {
      debugPrint('Không xóa được mã FCM: $e');
    }
  }

  @override
  Stream<String> get foreground => _ready
      ? FirebaseMessaging.onMessage.map((m) => m.notification?.body ?? '')
      : const Stream.empty();

  @override
  Stream<void> get opened {
    if (!_ready) return const Stream.empty();
    final controller = StreamController<void>();
    // Mở app từ thông báo khi app đã tắt hẳn
    FirebaseMessaging.instance.getInitialMessage().then((m) {
      if (m != null) controller.add(null);
    });
    controller.addStream(FirebaseMessaging.onMessageOpenedApp.map((_) {}));
    return controller.stream;
  }
}

final pushServiceProvider = Provider<PushService>((ref) => FcmPushService(ref.watch(apiClientProvider)));
