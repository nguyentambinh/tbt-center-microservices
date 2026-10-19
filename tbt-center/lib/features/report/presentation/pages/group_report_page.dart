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

import '../../../../core/locale/l10n_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/presentation/pages/attendance_page.dart' show LeaveStatusLabel;
import '../../../recruitment/presentation/widgets/stage_widgets.dart';
import '../../domain/entities/group_report.dart';
import '../providers/report_providers.dart';

/// Dashboard lãnh đạo (R01, R02, R60): số liệu hợp nhất mọi khu vực, đọc từ
/// mô hình đọc ở Hub (CQRS), tiền đã quy về USD để cộng được.
class GroupReportPage extends ConsumerWidget {
  const GroupReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final report = ref.watch(groupReportProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.groupReport)),
      body: switch (report) {
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(groupReportProvider.future),
            child: _ReportView(report: value),
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(groupReportProvider)),
        _ => const SkeletonList(),
      },
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.report});

  final GroupReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final usd = NumberFormat.simpleCurrency(locale: locale, name: 'USD');
    final text = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    final periods = {for (final p in report.payroll) p.period}.toList()..sort((a, b) => b.compareTo(a));

    Widget section(String title, List<Widget> children) => Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleLarge),
                const SizedBox(height: 8),
                if (children.isEmpty)
                  Text(l10n.noReportData, style: TextStyle(color: context.tbt.textSecondary))
                else
                  ...children,
              ],
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.dataAsOf('${report.projectedUntilEvent}'), style: text.bodySmall?.copyWith(color: context.tbt.textSecondary)),
        const SizedBox(height: 12),
        section(l10n.payrollCostByRegion, [
          for (final period in periods) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(child: Text(period, style: text.titleMedium)),
                  Text(
                    '${l10n.groupTotal}: ${usd.format(report.payroll.where((p) => p.period == period).fold<double>(0, (s, p) => s + p.totalUsd))}',
                    style: TextStyle(color: accent, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            for (final p in report.payroll.where((p) => p.period == period))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.regionName(p.region)),
                subtitle: Text(l10n.employeesCount(p.employees)),
                trailing: Text(usd.format(p.totalUsd)),
              ),
          ],
        ]),
        section(l10n.financeByRegion, [
          for (final f in report.finance)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${l10n.regionName(f.region)} · ${f.period}'),
              subtitle: Text('${l10n.revenue} ${usd.format(f.revenueUsd)} · ${l10n.cost} ${usd.format(f.costUsd)}'),
              trailing: Text(
                usd.format(f.revenueUsd - f.costUsd),
                style: TextStyle(color: f.revenueUsd >= f.costUsd ? context.tbt.success : context.tbt.danger),
              ),
            ),
        ]),
        section(l10n.workConditions, [
          for (final w in report.work)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${l10n.regionName(w.region)} · ${w.period}'),
              subtitle: Text(l10n.employeesCount(w.employees)),
              trailing: Text(l10n.workHoursSummary(
                NumberFormat.decimalPattern(locale).format(w.hours),
                NumberFormat.decimalPattern(locale).format(w.overtimeHours),
              )),
            ),
        ]),
        section(l10n.leavesByRegion, [
          for (final r in report.leaves)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.regionName(r.region)),
              subtitle: Text(LeaveStatusLabel.of(l10n, r.status)),
              trailing: Text('${r.count} · ${l10n.leaveDays(r.days ?? 0)}'),
            ),
        ]),
        section(l10n.candidatesByRegion, [
          for (final r in report.candidates)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.regionName(r.region)),
              subtitle: Text(stageName(l10n, r.status)),
              trailing: Text('${r.count}'),
            ),
        ]),
      ],
    );
  }
}
