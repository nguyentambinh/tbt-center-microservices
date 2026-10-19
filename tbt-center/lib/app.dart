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
import 'core/push/push_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode.dart';
import 'core/theme/role_gem.dart';
import 'core/widgets/back_gestures.dart';
import 'core/widgets/connection_banner.dart';
import 'features/notification/presentation/providers/notification_providers.dart';
import 'l10n/app_localizations.dart';

class TbtApp extends ConsumerStatefulWidget {
  const TbtApp({super.key});

  @override
  ConsumerState<TbtApp> createState() => _TbtAppState();
}

class _TbtAppState extends ConsumerState<TbtApp> {
  final _subscriptions = <StreamSubscription<Object?>>[];

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
      ..add(push.foreground.listen((body) {
        ref.invalidate(inboxProvider);
        if (body.isNotEmpty) {
          scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(body)));
        }
      }))
      ..add(push.opened.listen((_) => ref.read(appRouterProvider).push(Routes.notifications)));
  }

  @override
  void dispose() {
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
        child: ConnectionShell(child: child!),
      ),
    );
  }
}
