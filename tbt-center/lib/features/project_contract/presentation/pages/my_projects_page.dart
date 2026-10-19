/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/project_providers.dart';

/// Dự án mình đang tham gia và tổng giờ làm theo từng dự án (R38).
class MyProjectsPage extends ConsumerWidget {
  const MyProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final projects = ref.watch(myProjectsProvider);
    String day(DateTime? d) => d == null ? '-' : DateFormat.yMMMd(locale).format(d);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProjects)),
      body: switch (projects) {
        AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noMyProjects),
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(myProjectsProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final p in value)
                  Card(
                    child: ListTile(
                      title: Text(p.name ?? p.projectId),
                      subtitle: Text(
                        '${p.projectId} · ${day(p.startDate)} – ${day(p.endDate)}',
                        style: TextStyle(color: context.tbt.textSecondary),
                      ),
                      trailing: Text(
                        l10n.hoursValue(NumberFormat.decimalPattern(locale).format(p.hours)),
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(myProjectsProvider)),
        _ => const SkeletonList(),
      },
    );
  }
}
