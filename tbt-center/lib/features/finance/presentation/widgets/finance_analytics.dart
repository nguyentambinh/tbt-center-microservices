/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../project_contract/presentation/providers/project_providers.dart';
import '../../domain/entities/finance.dart';
import '../providers/finance_providers.dart';

/// Thu chi, lợi nhuận theo ngày/tháng/năm và xếp hạng dự án theo lợi nhuận
class FinanceAnalyticsTab extends ConsumerStatefulWidget {
  const FinanceAnalyticsTab({super.key});

  @override
  ConsumerState<FinanceAnalyticsTab> createState() => _FinanceAnalyticsTabState();
}

class _FinanceAnalyticsTabState extends ConsumerState<FinanceAnalyticsTab> {
  String _granularity = 'month';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final series = ref.watch(financeAnalyticsProvider(_granularity));
    final ranking = ref.watch(projectRankingProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(financeAnalyticsProvider)
          ..invalidate(projectRankingProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'day', label: Text(l10n.byDay)),
              ButtonSegment(value: 'month', label: Text(l10n.byMonth)),
              ButtonSegment(value: 'year', label: Text(l10n.byYear)),
            ],
            selected: {_granularity},
            onSelectionChanged: (v) => setState(() => _granularity = v.first),
          ),
          const SizedBox(height: 12),
          switch (series) {
            AsyncValue(:final value?) => _SeriesCard(series: value),
            AsyncValue(:final error?) => SizedBox(height: 260, child: ErrorView(error: error, onRetry: () => ref.invalidate(financeAnalyticsProvider))),
            _ => const SizedBox(height: 260, child: SkeletonList()),
          },
          const SizedBox(height: 16),
          Text(l10n.projectProfitRanking, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          switch (ranking) {
            AsyncValue(:final value?) when value.isEmpty => SizedBox(height: 120, child: EmptyView(message: l10n.noProjects)),
            AsyncValue(:final value?) => _Ranking(items: value, currency: series.value?.currency ?? 'USD'),
            AsyncValue(:final error?) => SizedBox(height: 200, child: ErrorView(error: error, onRetry: () => ref.invalidate(projectRankingProvider))),
            _ => const SizedBox(height: 200, child: SkeletonList()),
          },
        ],
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.series});

  final FinanceSeries series;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final money = NumberFormat.compactSimpleCurrency(locale: locale, name: series.currency);
    final points = series.points;
    final revenue = points.fold<double>(0, (s, p) => s + p.revenue);
    final cost = points.fold<double>(0, (s, p) => s + p.material + p.payroll);
    LineChartBarData line(List<double> values, Color color) => LineChartBarData(
          spots: [for (final (i, v) in values.indexed) FlSpot(i.toDouble(), v)],
          isCurved: true,
          preventCurveOverShooting: true,
          color: color,
          barWidth: 2.5,
          dotData: FlDotData(show: points.length < 15),
        );
    Widget total(String label, double value, Color color) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: context.tbt.textSecondary)),
              Text(money.format(value), style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              total(l10n.revenue, revenue, context.tbt.info),
              total(l10n.costs, cost, context.tbt.danger),
              total(l10n.profit, revenue - cost, revenue >= cost ? context.tbt.success : context.tbt.danger),
            ]),
            const SizedBox(height: 16),
            if (points.isEmpty)
              SizedBox(height: 160, child: EmptyView(message: l10n.noData, icon: Icons.show_chart))
            else
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: context.tbt.glassBorder, strokeWidth: 1)),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 48,
                          getTitlesWidget: (v, _) => Text(NumberFormat.compact(locale: locale).format(v), style: TextStyle(fontSize: 10, color: context.tbt.textSecondary)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (points.length / 6).ceilToDouble().clamp(1, 1000),
                          getTitlesWidget: (v, _) {
                            final b = points[v.toInt()].bucket;
                            return Text(b.length > 7 ? b.substring(5) : b, style: TextStyle(fontSize: 9, color: context.tbt.textSecondary));
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      line([for (final p in points) p.revenue], context.tbt.info),
                      line([for (final p in points) p.material + p.payroll], context.tbt.danger),
                      line([for (final p in points) p.profit], context.tbt.success),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Wrap(spacing: 12, children: [
              for (final (label, color) in [(l10n.revenue, context.tbt.info), (l10n.costs, context.tbt.danger), (l10n.profit, context.tbt.success)])
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.circle, size: 10, color: color),
                  Text(' $label', style: const TextStyle(fontSize: 11)),
                ]),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Ranking extends ConsumerWidget {
  const _Ranking({required this.items, required this.currency});

  final List<ProjectFinance> items;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).toString();
    final money = NumberFormat.compactSimpleCurrency(locale: locale, name: currency);
    final names = {for (final p in ref.watch(projectsProvider).value ?? const []) p.id: p.name};
    return Column(
      children: [
        for (final p in items)
          FadeSlideIn(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text('${p.rank}')),
              title: Text(names[p.projectId] ?? p.projectId, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${money.format(p.revenue)} − ${money.format(p.cost)}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(money.format(p.profit), style: TextStyle(fontWeight: FontWeight.bold, color: p.profit >= 0 ? context.tbt.success : context.tbt.danger)),
                  if (p.margin case final m?) Text('${(m * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, color: context.tbt.textSecondary)),
                ],
              ),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => ProjectFinanceSheet(projectId: p.projectId, name: names[p.projectId]),
              ),
            ),
          ),
      ],
    );
  }
}

