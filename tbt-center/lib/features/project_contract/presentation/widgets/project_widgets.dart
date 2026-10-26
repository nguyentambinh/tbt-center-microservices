/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Còn 1 tháng đỏ, 6 tháng cam, 12 tháng vàng, chưa bắt đầu xanh dương, đã nghiệm thu xanh lá
Color warningColor(BuildContext context, String level) => switch (level) {
      'red' => context.tbt.danger,
      'orange' => context.tbt.warning,
      'yellow' => context.tbt.caution,
      'not_started' => context.tbt.info,
      'accepted' => context.tbt.success,
      _ => context.tbt.textSecondary,
    };

String warningLabel(AppLocalizations l10n, String level) => switch (level) {
      'red' => l10n.warnRed,
      'orange' => l10n.warnOrange,
      'yellow' => l10n.warnYellow,
      'not_started' => l10n.warnNotStarted,
      'accepted' => l10n.warnAccepted,
      _ => l10n.warnNormal,
    };

String tierLabel(AppLocalizations l10n, int tier) => switch (tier) {
      1 => l10n.tierSmall,
      2 => l10n.tierMedium,
      3 => l10n.tierLarge,
      _ => l10n.tierStrategic,
    };

/// Nhãn nhỏ viền màu: phân cấp hoặc mức cảnh báo
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.7))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Thanh tiến độ tô theo màu cảnh báo, kèm phần trăm
class ProgressLine extends StatelessWidget {
  const ProgressLine({super.key, required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress, minHeight: 6, color: color, backgroundColor: context.tbt.glassStrong),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 40, child: Text('${(progress * 100).round()}%', textAlign: TextAlign.end, style: TextStyle(color: context.tbt.textSecondary, fontSize: 12))),
      ],
    );
  }
}
