/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/export/table_export.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/payroll.dart';
import '../providers/payroll_providers.dart';

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.bold = false, this.color});

  final String label;
  final String value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : null, color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: style), Text(value, style: style)]),
    );
  }
}

/// Lương gộp, thực nhận qua các kỳ (cũ tới mới)
class _GrowthChart extends StatelessWidget {
  const _GrowthChart({required this.payslips});

  final List<Payslip> payslips;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [...payslips]..sort((a, b) => a.period.compareTo(b.period));
    final shown = items.length > 12 ? items.sublist(items.length - 12) : items;
    final first = shown.first.net;
    final growth = first == 0 ? 0 : (shown.last.net - first) / first;
    LineChartBarData line(List<double> values, Color color) => LineChartBarData(
          spots: [for (final (i, v) in values.indexed) FlSpot(i.toDouble(), v)],
          isCurved: true,
          color: color,
          barWidth: 3,
          dotData: const FlDotData(show: false),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.salaryGrowth, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              l10n.salaryGrowthRate('${growth >= 0 ? '+' : ''}${(growth * 100).toStringAsFixed(1)}%', shown.length),
              style: TextStyle(color: growth >= 0 ? context.tbt.success : context.tbt.danger),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
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
                        reservedSize: 44,
                        getTitlesWidget: (v, _) => Text(NumberFormat.compact().format(v), style: TextStyle(fontSize: 10, color: context.tbt.textSecondary)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (v, _) => Text(shown[v.toInt()].period.substring(5), style: TextStyle(fontSize: 10, color: context.tbt.textSecondary)),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    line([for (final p in shown) p.gross], context.tbt.info),
                    line([for (final p in shown) p.net], context.tbt.success),
                  ],
                ),
              ),
            ),
            Row(children: [
              Icon(Icons.circle, size: 10, color: context.tbt.info),
              Text(' ${l10n.grossPay}   ', style: const TextStyle(fontSize: 11)),
              Icon(Icons.circle, size: 10, color: context.tbt.success),
              Text(' ${l10n.netPay}', style: const TextStyle(fontSize: 11)),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Phiếu lương của chính người đăng nhập (R37). Số tiền hiện theo tiền tệ
/// của khu vực, định dạng theo ngôn ngữ đang chọn.
class PayslipsPage extends ConsumerWidget {
  const PayslipsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final payroll = ref.watch(myPayrollProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.payslips),
        actions: [
          IconButton(tooltip: l10n.raiseRequests, icon: const Icon(Icons.trending_up), onPressed: () => context.push(Routes.raiseRequests)),
          ExportMenuButton(table: () {
            final slips = payroll.value?.payslips;
            if (slips == null) return null;
            return ExportTable(
              title: l10n.payslips,
              headers: [l10n.exportPeriod, l10n.baseSalary, l10n.overtimePay, l10n.bonusesPenalties, l10n.grossPay, l10n.insuranceDeduction, l10n.incomeTax, l10n.netPay, l10n.exportCurrency],
              rows: [for (final s in slips) [s.period, s.base, s.overtime, s.bonus, s.gross, s.insurance, s.tax, s.net, s.currency]],
            );
          }),
        ],
      ),
      body: switch (payroll) {
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(myPayrollProvider.future),
            child: _PayrollView(payroll: value),
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(myPayrollProvider)),
        _ => const SkeletonList(),
      },
    );
  }
}

class _PayrollView extends StatelessWidget {
  const _PayrollView({required this.payroll});

  final PayrollSummary payroll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final text = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    String money(double amount, String currency) =>
        NumberFormat.simpleCurrency(locale: locale, name: currency).format(amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (payroll.baseSalary case final base?)
          Card(
            child: ListTile(
              title: Text(l10n.baseSalary),
              trailing: Text(money(base, payroll.currency ?? 'USD'), style: text.titleMedium),
            ),
          ),
        if (payroll.payslips.isEmpty) EmptyView(message: l10n.noPayslips, icon: Icons.receipt_long),
        if (payroll.payslips.length >= 2) _GrowthChart(payslips: payroll.payslips),
        for (final slip in payroll.payslips)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toBeginningOfSentenceCase(DateFormat.yMMMM(locale).format(DateTime.parse('${slip.period}-01')), locale),
                    style: text.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  for (final (label, amount, sign) in [
                    (l10n.baseSalary, slip.base, ''),
                    (l10n.overtimePay, slip.overtime, '+'),
                    (l10n.bonusesPenalties, slip.bonus, slip.bonus != null && slip.bonus! < 0 ? '' : '+'),
                  ])
                    if (amount != null && (amount != 0 || label == l10n.baseSalary))
                      _Line(label: label, value: '$sign${money(amount, slip.currency)}'),
                  _Line(label: l10n.grossPay, value: money(slip.gross, slip.currency), bold: true),
                  if (slip.insurance case final v?) _Line(label: l10n.insuranceDeduction, value: '−${money(v, slip.currency)}', color: context.tbt.danger),
                  if (slip.tax case final v? when v > 0) _Line(label: l10n.incomeTax, value: '−${money(v, slip.currency)}', color: context.tbt.danger),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.netPay, style: TextStyle(color: accent)),
                      Text(money(slip.net, slip.currency), style: text.titleMedium?.copyWith(color: accent)),
                    ],
                  ),
                  if (slip.netUsd case final usd? when slip.currency != 'USD')
                    Text(
                      l10n.netUsd(money(usd, 'USD')),
                      style: text.bodySmall?.copyWith(color: context.tbt.textSecondary),
                    ),
                  if (slip.paidOn case final paid?)
                    Text(
                      l10n.paidOn(DateFormat.yMMMd(locale).format(paid)),
                      style: text.bodySmall?.copyWith(color: context.tbt.textSecondary),
                    ),
                ],
              ),
            ),
          ),
        if (payroll.bonusesPenalties.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(l10n.bonusesPenalties, style: text.titleLarge),
          for (final b in payroll.bonusesPenalties)
            ListTile(
              leading: Icon(
                b.isBonus ? Icons.trending_up : Icons.trending_down,
                color: b.isBonus ? context.tbt.success : context.tbt.danger,
              ),
              title: Text(b.isBonus ? l10n.bonus : l10n.penalty),
              subtitle: Text(DateFormat.yMMMd(locale).format(b.date)),
              trailing: Text(money(b.total, b.currency)),
            ),
        ],
      ],
    );
  }
}
