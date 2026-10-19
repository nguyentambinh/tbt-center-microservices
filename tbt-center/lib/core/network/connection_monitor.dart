/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';

enum ConnectionStatus { online, unstable, offline, serverUnreachable }

class ConnectionSnapshot {
  const ConnectionSnapshot(this.status, {this.retrying = false, this.recovered = false});

  final ConnectionStatus status;
  final bool retrying;

  /// Vừa có mạng lại, hiện thanh xanh vài giây rồi ẩn.
  final bool recovered;

  bool get isDown => status == ConnectionStatus.offline || status == ConnectionStatus.serverUnreachable;
}

/// Kiểm tra một địa chỉ có trả lời không. Tách riêng để test thay được.
class ConnectionProbe {
  ConnectionProbe()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          validateStatus: (_) => true,
        ));

  final Dio _dio;

  Future<bool> reachable(String url) async {
    try {
      await _dio.get<void>(url);
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> internet() => reachable(Env.publicIpUrl);

  Future<bool> server() => reachable(Env.geoUrl);
}

final connectionProbeProvider = Provider<ConnectionProbe>((ref) => ConnectionProbe());

/// Theo dõi tình trạng kết nối từ kết quả của mọi request qua ApiClient.
/// Mất kết nối thì tự thử lại sau 2, 4, 8… tối đa 30 giây.
class ConnectionMonitor extends Notifier<ConnectionSnapshot> {
  static const slowThreshold = Duration(seconds: 4);
  static const recoveredVisible = Duration(seconds: 2);

  Timer? _retryTimer;
  Timer? _recoveredTimer;
  int _attempt = 0;

  @override
  ConnectionSnapshot build() {
    ref.onDispose(() {
      _retryTimer?.cancel();
      _recoveredTimer?.cancel();
    });
    return const ConnectionSnapshot(ConnectionStatus.online);
  }

  void reportSuccess(Duration elapsed) {
    _retryTimer?.cancel();
    _attempt = 0;
    if (state.isDown) {
      state = const ConnectionSnapshot(ConnectionStatus.online, recovered: true);
      _recoveredTimer?.cancel();
      _recoveredTimer = Timer(recoveredVisible, () {
        if (state.recovered) state = const ConnectionSnapshot(ConnectionStatus.online);
      });
    } else if (elapsed > slowThreshold) {
      state = const ConnectionSnapshot(ConnectionStatus.unstable);
    } else if (state.status == ConnectionStatus.unstable) {
      state = const ConnectionSnapshot(ConnectionStatus.online);
    }
  }

  Future<void> reportConnectionFailure() async {
    // Phân biệt máy mất mạng hẳn với chỉ riêng máy chủ không trả lời.
    final hasInternet = await ref.read(connectionProbeProvider).internet();
    if (!ref.mounted) return;
    state = ConnectionSnapshot(hasInternet ? ConnectionStatus.serverUnreachable : ConnectionStatus.offline);
    _scheduleRetry();
  }

  Future<void> retryNow() async {
    if (state.retrying) return;
    _retryTimer?.cancel();
    state = ConnectionSnapshot(state.status, retrying: true);
    final reachable = await ref.read(connectionProbeProvider).server();
    if (!ref.mounted) return;
    if (reachable) {
      reportSuccess(Duration.zero);
    } else {
      await reportConnectionFailure();
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    final seconds = min(30, 2 << min(_attempt, 4));
    _attempt++;
    _retryTimer = Timer(Duration(seconds: seconds), retryNow);
  }
}

final connectionMonitorProvider =
    NotifierProvider<ConnectionMonitor, ConnectionSnapshot>(ConnectionMonitor.new);
