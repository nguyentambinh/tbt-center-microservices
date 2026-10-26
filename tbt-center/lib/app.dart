/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_controller.dart';
import 'core/error/error_reporter.dart';
import 'core/locale/locale_providers.dart';
import 'core/network/api_client.dart';
import 'core/push/push_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode.dart';
import 'core/theme/role_gem.dart';
import 'core/widgets/back_gestures.dart';
import 'core/widgets/connection_banner.dart';
import 'core/widgets/floating_notice.dart';
import 'features/notification/presentation/providers/notification_providers.dart';
import 'l10n/app_localizations.dart';

class TbtApp extends ConsumerStatefulWidget {
  const TbtApp({super.key});

  @override
  ConsumerState<TbtApp> createState() => _TbtAppState();
}

class _TbtAppState extends ConsumerState<TbtApp> {
  final _subscriptions = <StreamSubscription<Object?>>[];
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    final push = ref.read(pushServiceProvider);
    // FCM: đăng nhập thì đăng ký máy, đăng xuất thì bỏ mã
    ref.listenManual(authControllerProvider, (previous, next) {
      final session = next.value;
      if (session != null && previous?.value?.subject != session.subject) {
        push.register(session, ref.read(appLocaleProvider).languageCode);
      } else if (session == null && previous?.value != null) {
        push.unregister();
      }
    }, fireImmediately: true);
    _subscriptions
      // FCM lúc app đang mở: tải lại dữ liệu đang xem và hộp thư để hiện thông báo nổi
      ..add(push.foreground.listen((_) => _refreshData()))
      ..add(push.opened.listen((_) {
        _refreshData();
        ref.read(appRouterProvider).push(Routes.notifications);
      }));
    // Quay lại app từ nền: dữ liệu có thể đã đổi trong lúc vắng
    _lifecycle = AppLifecycleListener(onResume: _refreshData);
  }

  /// Tạo lại client mạng: mọi provider dữ liệu đang hiển thị gọi lại server, vẫn giữ dữ liệu cũ trên màn trong lúc tải
  void _refreshData() {
    if (ref.read(authControllerProvider).value == null) return;
    ref.invalidate(apiClientProvider);
    ref.invalidate(inboxProvider);
    floatingNoticeRefresh.add(null);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Chưa đăng nhập thì dùng vàng kim; đăng nhập rồi đổi theo vai trò chính.
    final gem = ref.watch(authControllerProvider).value?.gem ?? RoleGem.gold;
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(gem, brightness: Brightness.light),
      darkTheme: buildTheme(gem),
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(appLocaleProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: router,
      builder: (context, child) => BackGestures(
        navigatorKey: router.routerDelegate.navigatorKey,
        child: FloatingNoticeHost(child: ConnectionShell(child: child!)),
      ),
    );
  }
}
