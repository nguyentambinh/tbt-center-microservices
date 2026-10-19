/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../network/connection_monitor.dart';
import '../theme/app_theme.dart';

/// Bọc toàn bộ app: thanh báo kết nối nằm trên cùng (giống Facebook), nội dung vẫn dùng bình thường bên dưới.
class ConnectionShell extends ConsumerWidget {
  const ConnectionShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(connectionMonitorProvider);
    final visible = snapshot.status != ConnectionStatus.online || snapshot.recovered;
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: visible ? _Banner(snapshot) : const SizedBox(width: double.infinity),
        ),
        // Thanh báo đã chiếm phần tai thỏ phía trên, nên bỏ khoảng đệm trên của màn bên dưới.
        Expanded(child: visible ? MediaQuery.removePadding(context: context, removeTop: true, child: child) : child),
      ],
    );
  }
}

class _Banner extends ConsumerWidget {
  const _Banner(this.snapshot);

  final ConnectionSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final (color, icon, text) = switch (snapshot) {
      ConnectionSnapshot(recovered: true) => (const Color(0xFF1B6B47), Icons.wifi, l10n.bannerRecovered),
      ConnectionSnapshot(status: ConnectionStatus.offline) => (const Color(0xFF8C1C3A), Icons.wifi_off, l10n.bannerOffline),
      ConnectionSnapshot(status: ConnectionStatus.serverUnreachable) =>
        (const Color(0xFF8C1C3A), Icons.cloud_off, l10n.bannerServerDown),
      _ => (const Color(0xFF8A6E1F), Icons.network_check, l10n.bannerUnstable),
    };

    return Material(
      color: color,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 6, 8, 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.tbt.textMain),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: TextStyle(color: context.tbt.textMain, fontSize: 13)),
            ),
            if (snapshot.isDown)
              snapshot.retrying
                  ? Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.tbt.textMain),
                      ),
                    )
                  : TextButton(
                      onPressed: () => ref.read(connectionMonitorProvider.notifier).retryNow(),
                      style: TextButton.styleFrom(foregroundColor: context.tbt.brandGold),
                      child: Text(l10n.reconnect),
                    ),
          ],
        ),
      ),
    );
  }
}
