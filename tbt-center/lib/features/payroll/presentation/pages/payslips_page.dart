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
import '../../domain/entities/payroll.dart';
import '../providers/payroll_providers.dart';

/// Phiếu lương của chính người đăng nhập (R37). Số tiền hiện theo tiền tệ
/// của khu vực, định dạng theo ngôn ngữ đang chọn.
class PayslipsPage extends ConsumerWidget {
  const PayslipsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final payroll = ref.watch(myPayrollProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.payslips)),
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
        for (final slip in payroll.payslips)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMM(locale).format(DateTime.parse('${slip.period}-01')),
                    style: text.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(l10n.grossPay), Text(money(slip.gross, slip.currency))],
                  ),
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
