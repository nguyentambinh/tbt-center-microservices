/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-11-01
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';

/// Thanh báo trên cùng khi quản trị đang vào thay tài khoản khác, có nút thoát
class ImpersonationBanner extends ConsumerWidget {
  const ImpersonationBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value;
    if (session?.impersonatedBy == null) return child;
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(children: [
      Material(
        color: scheme.primary,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(child: Text(l10n.impersonatingAs(session!.fullName ?? session.username), style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: scheme.onPrimary),
                onPressed: ref.read(authControllerProvider.notifier).stopImpersonation,
                child: Text(l10n.impersonationExit),
              ),
            ]),
          ),
        ),
      ),
      Expanded(child: MediaQuery.removePadding(context: context, removeTop: true, child: child)),
    ]);
  }
}
