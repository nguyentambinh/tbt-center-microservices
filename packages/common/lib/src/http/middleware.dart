/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dart_frog/dart_frog.dart';

import 'claims.dart';
import 'jwt_verifier.dart';

/// Lỗi trả về cho app theo một dạng chung: `{"code": ..., "message": ...}`.
Response apiError(int status, String code, String message) =>
    Response.json(statusCode: status, body: {'code': code, 'message': message});

/// Trả lại `X-Correlation-Id` cho app và bắt mọi lỗi chưa xử lý thành 500,
/// ghi log kèm mã để lần vết từ app → Kong → service.
Middleware correlationAndErrors() {
  return (handler) {
    return (context) async {
      final given = context.request.headers['x-correlation-id'];
      final id = given == null || given.isEmpty || given == '-'
          ? newCorrelationId()
          : given;
      // Đặt vào Zone: InternalClient gọi service khác tự gửi kèm id này
      return withCorrelationId(id, () async {
        try {
          final response = await handler(context);
          return response.copyWith(
            headers: {...response.headers, 'x-correlation-id': id},
          );
        } on Object catch (error, stack) {
          stderr.writeln('[$id] ${context.request.uri}: $error\n$stack');
          return apiError(
            500,
            'internal',
            'Internal server error',
          ).copyWith(headers: {'x-correlation-id': id});
        }
      });
    };
  };
}

const _correlationKey = #tbtCorrelationId;

/// Correlation id của request đang xử lý, đi theo cả việc nền tạo trong request
String? get currentCorrelationId => Zone.current[_correlationKey] as String?;

/// Chạy [body] với correlation id [id], ví dụ Saga chạy tiếp không qua request
R withCorrelationId<R>(String id, R Function() body) =>
    runZoned(body, zoneValues: {_correlationKey: id});

final _random = Random.secure();

String newCorrelationId() {
  final bytes = List.generate(8, (_) => _random.nextInt(256));
  return 'tbt-${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
}

/// Bắt buộc có token; [anyRole] là các vai trò được phép;
/// [region] là khu vực của service: người khu vực khác không đọc được dữ liệu ở đây.
/// [allowNoRegion] cho token chưa gắn khu vực (ứng viên tự đăng ký nộp hồ sơ
/// về khu vực theo IP) đi qua.
///
/// Có [verifier] (mặc định đọc `JWT_JWKS_URL`, `JWT_ISSUER`) thì kiểm chữ ký
/// và hạn của token lần nữa ở service, không chỉ tin Kong.
Middleware requireClaims({
  Set<String> anyRole = const {},
  String? region,
  bool allowNoRegion = false,
  JwtVerifier? verifier,
}) {
  final jwt = verifier ?? _environmentVerifier;
  return (handler) {
    return (context) async {
      final header = context.request.headers['authorization'];
      final claims = Claims.fromAuthorization(header);
      if (claims == null) {
        return apiError(401, 'unauthorized', 'Missing or invalid token');
      }
      if (jwt != null) {
        final String? rejected;
        try {
          rejected = await jwt.check(header!.substring(7));
        } on Exception catch (e) {
          // Chưa tải được khóa công khai (Hub mất kết nối lúc service vừa bật).
          stderr.writeln('Không kiểm được token: $e');
          return apiError(503, 'auth_unavailable', 'Cannot verify token now');
        }
        if (rejected != null) {
          return apiError(401, 'unauthorized', 'Token rejected: $rejected');
        }
      }
      final noRegionAllowed = allowNoRegion && claims.region == null;
      if (region != null && claims.region != region && !noRegionAllowed) {
        return apiError(
          403,
          'region_mismatch',
          'Data belongs to another region',
        );
      }
      if (anyRole.isNotEmpty && !claims.hasAnyRole(anyRole)) {
        return apiError(403, 'forbidden', 'Not allowed for your role');
      }
      return handler(context.provide<Claims>(() => claims));
    };
  };
}

/// Đọc cấu hình một lần cho cả service; bộ khóa công khai được nhớ lại.
final _environmentVerifier = JwtVerifier.fromEnvironment();
