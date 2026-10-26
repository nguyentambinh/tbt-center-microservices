/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:convert';
import 'dart:io';

/// Lỗi gọi Keycloak Admin API (mất kết nối, sai quyền, không tìm thấy)
class KeycloakException implements Exception {
  const KeycloakException(this.message, {this.status});

  final String message;
  final int? status;

  @override
  String toString() => 'KeycloakException($status): $message';
}

/// Một tài khoản trong realm, đọc từ Admin API
class KeycloakUser {
  const KeycloakUser({
    required this.id,
    required this.username,
    required this.enabled,
    this.email,
    this.firstName,
    this.lastName,
    this.attributes = const {},
  });

  factory KeycloakUser.fromJson(Map<String, dynamic> json) => KeycloakUser(
    id: json['id'] as String,
    username: json['username'] as String? ?? '',
    enabled: json['enabled'] == true,
    email: json['email'] as String?,
    firstName: json['firstName'] as String?,
    lastName: json['lastName'] as String?,
    attributes: {
      for (final e in (json['attributes'] as Map? ?? const {}).entries)
        e.key as String: (e.value as List?)?.firstOrNull?.toString(),
    },
  );

  final String id;
  final String username;
  final bool enabled;
  final String? email;
  final String? firstName;
  final String? lastName;
  final Map<String, String?> attributes;

  String? get region => attributes['region'];
  String? get employeeId => attributes['employee_id'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'enabled': enabled,
    'email': email,
    'name': [firstName, lastName].nonNulls.join(' ').trim(),
    'region': region,
    'employeeId': employeeId,
  };
}

/// Quản lý tài khoản qua Keycloak Admin API bằng client có service account
/// (client_credentials), dùng cho cấp vai trò tập đoàn và màn quản trị
class KeycloakUsers {
  KeycloakUsers({
    required this.baseUrl,
    required this.clientId,
    required String clientSecret,
    this.realm = 'tbt',
    HttpClient? http,
  }) : _secret = clientSecret,
       _http = http ?? (HttpClient()..connectionTimeout = const Duration(seconds: 5));

  factory KeycloakUsers.fromEnvironment() {
    final env = Platform.environment;
    return KeycloakUsers(
      baseUrl: Uri.parse(env['KEYCLOAK_ADMIN_URL'] ?? 'http://host.docker.internal:8180'),
      clientId: env['KEYCLOAK_IDENTITY_CLIENT'] ?? 'tbt-identity',
      clientSecret: env['KEYCLOAK_IDENTITY_SECRET'] ?? '',
    );
  }

  final Uri baseUrl;
  final String clientId;
  final String realm;
  final String _secret;
  final HttpClient _http;

  /// Token service account dùng lại tới gần lúc hết hạn
  String? _cachedToken;
  DateTime _tokenUntil = DateTime(2000);

  static const _timeout = Duration(seconds: 15);

  bool get configured => _secret.isNotEmpty;

  /// Tìm theo tên đăng nhập, email, họ tên (`search`) hoặc theo thuộc tính (`q=region:vn`)
  Future<List<KeycloakUser>> search({String? text, Map<String, String> attributes = const {}, int max = 100}) async {
    final query = <String, String>{
      'max': '$max',
      'briefRepresentation': 'false',
      if (text != null && text.isNotEmpty) 'search': text,
      if (attributes.isNotEmpty) 'q': [for (final e in attributes.entries) '${e.key}:${e.value}'].join(' '),
    };
    final list = await _send('GET', 'users', query: query) as List? ?? const [];
    return [for (final u in list) KeycloakUser.fromJson(u as Map<String, dynamic>)];
  }

  Future<KeycloakUser?> byEmployeeId(String employeeId) async =>
      (await search(attributes: {'employee_id': employeeId}, max: 2)).firstOrNull;

  Future<KeycloakUser> user(String id) async =>
      KeycloakUser.fromJson(await _send('GET', 'users/$id') as Map<String, dynamic>);

  /// Vai trò realm của tài khoản (bỏ các vai trò mặc định của Keycloak)
  Future<List<String>> roles(String userId) async {
    final list = await _send('GET', 'users/$userId/role-mappings/realm') as List? ?? const [];
    return [
      for (final r in list)
        if (!(r['name'] as String).startsWith('default-roles') && r['name'] != 'offline_access' && r['name'] != 'uma_authorization')
          r['name'] as String,
    ];
  }

  Future<void> addRoles(String userId, Iterable<String> names) => _changeRoles('POST', userId, names);

  Future<void> removeRoles(String userId, Iterable<String> names) => _changeRoles('DELETE', userId, names);

  Future<void> setEnabled(String userId, {required bool enabled}) async {
    final current = await _send('GET', 'users/$userId') as Map<String, dynamic>;
    await _send('PUT', 'users/$userId', body: {...current, 'enabled': enabled});
  }

  Future<void> _changeRoles(String method, String userId, Iterable<String> names) async {
    if (names.isEmpty) return;
    final roles = [for (final name in names) await _send('GET', 'roles/${Uri.encodeComponent(name)}')];
    await _send(method, 'users/$userId/role-mappings/realm', body: roles);
  }

  Future<String> _token() async {
    if (_cachedToken != null && DateTime.now().isBefore(_tokenUntil)) {
      return _cachedToken!;
    }
    final url = baseUrl.resolve('/realms/$realm/protocol/openid-connect/token');
    try {
      final request = await _http.postUrl(url);
      request.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
      request.write(
        Uri(queryParameters: {'grant_type': 'client_credentials', 'client_id': clientId, 'client_secret': _secret}).query,
      );
      final response = await request.close().timeout(_timeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode != 200) {
        throw KeycloakException('token HTTP ${response.statusCode}', status: response.statusCode);
      }
      final json = jsonDecode(text) as Map<String, dynamic>;
      final seconds = (json['expires_in'] as num?)?.toInt() ?? 60;
      _tokenUntil = DateTime.now().add(Duration(seconds: seconds - 30));
      return _cachedToken = json['access_token']! as String;
    } on KeycloakException {
      rethrow;
    } on Exception catch (e) {
      throw KeycloakException(e.toString());
    }
  }

  Future<Object?> _send(String method, String path, {Object? body, Map<String, String>? query}) async {
    if (!configured) throw const KeycloakException('Keycloak admin client is not configured');
    final token = await _token();
    final url = baseUrl.resolve('/admin/realms/$realm/$path').replace(queryParameters: query);
    try {
      final request = await _http.openUrl(method, url);
      request.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer $token')
        ..contentType = ContentType.json;
      if (body != null) request.add(utf8.encode(jsonEncode(body)));
      final response = await request.close().timeout(_timeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode >= 400) {
        throw KeycloakException('$method $path HTTP ${response.statusCode}', status: response.statusCode);
      }
      return text.isEmpty ? null : jsonDecode(text);
    } on KeycloakException {
      rethrow;
    } on Exception catch (e) {
      throw KeycloakException(e.toString());
    }
  }
}
