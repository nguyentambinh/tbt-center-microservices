/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/work_region.dart';
import '../../core/config/env.dart';
import '../../core/locale/l10n_names.dart';
import '../../core/network/api_client.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_states.dart';
import '../../core/widgets/motion.dart';
import '../../l10n/app_localizations.dart';
import '../finance/data/repositories/finance_repository_impl.dart';
import '../organization/data/organization_repository.dart';

/// Số liệu một nước: nhân sự (HR, văn phòng) và tài chính năm nay quy USD (tài chính, văn phòng)
typedef RegionFigures = ({String region, int? employees, int? departments, double? revenueUsd, double? costUsd, bool reachable});

final groupFiguresProvider = FutureProvider.autoDispose<List<RegionFigures>>((ref) async {
  final dio = ref.read(apiClientProvider);
  final roles = ref.read(authControllerProvider).value?.roles ?? const [];
  final people = roles.any({'hr', 'executive'}.contains);
  final money = roles.any({'finance', 'executive'}.contains);
  final year = DateTime.now().year;

  Future<RegionFigures> load(String region) async {
    var reachable = true;
    Future<T?> safe<T>(Future<T> Function() call) async {
      try {
        return await call();
      } on Object {
        reachable = false;
        return null;
      }
    }

    final base = Env.kongUrl(region);
    final tree = people ? await safe(() => OrganizationRepositoryImpl(dio, baseUrl: base).orgTree()) : null;
    final finance = money ? await safe(() => FinanceRepositoryImpl(dio, baseUrl: base).year(year)) : null;
    return (
      region: region,
      employees: tree?.departments.fold<int>(0, (s, d) => s + d.people.length),
      departments: tree?.departments.length,
      revenueUsd: finance?.months.fold<double>(0, (s, m) => s + m.revenueUsd),
      costUsd: finance?.months.fold<double>(0, (s, m) => s + m.costUsd),
      reachable: reachable,
    );
  }

  return Future.wait([for (final r in Env.regions) load(r)]);
});

/// Tổng quan tập đoàn: tổng cả tập đoàn, biểu đồ so sánh các nước, bấm một nước để chuyển sang xem nước đó
class GroupOverviewPage extends ConsumerWidget {
  const GroupOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final figures = ref.watch(groupFiguresProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.groupOverview)),
      body: switch (figures) {
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(groupFiguresProvider.future),
            child: _Body(items: value),
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(groupFiguresProvider)),
        _ => const SkeletonList(),
      },
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.items});

  final List<RegionFigures> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final number = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final usd = NumberFormat.compactCurrency(symbol: r'$', locale: Localizations.localeOf(context).toString());
    final hasPeople = items.any((i) => i.employees != null);
    final hasMoney = items.any((i) => i.revenueUsd != null);
    final employees = items.fold<int>(0, (s, i) => s + (i.employees ?? 0));
    final revenue = items.fold<double>(0, (s, i) => s + (i.revenueUsd ?? 0));
    final cost = items.fold<double>(0, (s, i) => s + (i.costUsd ?? 0));
    final style = TextStyle(fontSize: 10, color: context.tbt.textSecondary);
    final accent = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.groupTotals, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(spacing: 24, runSpacing: 8, children: [
                if (hasPeople) _Figure(label: l10n.groupEmployees, value: number.format(employees)),
                if (hasMoney) ...[
                  _Figure(label: l10n.groupRevenueYtd, value: usd.format(revenue)),
                  _Figure(label: l10n.groupCostYtd, value: usd.format(cost)),
                ],
              ]),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: BarChart(BarChartData(
                  gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: context.tbt.glassBorder, strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text(hasMoney ? usd.format(v) : number.format(v), style: style))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (v, _) => Text(items[v.toInt()].region.toUpperCase(), style: style))),
                  ),
                  barGroups: [
                    for (final (i, item) in items.indexed)
                      BarChartGroupData(x: i, barsSpace: 3, barRods: [
                        if (hasMoney) ...[
                          BarChartRodData(toY: item.revenueUsd ?? 0, width: 9, color: accent, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
                          BarChartRodData(toY: item.costUsd ?? 0, width: 9, color: context.tbt.caution, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
                        ] else
                          BarChartRodData(toY: (item.employees ?? 0).toDouble(), width: 14, color: accent, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
                      ]),
                  ],
                )),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        for (final (i, item) in items.indexed)
          FadeSlideIn(
            index: i,
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.public),
                title: Text(l10n.regionName(item.region), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  item.reachable
                      ? [
                          if (item.employees != null) '${l10n.groupEmployees}: ${number.format(item.employees)}',
                          if (item.departments != null) '${l10n.departments}: ${item.departments}',
                          if (item.revenueUsd != null) '${l10n.groupRevenueYtd}: ${usd.format(item.revenueUsd)}',
                          if (item.costUsd != null) '${l10n.groupCostYtd}: ${usd.format(item.costUsd)}',
                        ].join('\n')
                      : l10n.groupRegionDown,
                ),
                isThreeLine: item.reachable,
                trailing: Icon(Icons.chevron_right, color: context.tbt.textSecondary),
                onTap: () {
                  ref.read(workRegionProvider.notifier).select(item.region);
                  context.go(Routes.home);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.viewingRegion(l10n.regionName(item.region))), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: context.tbt.textSecondary)),
      ]);
}
