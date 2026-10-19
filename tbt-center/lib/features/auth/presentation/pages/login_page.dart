/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_gateway.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/locale/l10n_names.dart';
import '../../../../core/locale/locale_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/role_gem.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/widgets/tbt_logo.dart';
import '../../../../l10n/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _busy = false;

  Future<void> _signIn({bool register = false}) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(register: register, locale: Localizations.localeOf(context).languageCode);
    } on SignInCancelled {
      // Người dùng tự đóng trang đăng nhập.
    } on Exception catch (e) {
      debugPrint('Đăng nhập lỗi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).signInFailed),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } on Object catch (e) {
      reportFailure(e is AppFailure ? e : const AppFailure(FailureKind.unknown));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final region = ref.watch(submitRegionProvider);

    final glassLine = context.tbt.glassBorder;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: context.tbt.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  GlassPanel(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tagline dịch theo ngôn ngữ ở dưới, nên logo không cần dòng tiếng Anh
                        const Center(child: TbtLogo(gem: RoleGem.gold, height: 130, showTagline: false)),
                        const SizedBox(height: 12),
                        Text(
                          l10n.tagline,
                          textAlign: TextAlign.center,
                          style: text.labelMedium?.copyWith(color: context.tbt.brandGold, letterSpacing: 4),
                        ),
                        Divider(height: 40, color: glassLine),
                        FilledButton(
                          onPressed: _busy ? null : _signIn,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _busy
                              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(l10n.signIn),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _busy ? null : () => _signIn(register: true),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: context.tbt.textMain,
                            backgroundColor: context.tbt.glass,
                            side: BorderSide(color: context.tbt.textSecondary.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(l10n.applyAsCandidate),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.dataStoredIn(l10n.regionName(region)),
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(color: context.tbt.textMain.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
