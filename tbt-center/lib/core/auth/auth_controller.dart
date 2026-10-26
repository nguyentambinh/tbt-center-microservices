/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/response_cache.dart';
import 'auth_gateway.dart';
import 'session.dart';

final authGatewayProvider = Provider<AuthGateway>((ref) => KeycloakAuthGateway());
final sessionStoreProvider = Provider<SessionStore>((ref) => SecureSessionStore());

/// Trạng thái đăng nhập của cả app: `null` là chưa đăng nhập.
class AuthController extends AsyncNotifier<Session?> {
  Future<Session?>? _refreshing;

  AuthGateway get _gateway => ref.read(authGatewayProvider);
  SessionStore get _store => ref.read(sessionStoreProvider);

  @override
  Future<Session?> build() async {
    final saved = await _store.read();
    if (saved == null || !saved.isExpired) return saved;
    try {
      return await _renew(saved);
    } on SessionExpired {
      return null;
    } on Exception {
      // Mất mạng lúc mở app: giữ phiên cũ để xem dữ liệu đã lưu, có mạng sẽ làm mới sau.
      return saved;
    }
  }

  Future<void> signIn({bool register = false, String? locale}) async {
    final session = await _gateway.signIn(register: register, locale: locale);
    await _store.write(session);
    state = AsyncData(session);
  }

  /// Đổi mật khẩu xong thì nhận phiên mới
  Future<void> changePassword({String? locale}) async {
    final session = await _gateway.changePassword(locale: locale);
    await _store.write(session);
    state = AsyncData(session);
  }

  Future<void> signOut() async {
    final session = state.value;
    await _clearLocalData();
    state = const AsyncData(null);
    if (session != null) await _gateway.signOut(session);
  }

  /// Token còn hạn để gắn vào request; tự làm mới nếu sắp hết hạn.
  /// Nhiều request cùng lúc chỉ làm mới một lần.
  Future<String?> validAccessToken({bool forceRefresh = false}) async {
    final session = state.value;
    if (session == null) return null;
    if (!forceRefresh && !session.isExpired) return session.accessToken;
    try {
      return (await (_refreshing ??= _renew(session).whenComplete(() => _refreshing = null)))?.accessToken;
    } on SessionExpired {
      await expire();
      return null;
    }
  }

  /// Server từ chối phiên: xóa phiên, router tự đưa về màn đăng nhập.
  Future<void> expire() async {
    await _clearLocalData();
    state = const AsyncData(null);
  }

  /// Cache là dữ liệu của người vừa đăng xuất, xóa để người sau dùng máy không xem được.
  Future<void> _clearLocalData() async {
    await _store.clear();
    ref.read(responseCacheProvider).clear();
  }

  Future<Session?> _renew(Session session) async {
    final renewed = await _gateway.refresh(session);
    await _store.write(renewed);
    if (state.hasValue) state = AsyncData(renewed);
    return renewed;
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, Session?>(AuthController.new);
