/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'jwt_verifier.dart';

/// Vai trò đánh dấu cấp tập đoàn: đi kèm executive, admin, hr, finance,
/// cho phép làm việc với dữ liệu mọi khu vực
const groupRole = 'group';

/// Thông tin người gọi lấy từ access token Keycloak.
///
/// Lớp này chỉ đọc nội dung token. Chữ ký, hạn đã được Kong kiểm, và
/// `requireClaims` kiểm lần hai bằng [JwtVerifier] khi có cấu hình JWKS.
class Claims {
  Claims(this._payload);

  final Map<String, dynamic> _payload;

  /// Đọc từ header `Authorization: Bearer <jwt>`, `null` nếu không có hoặc sai dạng.
  static Claims? fromAuthorization(String? header) {
    if (header == null || !header.startsWith('Bearer ')) return null;
    final parts = header.substring(7).split('.');
    if (parts.length != 3) return null;
    try {
      final json = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return Claims(jsonDecode(json) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  String get subject => _payload['sub'] as String? ?? '';
  String get username => _payload['preferred_username'] as String? ?? subject;
  String? get region => _payload['region'] as String?;
  String? get countryCode => _payload['country_code'] as String?;

  /// Mã nhân viên gắn với tài khoản (thuộc tính `employee_id` trong Keycloak).
  String? get employeeId => _payload['employee_id'] as String?;

  /// Họ tên, email, số điện thoại khai lúc đăng ký tài khoản
  String? get fullName => _payload['name'] as String? ?? _payload['given_name'] as String?;
  String? get email => _payload['email'] as String?;
  String? get phone => _payload['phone_number'] as String?;

  /// Hạn truy cập của tài khoản kiểm toán độc lập (thuộc tính `access_until`
  /// trong Keycloak, dạng YYYY-MM-DD).
  String? get accessUntil => _payload['access_until'] as String?;

  Set<String> get roles {
    final realm = _payload['realm_access'];
    if (realm is! Map) return const {};
    return {...(realm['roles'] as List? ?? const []).cast<String>()};
  }

  bool hasAnyRole(Iterable<String> wanted) => wanted.any(roles.contains);

  /// Tài khoản cấp tập đoàn (văn phòng, admin, HR, tài chính tập đoàn)
  bool get isGroup => roles.contains(groupRole);
}
