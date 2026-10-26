/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import '../theme/role_gem.dart';

/// Vai trò nghiệp vụ, xếp theo mức ưu tiên khi một người có nhiều vai trò.
const businessRoles = ['executive', 'admin', 'finance', 'hr', 'employee', 'auditor', 'candidate'];

/// Vai trò của người làm trong công ty: có chấm công, phiếu lương, dự án.
/// Ứng viên và kiểm toán độc lập không thuộc nhóm này.
const staffRoles = {'executive', 'admin', 'finance', 'hr', 'employee'};

/// Phiên đăng nhập Keycloak. Thông tin người dùng đọc từ access token (JWT),
/// chữ ký token do Kong và service kiểm, app chỉ đọc để hiển thị.
class Session {
  Session({required this.accessToken, this.refreshToken, this.idToken, required this.expiresAt})
      : claims = _decodePayload(accessToken);

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String?,
        idToken: json['idToken'] as String?,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );

  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final DateTime expiresAt;
  final Map<String, dynamic> claims;

  String get subject => claims['sub'] as String? ?? '';
  String get username => claims['preferred_username'] as String? ?? subject;
  String get displayName => claims['given_name'] as String? ?? claims['name'] as String? ?? username;
  String get region => claims['region'] as String? ?? 'vn';

  /// Mã nhân viên; ứng viên, kiểm toán ngoài không có
  String? get employeeId => claims['employee_id'] as String?;

  /// Họ tên khai lúc đăng ký (token `name`, không có thì `given_name`)
  String? get fullName => claims['name'] as String? ?? claims['given_name'] as String?;
  String? get countryCode => claims['country_code'] as String?;

  List<String> get roles {
    final realm = claims['realm_access'];
    final all = realm is Map ? (realm['roles'] as List? ?? const []).cast<String>() : const <String>[];
    final roles = businessRoles.where(all.contains).toList();
    // Nhân viên không còn là ứng viên
    if (roles.any(staffRoles.contains)) roles.remove('candidate');
    return roles;
  }

  /// Cấp tập đoàn (vai trò group): xem và làm việc với mọi khu vực
  bool get isGroup {
    final realm = claims['realm_access'];
    return realm is Map && (realm['roles'] as List? ?? const []).contains('group');
  }

  /// Người làm trong công ty có hồ sơ nhân viên: có chấm công, phiếu lương, việc của tôi.
  /// Văn phòng quản lý, quản trị chỉ duyệt và cấu hình nên không có phần này.
  bool get isEmployee => (employeeId ?? '').isNotEmpty && roles.any({'employee', 'hr', 'finance'}.contains);

  /// Vai trò chính quyết định bộ màu: ai vừa là admin vừa là executive thì lấy executive.
  String get primaryRole => roles.isEmpty ? 'candidate' : roles.first;

  RoleGem get gem => RoleGem.forRole(primaryRole);

  /// Coi như hết hạn sớm 30 giây để không gửi token sắp chết lên server.
  bool get isExpired => DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 30)));

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'idToken': idToken,
        'expiresAt': expiresAt.toIso8601String(),
      };

  static Map<String, dynamic> _decodePayload(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) return const {};
    try {
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return jsonDecode(payload) as Map<String, dynamic>;
    } on FormatException {
      return const {};
    }
  }
}
