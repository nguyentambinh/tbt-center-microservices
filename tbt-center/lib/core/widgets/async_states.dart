/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../error/app_failure.dart';
import '../theme/app_theme.dart';

/// Màn báo lỗi dùng chung khi tải dữ liệu không được: câu báo đúng loại lỗi và nút Thử lại.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failure = error is AppFailure ? error as AppFailure : const AppFailure(FailureKind.unknown);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              failure.isConnectionProblem ? Icons.wifi_off : Icons.error_outline,
              size: 48,
              color: context.tbt.brandGold,
            ),
            const SizedBox(height: 16),
            Text(failure.message(l10n), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message, this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: context.tbt.textSecondary),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: context.tbt.textSecondary)),
        ],
      ),
    );
  }
}

/// Chữ cái đầu của tên trong vòng tròn viền vàng, dùng khi chưa có ảnh.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.initials, this.radius = 22});

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.tbt.glass,
        border: Border.all(color: context.tbt.brandGold.withValues(alpha: 0.7)),
      ),
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(color: color, fontFamily: 'serif', fontSize: radius * 0.75, fontWeight: FontWeight.w600),
      ),
    );
  }
}
