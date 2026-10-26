/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/export/table_export.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../core/widgets/bar_chart.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/finance.dart';
import '../providers/finance_providers.dart';
import '../widgets/finance_analytics.dart';

/// Tài chính của khu vực: thu chi theo tháng, chốt sổ (R19–R22, R62) và
/// công nợ nhà cung cấp (R103, R104).
class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.finance),
          // Một nút xuất theo tab đang mở: Phân tích xuất xếp hạng dự án, còn lại xuất thu chi theo tháng
          actions: [
            Builder(
              builder: (context) => ExportMenuButton(table: () {
                if (DefaultTabController.of(context).index == 1) {
                  final ranking = ref.read(projectRankingProvider).value;
                  if (ranking == null) return null;
                  return ExportTable(
                    title: l10n.projectProfitRanking,
                    headers: [l10n.exportRank, l10n.exportId, l10n.revenue, l10n.materialCost, l10n.profit, l10n.exportMargin],
                    rows: [for (final p in ranking) [p.rank, p.projectId, p.revenue, p.cost, p.profit, p.margin == null ? '' : '${(p.margin! * 100).toStringAsFixed(1)}%']],
                  );
                }
                final year = ref.read(financeSummaryProvider).value;
                if (year == null) return null;
                return ExportTable(
                  title: l10n.exportFinanceTitle(year.year),
                  subtitle: year.currency,
                  headers: [l10n.exportPeriod, l10n.revenue, l10n.costs, l10n.profit, l10n.exportRevenueUsd, l10n.exportCostUsd, l10n.closePeriod],
                  rows: [for (final m in year.months) [m.period, m.revenue, m.cost, m.profit, m.revenueUsd, m.costUsd, m.closed ? '✓' : '']],
                );
              }),
            ),
          ],
          bottom: TabBar(tabs: [Tab(text: l10n.incomeExpense), Tab(text: l10n.financeAnalytics), Tab(text: l10n.suppliers)]),
        ),
        body: const TabBarView(children: [_MonthsTab(), FinanceAnalyticsTab(), _SuppliersTab()]),
      ),
    );
  }
}

class _MonthsTab extends ConsumerWidget {
  const _MonthsTab();

  Future<void> _close(BuildContext context, WidgetRef ref, String period) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.closePeriod),
        content: Text(l10n.closePeriodConfirm(period)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.closePeriod)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(financeRepositoryProvider).closePeriod(period);
      ref.invalidate(financeSummaryProvider);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final year = ref.watch(financeYearProvider);
    final summary = ref.watch(financeSummaryProvider);
    final roles = ref.watch(authControllerProvider).value?.roles ?? const <String>[];
    final canWrite = roles.any(financeWriterRoles.contains);
    final thisMonth = DateTime.now().toIso8601String().substring(0, 7);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => ref.read(financeYearProvider.notifier).previous(),
            ),
            Text('$year', style: Theme.of(context).textTheme.titleLarge),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => ref.read(financeYearProvider.notifier).next(),
            ),
          ],
        ),
        Expanded(
          child: switch (summary) {
            AsyncValue(:final value?) when value.months.isEmpty => EmptyView(message: l10n.noFinanceData),
            AsyncValue(:final value?) => RefreshIndicator(
                onRefresh: () => ref.refresh(financeSummaryProvider.future),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _YearChart(year: value),
                    for (final m in value.months)
                      _MonthCard(
                        month: m,
                        currency: value.currency,
                        onClose: canWrite && !m.closed && m.period.compareTo(thisMonth) < 0
                            ? () => _close(context, ref, m.period)
                            : null,
                      ),
                  ],
                ),
              ),
            AsyncValue(:final error?) =>
              ErrorView(error: error, onRetry: () => ref.invalidate(financeSummaryProvider)),
            _ => const SkeletonList(),
          },
        ),
      ],
    );
  }
}

/// Doanh thu, chi phí cả năm theo tháng, quy USD để so được giữa các tháng (R25).
class _YearChart extends StatelessWidget {
  const _YearChart({required this.year});

  final FinanceYear year;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final compact = NumberFormat.compactSimpleCurrency(locale: locale, name: 'USD');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GroupedBarChart(
          series: [
            BarSeries(l10n.revenue, Theme.of(context).colorScheme.primary),
            BarSeries(l10n.cost, context.tbt.textSecondary),
          ],
          groups: [
            for (final m in year.months) BarGroup(m.period.substring(5), [m.revenueUsd, m.costUsd]),
          ],
          formatValue: compact.format,
        ),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.month, required this.currency, this.onClose});

  final MonthFigures month;
  final String currency;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final text = Theme.of(context).textTheme;
    final money = NumberFormat.simpleCurrency(locale: locale, name: currency);
    final usd = NumberFormat.simpleCurrency(locale: locale, name: 'USD');
    final profitColor = month.profit >= 0 ? context.tbt.success : context.tbt.danger;

    Widget line(String label, double amount, double amountUsd, {Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(color: color))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(money.format(amount), style: TextStyle(color: color)),
                  if (currency != 'USD')
                    Text(usd.format(amountUsd), style: text.bodySmall?.copyWith(color: context.tbt.textSecondary)),
                ],
              ),
            ],
          ),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    toBeginningOfSentenceCase(DateFormat.yMMMM(locale).format(DateTime.parse('${month.period}-01')), locale),
                    style: text.titleLarge,
                  ),
                ),
                if (month.closed)
                  Chip(avatar: const Icon(Icons.lock_outline, size: 16), label: Text(l10n.periodClosed))
                else if (onClose != null)
                  OutlinedButton(onPressed: onClose, child: Text(l10n.closePeriod)),
              ],
            ),
            const SizedBox(height: 8),
            line(l10n.revenue, month.revenue, month.revenueUsd),
            line(l10n.cost, month.cost, month.costUsd),
            const Divider(),
            line(l10n.profit, month.profit, month.revenueUsd - month.costUsd, color: profitColor),
          ],
        ),
      ),
    );
  }
}

class _SuppliersTab extends ConsumerWidget {
  const _SuppliersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final suppliers = ref.watch(suppliersProvider);
    final currency = ref.watch(financeSummaryProvider).value?.currency;

    return switch (suppliers) {
      AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noData),
      AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: () => ref.refresh(suppliersProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final (rank, s) in value.indexed)
                Card(
                  child: ListTile(
                    leading: Text('#${rank + 1}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    title: Text(s.name),
                    subtitle: Text(
                      [
                        l10n.supplierPurchases(s.purchases),
                        if (s.paidPercent case final p?) l10n.supplierPaidPercent(NumberFormat.decimalPattern(locale).format(p)),
                      ].join(' · '),
                      style: TextStyle(color: context.tbt.textSecondary),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(l10n.balance, style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          currency == null
                              ? NumberFormat.decimalPattern(locale).format(s.balance)
                              : NumberFormat.simpleCurrency(locale: locale, name: currency).format(s.balance),
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                    onTap: () => context.push('${Routes.suppliers}/${Uri.encodeComponent(s.id)}'),
                  ),
                ),
            ],
          ),
        ),
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(suppliersProvider)),
      _ => const SkeletonList(),
    };
  }
}
