/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_controller.dart';
import '../config/env.dart';
import '../error/app_failure.dart';
import 'connection_monitor.dart';
import 'response_cache.dart';

/// Dio duy nhất của app. Mọi lời gọi mạng đi qua đây để cùng được gắn header,
/// báo tình trạng kết nối và dùng cache khi mất mạng.
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 15),
  ));
  dio.interceptors.add(_TbtInterceptor(ref, dio));
  return dio;
});

/// Đặt `extra: {noCache: true}` cho request không muốn lưu cache.
const noCache = 'noCache';
const fromCache = 'fromCache';
const cachedAt = 'cachedAt';

/// Request vốn lâu (AI trả lời) thì không tính là mạng chậm.
const slowExpected = 'slowExpected';

class _TbtInterceptor extends Interceptor {
  _TbtInterceptor(this._ref, this._dio);

  final Ref _ref;
  final Dio _dio;
  static const _uuid = Uuid();
  static const _writeMethods = {'POST', 'PUT', 'PATCH', 'DELETE'};

  ConnectionMonitor get _monitor => _ref.read(connectionMonitorProvider.notifier);
  AuthController get _auth => _ref.read(authControllerProvider.notifier);
  ResponseCache get _cache => _ref.read(responseCacheProvider);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['X-Correlation-Id'] = _uuid.v4();
    if (Env.isKongUrl(options.uri)) {
      final token = await _auth.validAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    if (_writeMethods.contains(options.method)) {
      // Gửi lại cùng một thao tác (bấm hai lần, mạng chập chờn) thì server nhận ra và không ghi trùng.
      options.headers.putIfAbsent('Idempotency-Key', _uuid.v4);
    }
    options.extra['startedAt'] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final started = response.requestOptions.extra['startedAt'] as DateTime?;
    final slowOk = response.requestOptions.extra[slowExpected] == true;
    _monitor.reportSuccess(started == null || slowOk ? Duration.zero : DateTime.now().difference(started));
    if (_cacheable(response.requestOptions) && (response.statusCode ?? 0) < 300) {
      _cache.write(_key(response.requestOptions), response.data);
    }
    handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final failure = AppFailure.fromDio(err);
    if (failure.kind == FailureKind.unauthorized && Env.isKongUrl(err.requestOptions.uri)) {
      final retried = await _retryWithFreshToken(err.requestOptions);
      if (retried != null) {
        handler.resolve(retried);
        return;
      }
    }
    if (!failure.isConnectionProblem) {
      handler.next(err.copyWith(error: failure));
      return;
    }

    _monitor.reportConnectionFailure();
    final options = err.requestOptions;

    if (_cacheable(options)) {
      final cached = _cache.read(_key(options));
      if (cached != null) {
        handler.resolve(Response(
          requestOptions: options,
          data: cached.data,
          statusCode: 200,
          extra: {fromCache: true, cachedAt: cached.savedAt},
        ));
        return;
      }
    }

    final kind = _writeMethods.contains(options.method) ? FailureKind.offlineWrite : failure.kind;
    handler.next(err.copyWith(error: AppFailure(kind)));
  }

  /// Token bị từ chối: làm mới một lần rồi gửi lại. Vẫn bị từ chối thì kết thúc phiên.
  Future<Response<dynamic>?> _retryWithFreshToken(RequestOptions options) async {
    if (options.extra['retriedAuth'] == true) {
      await _auth.expire();
      return null;
    }
    final token = await _auth.validAccessToken(forceRefresh: true);
    if (token == null) return null;
    options.extra['retriedAuth'] = true;
    try {
      return await _dio.fetch<dynamic>(options);
    } on DioException {
      return null;
    }
  }

  bool _cacheable(RequestOptions options) => options.method == 'GET' && options.extra[noCache] != true;

  String _key(RequestOptions options) => '${options.method} ${options.uri}';
}
