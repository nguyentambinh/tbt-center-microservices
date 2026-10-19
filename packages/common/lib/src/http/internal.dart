/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../discovery/eureka.dart';
import 'middleware.dart';

/// Đường dẫn chỉ dành cho service gọi service trong cùng khu vực.
bool isInternalPath(Uri uri) => uri.path.startsWith('/internal/');

/// Chặn lời gọi nội bộ không có `X-Internal-Token` đúng. Kong chuyển mọi
/// đường dẫn của service ra ngoài, nên `/internal/...` phải tự bảo vệ.
Middleware requireInternalToken([String? token]) {
  final expected = token ?? Platform.environment['INTERNAL_TOKEN'] ?? '';
  return (handler) {
    return (context) {
      final given = context.request.headers['x-internal-token'] ?? '';
      if (expected.isEmpty || !sameSecret(given, expected)) {
        return apiError(401, 'unauthorized', 'Internal token required');
      }
      return handler(context);
    };
  };
}

/// So sánh không dừng sớm ở ký tự sai đầu tiên, để không đoán dần được bí
/// mật qua thời gian phản hồi.
bool sameSecret(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

/// Lỗi khi gọi service khác: mất kết nối, quá hạn, hoặc trả mã lỗi.
class InternalCallException implements Exception {
  const InternalCallException(
    this.service,
    this.message, {
    this.statusCode,
    this.body = const {},
  });

  final String service;
  final String message;
  final int? statusCode;

  /// Thân câu trả lời lỗi, ví dụ các khoản đã chi trước khi ngân hàng lỗi.
  final Map<String, dynamic> body;

  @override
  String toString() => '$service: $message';
}

/// Gọi service khác trong mạng nội bộ của khu vực, kèm token và
/// `X-Correlation-Id` để lần vết một nghiệp vụ đi qua nhiều service.
class InternalClient {
  InternalClient(
    this.service,
    this.baseUrl, {
    String? token,
    this.timeout = const Duration(seconds: 20),
    EurekaClient? discovery,
  }) : _token = token ?? Platform.environment['INTERNAL_TOKEN'] ?? '',
       discovery = discovery ?? EurekaClient.shared;

  /// Sổ đăng ký service; null thì luôn gọi [baseUrl]
  final EurekaClient? discovery;

  final String service;
  final Uri baseUrl;
  final Duration timeout;
  final String _token;
  final _http = HttpClient()..connectionTimeout = const Duration(seconds: 5);

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    String? correlationId,
  }) => _send('GET', path, query: query, correlationId: correlationId);

  Future<Map<String, dynamic>> post(
    String path,
    Object body, {
    String? correlationId,
  }) => _send('POST', path, body: body, correlationId: correlationId);

  Future<Map<String, dynamic>> delete(
    String path,
    Object body, {
    String? correlationId,
  }) => _send('DELETE', path, body: body, correlationId: correlationId);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    String? correlationId,
  }) async {
    // Có Eureka thì gọi lần lượt các bản đang chạy; hỏi không được thì dùng địa chỉ cố định
    final discovered = await _discover();
    try {
      return await _sendTo(
        discovered ?? baseUrl,
        method,
        path,
        query,
        body,
        correlationId,
      );
    } on InternalCallException catch (e) {
      // Bản lấy từ Eureka vừa tắt (chưa kịp gỡ khỏi sổ) thì thử địa chỉ cố định
      if (discovered == null || e.statusCode != null) rethrow;
      return _sendTo(baseUrl, method, path, query, body, correlationId);
    }
  }

  Future<Uri?> _discover() async {
    final eureka = discovery;
    if (eureka == null) return null;
    try {
      return await eureka.pick(service);
    } on Object {
      return null;
    }
  }

  Future<Map<String, dynamic>> _sendTo(
    Uri base,
    String method,
    String path,
    Map<String, String>? query,
    Object? body,
    String? correlationId,
  ) async {
    final url = base.resolve(path).replace(queryParameters: query);
    try {
      final request = await _http.openUrl(method, url);
      request.headers
        ..set('x-internal-token', _token)
        ..set('x-correlation-id', correlationId ?? currentCorrelationId ?? '-')
        ..contentType = ContentType.json;
      if (body != null) request.add(utf8.encode(jsonEncode(body)));
      final response = await request.close().timeout(timeout);
      final text = await utf8.decodeStream(response);
      final json = text.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(text) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        throw InternalCallException(
          service,
          json['message'] as String? ?? 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
          body: json,
        );
      }
      return json;
    } on InternalCallException {
      rethrow;
    } on Exception catch (e) {
      throw InternalCallException(service, e.toString());
    }
  }
}
