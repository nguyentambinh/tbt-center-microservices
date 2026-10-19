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
import 'package:intl/intl.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/payroll_run.dart';
import '../providers/payroll_run_providers.dart';

String _period(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

/// Màn của bộ phận tài chính: chốt lương cả khu vực theo kỳ (Saga),
/// xem từng bước chạy tới đâu, chạy lại khi lỗi.
class PayrollRunsPage extends ConsumerWidget {
  const PayrollRunsPage({super.key});

  Future<void> _start(BuildContext context, WidgetRef ref, String period) async {
    try {
      final run = await ref.read(payrollRunRepositoryProvider).start(period);
      ref.invalidate(payrollRunsProvider);
      if (context.mounted) _openRun(context, run.id);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  void _openRun(BuildContext context, String id) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _RunSheet(id: id),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final runs = ref.watch(payrollRunsProvider);
    final now = DateTime.now();
    final periods = [_period(DateTime(now.year, now.month)), _period(DateTime(now.year, now.month - 1))];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.payrollRuns)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in periods)
                  FilledButton.tonal(onPressed: () => _start(context, ref, p), child: Text(l10n.startPayrollRun(p))),
              ],
            ),
          ),
          Expanded(
            child: switch (runs) {
              AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noRuns, icon: Icons.payments),
              AsyncValue(:final value?) => RefreshIndicator(
                  onRefresh: () => ref.refresh(payrollRunsProvider.future),
                  child: ListView(
                    children: [
                      for (final run in value)
                        ListTile(
                          title: Text(run.period),
                          trailing: RunStatusChip(run.status),
                          onTap: () => _openRun(context, run.id),
                        ),
                    ],
                  ),
                ),
              AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(payrollRunsProvider)),
              _ => const SkeletonList(),
            },
          ),
        ],
      ),
    );
  }
}

class RunStatusChip extends StatelessWidget {
  const RunStatusChip(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      'completed' => (l10n.runCompleted, const Color(0xFF3FCF8E)),
      'failed' => (l10n.runFailed, const Color(0xFFFF4D79)),
      'needs_attention' => (l10n.runNeedsAttention, const Color(0xFFFFA726)),
      _ => (l10n.runRunning, AppColors.brandGold),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

class _RunSheet extends ConsumerStatefulWidget {
  const _RunSheet({required this.id});

  final String id;

  @override
  ConsumerState<_RunSheet> createState() => _RunSheetState();
}

class _RunSheetState extends ConsumerState<_RunSheet> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    // Saga chạy nền ở server: đang chạy thì hỏi lại mỗi 2 giây.
    _poll = Timer.periodic(const Duration(seconds: 2), (_) {
      if (ref.read(payrollRunProvider(widget.id)).value?.isRunning ?? true) {
        ref.invalidate(payrollRunProvider(widget.id));
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _retry() async {
    try {
      await ref.read(payrollRunRepositoryProvider).retry(widget.id);
      ref
        ..invalidate(payrollRunProvider(widget.id))
        ..invalidate(payrollRunsProvider);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(payrollRunProvider(widget.id));
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: switch (run) {
        AsyncValue(:final value?) => _RunDetail(run: value, onRetry: _retry),
        AsyncValue(:final error?) =>
          ErrorView(error: error, onRetry: () => ref.invalidate(payrollRunProvider(widget.id))),
        _ => const SkeletonList(),
      },
    );
  }
}

class _RunDetail extends StatelessWidget {
  const _RunDetail({required this.run, required this.onRetry});

  final PayrollRun run;
  final VoidCallback onRetry;

  String _stepName(AppLocalizations l10n, String step) => switch (step) {
        'lock_period' => l10n.stepLockPeriod,
        'collect_hours' => l10n.stepCollectHours,
        'fetch_rate' => l10n.stepFetchRate,
        'calculate' => l10n.stepCalculate,
        'reserve_budget' => l10n.stepReserveBudget,
        'pay' => l10n.stepPay,
        'record_expense' => l10n.stepRecordExpense,
        'issue_payslips' => l10n.stepIssuePayslips,
        'unlock_period' => l10n.stepUnlockPeriod,
        'release_budget' => l10n.stepReleaseBudget,
        'needs_attention' => l10n.stepNeedsAttention,
        'complete' => l10n.stepComplete,
        'compensate' => l10n.stepCompensate,
        'retry' => l10n.stepRetry,
        'resume' => l10n.stepResume,
        _ => step,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final usd = NumberFormat.simpleCurrency(locale: locale, name: 'USD');
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Row(
          children: [
            Expanded(child: Text(run.period, style: text.headlineSmall)),
            RunStatusChip(run.status),
          ],
        ),
        if (run.paidCount > 0)
          Text(l10n.paidSummary(run.paidCount, usd.format(run.paidUsd ?? 0)),
              style: const TextStyle(color: AppColors.textSecondary)),
        if (run.isRunning) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
        if (run.status == 'failed' || run.status == 'needs_attention') ...[
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.replay), label: Text(l10n.retryRun)),
        ],
        const Divider(height: 32),
        Text(l10n.sagaSteps, style: text.titleLarge),
        for (final s in run.steps)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              switch (s.status) {
                'done' => Icons.check_circle,
                'failed' => Icons.cancel,
                _ => Icons.play_circle_outline,
              },
              color: switch (s.status) {
                'done' => const Color(0xFF3FCF8E),
                'failed' => const Color(0xFFFF4D79),
                _ => AppColors.brandGold,
              },
            ),
            title: Text(_stepName(l10n, s.step)),
            subtitle: switch (_stepDetail(l10n, s)) {
              final detail? => Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis),
              null => null,
            },
          ),
      ],
    );
  }
}

/// Lỗi kỹ thuật của bước (tên exception) thành câu người dùng hiểu
String? _stepDetail(AppLocalizations l10n, SagaStep step) {
  final detail = step.detail;
  if (detail == null || step.status != 'failed') return detail;
  if (detail.contains('Timeout')) return l10n.stepErrorTimeout;
  if (RegExp(r'(Exception|Error)\b').hasMatch(detail)) return l10n.stepErrorGeneric;
  return detail;
}
