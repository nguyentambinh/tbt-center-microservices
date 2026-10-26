/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

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
                          onPressed: _busy ? null : () => context.push(Routes.signup),
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
          // Giả lập IP công khai để thử dò khu vực, ngôn ngữ của nước khác
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton.icon(
                  onPressed: () => showDialog<void>(context: context, builder: (_) => const _ManualIpDialog()),
                  style: TextButton.styleFrom(
                    foregroundColor: context.tbt.textSecondary,
                    visualDensity: VisualDensity.compact,
                    textStyle: text.labelSmall,
                  ),
                  icon: const Icon(Icons.lan_outlined, size: 16),
                  label: Text(l10n.manualIpButton),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// IP công khai mẫu của từng nước (đã tra đúng nước bằng service geo)
const sampleIps = {
  'vn': '113.161.0.1',
  'de': '85.214.0.1',
  'us': '8.8.8.8',
  'br': '200.160.0.1',
  'za': '196.25.1.1',
  'au': '139.130.4.5',
};

class _ManualIpDialog extends ConsumerStatefulWidget {
  const _ManualIpDialog();

  @override
  ConsumerState<_ManualIpDialog> createState() => _ManualIpDialogState();
}

class _ManualIpDialogState extends ConsumerState<_ManualIpDialog> {
  late final _field = TextEditingController(text: ref.read(locationSimulatorProvider).ip ?? '');
  String? _error;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _apply(String? ip) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(locationSimulatorProvider).simulate(ip: ip);
    if (!mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(
      content: Text(ip == null ? l10n.manualIpCleared : l10n.manualIpSaved(ip)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _submit(AppLocalizations l10n) {
    final ip = _field.text.trim();
    if (ip.isEmpty) {
      _apply(null);
    } else if (InternetAddress.tryParse(ip) == null) {
      setState(() => _error = l10n.manualIpInvalid);
    } else {
      _apply(ip);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final region = ref.watch(submitRegionProvider);
    return AlertDialog(
      title: Text(l10n.manualIpTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.manualIpHint),
            const SizedBox(height: 12),
            TextField(
              controller: _field,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: sampleIps['de'], errorText: _error),
              onSubmitted: (_) => _submit(l10n),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final MapEntry(key: code, value: ip) in sampleIps.entries)
                  ActionChip(
                    label: Text(l10n.regionName(code)),
                    tooltip: ip,
                    onPressed: () => setState(() {
                      _field.text = ip;
                      _error = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l10n.manualIpCurrent(l10n.regionName(region)), style: TextStyle(color: context.tbt.textSecondary)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => _apply(null), child: Text(l10n.manualIpReset)),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(onPressed: () => _submit(l10n), child: Text(l10n.save)),
      ],
    );
  }
}
