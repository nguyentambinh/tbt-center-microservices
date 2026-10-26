/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/work_calendar.dart';
import '../providers/attendance_providers.dart';

/// Tần suất chấm công: nhân viên xem của mình, HR xem cả khu vực
class ClockStatsPage extends ConsumerStatefulWidget {
  const ClockStatsPage({super.key});

  @override
  ConsumerState<ClockStatsPage> createState() => _ClockStatsPageState();
}

class _ClockStatsPageState extends ConsumerState<ClockStatsPage> {
  int _months = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(clockStatsProvider(_months));
    final roles = ref.watch(authControllerProvider).value?.roles ?? const <String>{};
    final manager = roles.any(leaveApproverRoles.contains);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.clockStats)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SegmentedButton<int>(
            segments: [for (final m in [1, 3, 6, 12]) ButtonSegment(value: m, label: Text(l10n.lastMonths(m)))],
            selected: {_months},
            onSelectionChanged: (v) => setState(() => _months = v.first),
          ),
          const SizedBox(height: 8),
          Text(manager ? l10n.statsScopeRegion : l10n.statsScopeMine, style: TextStyle(color: context.tbt.textSecondary)),
          const SizedBox(height: 12),
          // ErrorView, SkeletonList tự cuộn nên cần chiều cao cố định trong ListView
          switch (stats) {
            AsyncValue(:final value?) => _Charts(stats: value),
            AsyncValue(:final error?) => SizedBox(height: 320, child: ErrorView(error: error, onRetry: () => ref.invalidate(clockStatsProvider(_months)))),
            _ => const SizedBox(height: 320, child: SkeletonList()),
          },
        ],
      ),
    );
  }
}

class _Charts extends StatelessWidget {
  const _Charts({required this.stats});

  final ClockStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final weekdays = [for (var i = 0; i < 7; i++) DateFormat.E(locale).format(DateTime(2024, 1, 1 + i))];
    final hours = [for (var h = 0; h < 24; h++) if (stats.byCheckInHour[h] > 0) h];
    final hourRange = hours.isEmpty ? <int>[] : [for (var h = hours.first; h <= hours.last; h++) h];
    final late = stats.totalDays == 0 ? 0 : stats.lateDays / stats.totalDays;
    if (stats.totalDays == 0) return SizedBox(height: 320, child: EmptyView(message: l10n.noTimesheets, icon: Icons.bar_chart));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _Tile(label: l10n.statsDays, value: '${stats.totalDays}', color: context.tbt.success)),
            const SizedBox(width: 8),
            Expanded(child: _Tile(label: l10n.statsLate, value: '${stats.lateDays} · ${(late * 100).round()}%', color: context.tbt.warning)),
          ],
        ),
        _Section(
          title: l10n.statsByWeekday,
          child: _Bars(labels: weekdays, values: [for (final n in stats.byWeekday) n.toDouble()], color: context.tbt.info),
        ),
        if (hourRange.isNotEmpty)
          _Section(
            title: l10n.statsByHour,
            child: _Bars(labels: [for (final h in hourRange) '${h}h'], values: [for (final h in hourRange) stats.byCheckInHour[h].toDouble()], color: context.tbt.brandGold),
          ),
        if (stats.byMonth.isNotEmpty)
          _Section(
            title: l10n.statsByMonth,
            child: _Bars(
              labels: [for (final m in stats.byMonth) m.month.substring(5)],
              values: [for (final m in stats.byMonth) m.days.toDouble()],
              overlay: [for (final m in stats.byMonth) m.late.toDouble()],
              color: context.tbt.success,
              overlayColor: context.tbt.warning,
            ),
          ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(height: 180, child: child),
          ],
        ),
      );
}

/// Cột đơn; có [overlay] thì vẽ thêm cột thứ hai cạnh bên (ví dụ số lần đi trễ)
class _Bars extends StatelessWidget {
  const _Bars({required this.labels, required this.values, required this.color, this.overlay, this.overlayColor});

  final List<String> labels;
  final List<double> values;
  final List<double>? overlay;
  final Color color;
  final Color? overlayColor;

  @override
  Widget build(BuildContext context) {
    final maxY = [...values, ...?overlay].fold<double>(1, math.max) * 1.2;
    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: context.tbt.glassBorder, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 10, color: context.tbt.textSecondary))),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, _) => Text(labels[v.toInt()], style: TextStyle(fontSize: 10, color: context.tbt.textSecondary)),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 2,
              barRods: [
                BarChartRodData(toY: values[i], width: overlay == null ? 14 : 8, color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
                if (overlay != null) BarChartRodData(toY: overlay![i], width: 8, color: overlayColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
              ],
            ),
        ],
      ),
    );
  }
}
