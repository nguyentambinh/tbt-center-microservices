/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

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

/// Client của app, phiên vào thay tài khoản đi qua đúng client này
const impersonationClient = 'tbt-mobile';
const impersonationRedirect = 'com.tbtcenter.tbtcenter:/oauthredirect';

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

  /// Tài khoản mang vai trò realm [role]
  Future<List<KeycloakUser>> withRole(String role, {int max = 200}) async {
    final list = await _send('GET', 'roles/${Uri.encodeComponent(role)}/users', query: {'max': '$max', 'briefRepresentation': 'false'}) as List? ?? const [];
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

  /// Phiên ngắn của [userId]: Admin API trả cookie phiên, dùng cookie đó đi hết
  /// luồng PKCE của app để lấy access token. Không lấy refresh token
  Future<({String accessToken, int expiresIn})> impersonate(String userId) async {
    final token = await _token();
    try {
      final start = await _http.postUrl(baseUrl.resolve('/admin/realms/$realm/users/$userId/impersonation'));
      start.headers
        ..set(HttpHeaders.authorizationHeader, 'Bearer $token')
        ..contentType = ContentType.json;
      final started = await start.close().timeout(_timeout);
      await started.drain<void>();
      if (started.statusCode != 200) {
        throw KeycloakException('impersonation HTTP ${started.statusCode}', status: started.statusCode);
      }
      final cookies = [for (final c in started.cookies) '${c.name}=${c.value}'].join('; ');

      final random = Random.secure();
      final verifier = base64Url.encode(List.generate(48, (_) => random.nextInt(256))).replaceAll('=', '');
      final challenge = base64Url.encode(sha256.convert(ascii.encode(verifier)).bytes).replaceAll('=', '');
      final authorize = await _http.getUrl(
        baseUrl.resolve('/realms/$realm/protocol/openid-connect/auth').replace(
          queryParameters: {
            'client_id': impersonationClient,
            'response_type': 'code',
            'redirect_uri': impersonationRedirect,
            'scope': 'openid',
            'state': verifier.substring(0, 16),
            'code_challenge': challenge,
            'code_challenge_method': 'S256',
          },
        ),
      );
      authorize
        ..followRedirects = false
        ..headers.set(HttpHeaders.cookieHeader, cookies);
      final authorized = await authorize.close().timeout(_timeout);
      await authorized.drain<void>();
      final location = authorized.headers.value(HttpHeaders.locationHeader);
      final code = location == null ? null : Uri.parse(location).queryParameters['code'];
      if (code == null) throw KeycloakException('impersonation no code HTTP ${authorized.statusCode}');

      final exchange = await _http.postUrl(baseUrl.resolve('/realms/$realm/protocol/openid-connect/token'));
      exchange.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
      exchange.write(
        Uri(
          queryParameters: {
            'grant_type': 'authorization_code',
            'client_id': impersonationClient,
            'redirect_uri': impersonationRedirect,
            'code': code,
            'code_verifier': verifier,
          },
        ).query,
      );
      final exchanged = await exchange.close().timeout(_timeout);
      final text = await utf8.decodeStream(exchanged);
      if (exchanged.statusCode != 200) {
        throw KeycloakException('impersonation token HTTP ${exchanged.statusCode}', status: exchanged.statusCode);
      }
      final json = jsonDecode(text) as Map<String, dynamic>;
      return (accessToken: json['access_token']! as String, expiresIn: (json['expires_in'] as num? ?? 300).toInt());
    } on KeycloakException {
      rethrow;
    } on Exception catch (e) {
      throw KeycloakException(e.toString());
    }
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
