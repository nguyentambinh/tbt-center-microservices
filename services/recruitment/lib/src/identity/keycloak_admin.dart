/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Thông tin tài khoản nhân viên mới
class StaffAccount {
  const StaffAccount({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.region,
    required this.countryCode,
    required this.employeeId,
  });

  final String email;
  final String firstName;
  final String lastName;
  final String region;
  final String countryCode;
  final String employeeId;
}

/// Mật khẩu ngẫu nhiên cấp lúc nhận việc, gửi email cho nhân viên
typedef GrantedAccount = ({String subject, String? temporaryPassword});

class IdentityException implements Exception {
  const IdentityException(this.message);

  final String message;

  @override
  String toString() => 'keycloak: $message';
}

abstract interface class IdentityAdmin {
  bool get configured;

  /// Đổi ứng viên thành nhân viên, cấp mật khẩu ngẫu nhiên mới
  Future<GrantedAccount> grantEmployee(StaffAccount account, {String? subject});

  Future<bool> emailTaken(String email);

  /// Tài khoản ứng viên sau khi đã xác nhận email
  Future<void> createCandidate({
    required String email,
    required String fullName,
    required String phone,
    required String password,
  });
}

/// Keycloak Admin API qua client tbt-identity
class KeycloakAdmin implements IdentityAdmin {
  KeycloakAdmin({
    required this.baseUrl,
    required this.clientId,
    required String clientSecret,
    this.realm = 'tbt',
  }) : _secret = clientSecret;

  factory KeycloakAdmin.fromEnvironment() {
    final env = Platform.environment;
    return KeycloakAdmin(
      baseUrl: Uri.parse(
        env['KEYCLOAK_ADMIN_URL'] ?? 'http://host.docker.internal:8180',
      ),
      clientId: env['KEYCLOAK_IDENTITY_CLIENT'] ?? 'tbt-identity',
      clientSecret: env['KEYCLOAK_IDENTITY_SECRET'] ?? '',
    );
  }

  final Uri baseUrl;
  final String clientId;
  final String realm;
  final String _secret;
  final _http = HttpClient()..connectionTimeout = const Duration(seconds: 5);

  @override
  bool get configured => _secret.isNotEmpty;

  @override
  Future<GrantedAccount> grantEmployee(
    StaffAccount account, {
    String? subject,
  }) async {
    final token = await _token();
    final password = _randomPassword();
    var id = subject ?? await _findByEmail(token, account.email);
    if (id == null) {
      id = await _create(token, account, password);
    } else {
      await _send('PUT', 'users/$id/reset-password', token, {
        'type': 'password',
        'value': password,
        'temporary': false,
      });
    }

    final user = await _object('users/$id', token);
    final attributes = {
      ...?(user['attributes'] as Map<String, dynamic>?),
      'region': [account.region],
      'country_code': [account.countryCode],
      'employee_id': [account.employeeId],
    };
    await _send('PUT', 'users/$id', token, {
      ...user,
      'email': account.email,
      'emailVerified': true,
      'firstName': account.firstName,
      'lastName': account.lastName,
      'attributes': attributes,
    });

    final employee = await _object('roles/employee', token);
    // Gỡ default-roles thì phải giữ offline_access cho app đăng nhập lâu dài
    final offline = await _object('roles/offline_access', token);
    await _send('POST', 'users/$id/role-mappings/realm', token, [
      _roleRef(employee),
      _roleRef(offline),
    ]);
    // Gỡ candidate và default-roles
    final current = await _list('users/$id/role-mappings/realm', token);
    final drop = [
      for (final role in current.cast<Map<String, dynamic>>())
        if (role['name'] == 'candidate' ||
            role['name'] == 'default-roles-$realm')
          _roleRef(role),
    ];
    if (drop.isNotEmpty) {
      await _send('DELETE', 'users/$id/role-mappings/realm', token, drop);
    }
    return (subject: id, temporaryPassword: password);
  }

