/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/candidate.dart';

String stageName(AppLocalizations l10n, String stage) => switch (stage) {
      'analyzed' => l10n.stageAnalyzed,
      'screening' => l10n.stageScreening,
      'interview' => l10n.stageInterview,
      'offered' => l10n.stageOffered,
      'hired' => l10n.stageHired,
      'rejected' => l10n.stageRejected,
      _ => l10n.stageSubmitted,
    };

class StageChip extends StatelessWidget {
  const StageChip(this.stage, {super.key});

  final String stage;

  @override
  Widget build(BuildContext context) {
    final color = switch (stage) {
      'offered' || 'hired' => const Color(0xFF3FCF8E),
      'rejected' => const Color(0xFFFF4D79),
      _ => AppColors.brandGold,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(stageName(AppLocalizations.of(context), stage), style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

/// Dòng thời gian các bước đã qua, mới nhất ở dưới cùng.
class StageTimeline extends StatelessWidget {
  const StageTimeline({super.key, required this.history});

  final List<StageChange> history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        for (final (index, step) in history.indexed)
          ListTile(
            leading: Icon(
              index == history.length - 1 ? Icons.radio_button_checked : Icons.check_circle_outline,
              color: index == history.length - 1 ? accent : AppColors.textSecondary,
            ),
            title: Text(stageName(l10n, step.status)),
            subtitle: Text([format.format(step.changedAt), step.note].whereType<String>().join(' · ')),
          ),
      ],
    );
  }
}
