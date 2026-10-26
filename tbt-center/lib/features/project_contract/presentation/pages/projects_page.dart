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
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../core/widgets/remote_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/proposal.dart';
import '../providers/project_providers.dart';
import '../widgets/project_widgets.dart';
import '../../../../core/widgets/input_rules.dart';

/// Dự án theo hợp đồng và khách hàng (R100), cho tài chính, HR, quản lý.
class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => ref.read(projectSearchProvider.notifier).set(value));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final text = Theme.of(context).textTheme;
    final projects = ref.watch(projectsProvider);
    final roles = ref.watch(authControllerProvider).value?.roles ?? const <String>{};
    final proposer = roles.any(proposerRoles.contains);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projects),
        actions: [
          IconButton(tooltip: l10n.projectCharts, icon: const Icon(Icons.insights), onPressed: () => context.push(Routes.projectCharts)),
          IconButton(tooltip: l10n.projectProposals, icon: const Icon(Icons.fact_check_outlined), onPressed: () => context.push(Routes.projectProposals)),
        ],
      ),
      floatingActionButton: proposer
          ? FloatingActionButton.extended(onPressed: () => context.push(Routes.projectNew), icon: const Icon(Icons.add), label: Text(l10n.projectNew))
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              inputFormatters: InputRules.search,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.searchProjects),
              onChanged: _search,
            ),
          ),
          FilterBar(
            children: [
              FilterSpinner<int>(
                label: l10n.projectTier,
                value: ref.watch(projectTierProvider),
                options: [for (final t in [1, 2, 3, 4]) (value: t, label: tierLabel(l10n, t))],
                onChanged: (v) => ref.read(projectTierProvider.notifier).set(v),
              ),
              _RangeFilter(range: ref.watch(projectRangeProvider), onChanged: (v) => ref.read(projectRangeProvider.notifier).set(v)),
            ],
          ),
          Expanded(
            child: switch (projects) {
              AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noProjects),
              AsyncValue(:final value?) => RefreshIndicator(
                  onRefresh: () => ref.refresh(projectsProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: value.length,
                    itemBuilder: (context, i) {
                      final p = value[i];
                      final money = NumberFormat.compactSimpleCurrency(locale: locale, name: p.currency);
                      String day(DateTime? d) => d == null ? '-' : DateFormat.yMMMd(locale).format(d);
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => context.push('${Routes.projects}/${Uri.encodeComponent(p.id)}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              RemotePhoto(url: p.imageUrl, aspectRatio: 16 / 7, radius: 0),
                              ListTile(
                                title: Text(p.name ?? p.id, style: text.titleMedium),
                                subtitle: Text(
                                  '${p.id} · ${p.customerName ?? '-'}\n'
                                  '${l10n.startDate}: ${day(p.startDate)} · ${l10n.endDate}: ${day(p.endDate)}\n'
                                  '${l10n.expectedAcceptance}: ${p.expectedAcceptance == null ? '-' : money.format(p.expectedAcceptance)}',
                                  style: TextStyle(color: context.tbt.textSecondary),
                                ),
                                isThreeLine: true,
                                trailing: Text(l10n.employeesCount(p.members)),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        TagChip(label: tierLabel(l10n, p.tier), color: context.tbt.brandGold, icon: Icons.layers_outlined),
                                        TagChip(label: warningLabel(l10n, p.warning), color: warningColor(context, p.warning), icon: Icons.schedule),
                                        if (p.overdue) TagChip(label: l10n.projectOverdue, color: context.tbt.danger, icon: Icons.alarm),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ProgressLine(progress: p.progress, color: warningColor(context, p.warning)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(projectsProvider)),
              _ => const SkeletonList(),
            },
          ),
        ],
      ),
    );
  }
}

/// Ô lọc khoảng thời gian: bấm để chọn từ ngày, đến ngày; chọn rồi bấm lại để xóa
class _RangeFilter extends StatelessWidget {
  const _RangeFilter({required this.range, required this.onChanged});

  final DateTimeRange? range;
  final ValueChanged<DateTimeRange?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final r = range;
    final label = r == null ? l10n.anyTime : '${DateFormat.yMd(locale).format(r.start)} – ${DateFormat.yMd(locale).format(r.end)}';
    return SizedBox(
      width: 220,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2032),
            initialDateRange: r,
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          isEmpty: false,
          decoration: InputDecoration(
            labelText: l10n.projectTime,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            prefixIcon: Icon(Icons.date_range, size: 18, color: r == null ? null : Theme.of(context).colorScheme.primary),
            prefixIconConstraints: const BoxConstraints(minWidth: 32),
            suffixIcon: r == null ? null : IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => onChanged(null)),
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
