/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';
import '../widgets/project_widgets.dart';

enum ProjectMetric { timeline, progress, members, value }

/// Biểu đồ dự án: timeline, tiến độ, số người, giá trị; mỗi dòng một mã dự án
class ProjectChartsPage extends ConsumerStatefulWidget {
  const ProjectChartsPage({super.key});

  @override
  ConsumerState<ProjectChartsPage> createState() => _ProjectChartsPageState();
}

class _ProjectChartsPageState extends ConsumerState<ProjectChartsPage> {
  ProjectMetric _metric = ProjectMetric.timeline;

  String _metricLabel(AppLocalizations l10n, ProjectMetric m) => switch (m) {
        ProjectMetric.timeline => l10n.chartTimeline,
        ProjectMetric.progress => l10n.chartProgress,
        ProjectMetric.members => l10n.chartMembers,
        ProjectMetric.value => l10n.chartValue,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projects = ref.watch(projectsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.projectCharts)),
      body: switch (projects) {
        AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noProjects),
        AsyncValue(:final value?) => Column(
            children: [
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    for (final m in ProjectMetric.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(label: Text(_metricLabel(l10n, m)), selected: m == _metric, onSelected: (_) => setState(() => _metric = m)),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _metric == ProjectMetric.timeline ? ProjectTimeline(projects: value) : ProjectBars(projects: value, metric: _metric),
              ),
              _Legend(),
            ],
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(projectsProvider)),
        _ => const SkeletonList(),
      },
    );
  }
}

/// Giá trị của một dự án theo chỉ số đang xem (giá trị quy USD để so được giữa các nước)
double metricValue(ProjectSummary p, ProjectMetric m) => switch (m) {
      ProjectMetric.progress => p.progress * 100,
      ProjectMetric.members => p.members.toDouble(),
      ProjectMetric.value => (p.valueUsd ?? 0) / 1000,
      ProjectMetric.timeline => p.progress * 100,
    };

/// Thanh ngang: trục dọc là mã dự án, dài theo chỉ số, xếp lớn trước
class ProjectBars extends StatelessWidget {
  const ProjectBars({super.key, required this.projects, required this.metric});

  final List<ProjectSummary> projects;
  final ProjectMetric metric;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [...projects]..sort((a, b) => metricValue(b, metric).compareTo(metricValue(a, metric)));
    final top = metric == ProjectMetric.progress ? 100.0 : items.map((p) => metricValue(p, metric)).fold<double>(1, math.max);
    String label(double v) => switch (metric) {
          ProjectMetric.progress => '${v.round()}%',
          ProjectMetric.value => '${NumberFormat.compact().format(v)} ${l10n.thousandUsd}',
          _ => NumberFormat.decimalPattern().format(v),
        };
    return LayoutBuilder(
      builder: (context, box) {
        final width = math.max(40.0, box.maxWidth - 32 - 84 - 72);
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final p = items[i];
            final v = metricValue(p, metric);
            return Tooltip(
              message: p.name ?? p.id,
              child: SizedBox(
                height: 28,
                child: Row(
                  children: [
                    SizedBox(width: 84, child: Text(p.id, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    Container(
                      width: math.max(3, v / top * width),
                      height: 14,
                      decoration: BoxDecoration(color: warningColor(context, p.warning), borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(label(v), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: context.tbt.textSecondary))),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Mỗi dự án một thanh từ ngày bắt đầu tới ngày kết thúc; vạch dọc là hôm nay
class ProjectTimeline extends StatelessWidget {
  const ProjectTimeline({super.key, required this.projects});

  final List<ProjectSummary> projects;

  @override
  Widget build(BuildContext context) {
    final dated = [for (final p in projects) if (p.startDate != null && p.endDate != null) p]..sort((a, b) => a.startDate!.compareTo(b.startDate!));
    if (dated.isEmpty) return EmptyView(message: AppLocalizations.of(context).noProjects);
    final first = dated.map((p) => p.startDate!).reduce((a, b) => a.isBefore(b) ? a : b);
    final last = dated.map((p) => p.endDate!).reduce((a, b) => a.isAfter(b) ? a : b);
    final span = math.max(1, last.difference(first).inDays);
    final years = DateFormat.y(Localizations.localeOf(context).toString());
    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth - 32 - 72;
        final today = DateTime.now().difference(first).inDays / span * width;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Row(
              children: [
                const SizedBox(width: 72),
                Text(years.format(first), style: TextStyle(color: context.tbt.textSecondary, fontSize: 11)),
                const Spacer(),
                Text(years.format(last), style: TextStyle(color: context.tbt.textSecondary, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 6),
            for (final p in dated)
              SizedBox(
                height: 26,
                child: Row(
                  children: [
                    SizedBox(width: 72, child: Text(p.id, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))),
                    SizedBox(
                      width: width,
                      child: Stack(
                        children: [
                          Positioned(
                            left: p.startDate!.difference(first).inDays / span * width,
                            width: math.max(3, p.endDate!.difference(p.startDate!).inDays / span * width),
                            top: 6,
                            height: 14,
                            child: Tooltip(
                              message: '${p.name ?? p.id} · ${(p.progress * 100).round()}%',
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: [warningColor(context, p.warning), warningColor(context, p.warning).withValues(alpha: 0.35)],
                                    stops: [p.progress, p.progress],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (today >= 0 && today <= width) Positioned(left: today, top: 0, bottom: 0, child: Container(width: 1.5, color: context.tbt.textMain)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          for (final level in ['red', 'orange', 'yellow', 'not_started', 'accepted', 'normal'])
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: warningColor(context, level), borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Text(warningLabel(l10n, level), style: TextStyle(fontSize: 11, color: context.tbt.textSecondary)),
              ],
            ),
        ],
      ),
    );
  }
}
