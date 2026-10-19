/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/env.dart';
import '../error/app_failure.dart';
import 'session.dart';

/// Người dùng tự đóng trang đăng nhập, không phải lỗi.
class SignInCancelled implements Exception {
  const SignInCancelled();
}

/// Không làm mới được phiên (refresh token hết hạn hoặc bị thu hồi), phải đăng nhập lại.
class SessionExpired implements Exception {
  const SessionExpired();
}

abstract interface class AuthGateway {
  /// [locale] là ngôn ngữ đang chọn trong app (`vi`, `en`, `de`, `pt`), để
  /// trang đăng nhập, đăng ký của Keycloak hiện cùng ngôn ngữ.
  Future<Session> signIn({bool register = false, String? locale});
  Future<Session> refresh(Session session);
  Future<void> signOut(Session session);
}

/// Đăng nhập Keycloak theo chuẩn OAuth 2.0 Authorization Code + PKCE qua trình duyệt hệ thống.
class KeycloakAuthGateway implements AuthGateway {
  KeycloakAuthGateway([FlutterAppAuth? appAuth]) : _appAuth = appAuth ?? const FlutterAppAuth();

  static const _clientId = 'tbt-mobile';
  static const _redirectUrl = 'com.tbtcenter.tbtcenter:/oauthredirect';
  static const _scopes = ['openid', 'profile', 'email', 'offline_access'];

  final FlutterAppAuth _appAuth;

  String get _issuer => '${Env.keycloakUrl}/realms/tbt';

  // http chỉ cho máy dev (Keycloak chạy localhost qua adb reverse); máy chủ thật phải https
  bool get _insecure {
    final uri = Uri.parse(_issuer);
    if (uri.scheme == 'https') return false;
    if (const {'localhost', '127.0.0.1', '10.0.2.2'}.contains(uri.host)) return true;
    // AppAuth văng app nếu gặp http, nên chặn trước bằng lỗi có thể báo ra giao diện
    throw const AppFailure(FailureKind.unknown);
  }

  @override
  Future<Session> signIn({bool register = false, String? locale}) async {
    try {
      final response = await _appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
        _clientId,
        _redirectUrl,
        issuer: _issuer,
        scopes: _scopes,
        allowInsecureConnections: _insecure,
        // Keycloak hiểu prompt=create là mở thẳng trang đăng ký. AppAuth trên
        // Android cấm truyền prompt qua additionalParameters (văng app), phải
        // dùng promptValues.
        promptValues: register ? const ['create'] : null,
        // Chuẩn OIDC ui_locales: plugin Android tự đưa vào chỗ riêng của AppAuth
        // nên không văng như prompt. Keycloak dùng tên pt-BR cho tiếng Bồ Đào Nha.
        additionalParameters: locale == null ? null : {'ui_locales': locale == 'pt' ? 'pt-BR' : locale},
      ));
      return _toSession(response.accessToken, response.refreshToken, response.idToken,
          response.accessTokenExpirationDateTime);
    } on FlutterAppAuthUserCancelledException {
      throw const SignInCancelled();
    }
  }

  @override
  Future<Session> refresh(Session session) async {
    if (session.refreshToken == null) throw const SessionExpired();
    try {
      final response = await _appAuth.token(TokenRequest(
        _clientId,
        _redirectUrl,
        issuer: _issuer,
        refreshToken: session.refreshToken,
        grantType: GrantType.refreshToken,
        allowInsecureConnections: _insecure,
      ));
      return _toSession(response.accessToken, response.refreshToken ?? session.refreshToken,
          response.idToken ?? session.idToken, response.accessTokenExpirationDateTime);
    } on FlutterAppAuthPlatformException catch (e) {
      // invalid_grant: refresh token đã hết hạn hoặc bị thu hồi. Lỗi khác (mất mạng) ném tiếp để giữ phiên.
      if (e.platformErrorDetails.error == 'invalid_grant') throw const SessionExpired();
      rethrow;
    }
  }

  @override
  Future<void> signOut(Session session) async {
    try {
      await _appAuth.endSession(EndSessionRequest(
        idTokenHint: session.idToken,
        postLogoutRedirectUrl: _redirectUrl,
        issuer: _issuer,
        allowInsecureConnections: _insecure,
      ));
    } on Exception {
      // Không tới được Keycloak thì vẫn xóa phiên trên máy; phiên ở server tự hết hạn.
    }
  }

  Session _toSession(String? access, String? refresh, String? id, DateTime? expiresAt) {
    if (access == null) throw const SessionExpired();
    return Session(
      accessToken: access,
      refreshToken: refresh,
      idToken: id,
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 5)),
    );
  }
}

abstract interface class SessionStore {
  Future<Session?> read();
  Future<void> write(Session session);
  Future<void> clear();
}

/// Token nằm trong Keystore của Android (mã hóa), không để trong SharedPreferences.
class SecureSessionStore implements SessionStore {
  SecureSessionStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'session';
  final FlutterSecureStorage _storage;

  @override
  Future<Session?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      return Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(Session session) => _storage.write(key: _key, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