  @override
  Future<bool> emailTaken(String email) async =>
      await _findByEmail(await _token(), email) != null;

  @override
  Future<void> createCandidate({
    required String email,
    required String fullName,
    required String phone,
    required String password,
  }) async {
    final token = await _token();
    // Tạo bằng Admin API thì vai trò mặc định (candidate) tự gán
    await _send('POST', 'users', token, {
      'username': email,
      'email': email,
      'enabled': true,
      'emailVerified': true,
      'firstName': fullName,
      if (phone.isNotEmpty)
        'attributes': {
          'phone': [phone],
        },
      'credentials': [
        {'type': 'password', 'value': password, 'temporary': false},
      ],
    });
  }

  // Chỉ gửi id, tên vai trò; mô tả dạng ${role_...} làm WAF chặn nhầm
  static Map<String, dynamic> _roleRef(Map<String, dynamic> role) => {
    'id': role['id'],
    'name': role['name'],
  };

  Future<String?> _findByEmail(String token, String email) async {
    final found = await _list(
      'users',
      token,
      query: {'email': email, 'exact': 'true'},
    );
    if (found.isEmpty) return null;
    return (found.first as Map<String, dynamic>)['id'] as String;
  }

  Future<String> _create(
    String token,
    StaffAccount account,
    String password,
  ) async {
    await _send('POST', 'users', token, {
      'username': account.email,
      'email': account.email,
      'enabled': true,
      'emailVerified': true,
      'credentials': [
        {'type': 'password', 'value': password, 'temporary': false},
      ],
    });
    final id = await _findByEmail(token, account.email);
    if (id == null) throw const IdentityException('user not created');
    return id;
  }

  Future<String> _token() async {
    final url = baseUrl.resolve('/realms/$realm/protocol/openid-connect/token');
    try {
      final request = await _http.postUrl(url);
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
      );
      request.write(
        Uri(
          queryParameters: {
            'grant_type': 'client_credentials',
            'client_id': clientId,
            'client_secret': _secret,
          },
        ).query,
      );
      final response = await request.close().timeout(_timeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode != 200) {
        throw IdentityException('token HTTP ${response.statusCode}');
      }
      final json = jsonDecode(text) as Map<String, dynamic>;
      return json['access_token']! as String;
    } on IdentityException {
      rethrow;
    } on Exception catch (e) {
      throw IdentityException(e.toString());
    }
  }

  Future<Map<String, dynamic>> _object(String path, String token) async =>
      (await _send('GET', path, token))! as Map<String, dynamic>;

  Future<List<dynamic>> _list(
    String path,
    String token, {
    Map<String, String>? query,
  }) async => (await _send('GET', path, token, null, query))! as List<dynamic>;

  Future<Object?> _send(
    String method,
    String path,
    String token, [
    Object? body,
    Map<String, String>? query,
  ]) async {
    final url = baseUrl
        .resolve('/admin/realms/$realm/$path')
        .replace(queryParameters: query);
    try {
      final request = await _http.openUrl(method, url);
      request.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer $token')
        ..contentType = ContentType.json;
      if (body != null) request.add(utf8.encode(jsonEncode(body)));
      final response = await request.close().timeout(_timeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode == 409) {
        throw const IdentityException('email already used by another account');
      }
      if (response.statusCode >= 400) {
        throw IdentityException('$method $path HTTP ${response.statusCode}');
      }
      return text.isEmpty ? null : jsonDecode(text);
    } on IdentityException {
      rethrow;
    } on Exception catch (e) {
      throw IdentityException(e.toString());
    }
  }

  static const _timeout = Duration(seconds: 15);

  static String _randomPassword() {
    // Bỏ ký tự dễ nhầm 0/O, 1/l/I
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';
    final random = Random.secure();
    return [
      for (var i = 0; i < 12; i++) chars[random.nextInt(chars.length)],
    ].join();
  }
}