/// Thu chi của một dự án: doanh thu theo đợt, vật liệu, ai được chia bao nhiêu lương dự án
class ProjectFinanceSheet extends ConsumerWidget {
  const ProjectFinanceSheet({super.key, required this.projectId, this.name});

  final String projectId;
  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final days = DateFormat.yMMMd(locale);
    final detail = ref.watch(projectFinanceProvider(projectId));
    final members = ref.watch(projectDetailProvider(projectId)).value?.members ?? const [];
    final text = Theme.of(context).textTheme;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: switch (detail) {
        AsyncValue(:final value?) => Builder(builder: (context) {
            final money = NumberFormat.simpleCurrency(locale: locale, name: value.currency);
            final shares = [for (final m in members) if (m.projectSalary != null && m.projectSalary! > 0) m];
            final shareTotal = shares.fold<double>(0, (s, m) => s + m.projectSalary!);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Text(name ?? projectId, style: text.titleLarge),
                const SizedBox(height: 8),
                Text('${l10n.revenue}: ${money.format(value.revenue)}'),
                Text('${l10n.materialCost}: ${money.format(value.cost)}'),
                Text('${l10n.profit}: ${money.format(value.profit)}', style: TextStyle(fontWeight: FontWeight.bold, color: value.profit >= 0 ? context.tbt.success : context.tbt.danger)),
                const Divider(height: 24),
                Text(l10n.revenueByStage, style: text.titleSmall),
                for (final r in value.revenues)
                  ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text(r.kind == 'acceptance' ? l10n.warnAccepted : l10n.chartProgress), subtitle: Text(days.format(r.date)), trailing: Text(money.format(r.amount))),
                const Divider(height: 24),
                Text(l10n.materialsUsed, style: text.titleSmall),
                if (value.materials.isEmpty) Text(l10n.noData, style: TextStyle(color: context.tbt.textSecondary)),
                for (final m in value.materials)
                  ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text(m.name), subtitle: Text([days.format(m.date), m.supplier].whereType<String>().join(' · ')), trailing: Text(money.format(m.amount))),
                if (shares.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(l10n.projectSalaryShares, style: text.titleSmall),
                  for (final m in shares)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(m.name ?? m.employeeId ?? '-'),
                      subtitle: LinearProgressIndicator(value: shareTotal == 0 ? 0 : m.projectSalary! / shareTotal, color: context.tbt.brandGold),
                      trailing: Text(money.format(m.projectSalary)),
                    ),
                ],
              ],
            );
          }),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(projectFinanceProvider(projectId))),
        _ => const SkeletonList(),
      },
    );
  }
}
