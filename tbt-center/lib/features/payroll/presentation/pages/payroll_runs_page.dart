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

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/config/env.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/locale/l10n_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/payout.dart';
import '../../domain/entities/payroll_run.dart';
import '../providers/payroll_run_providers.dart';

String _period(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

/// Kết quả một lượt chuyển ở một công ty
class _RegionOutcome {
  const _RegionOutcome(this.region, {this.result, this.run, this.note, this.error});

  final String region;
  final PayoutResult? result;
  final PayrollRun? run;
  final String? note;
  final Object? error;

  bool get needsDecision => result?.needsDecision ?? false;
}

/// Màn chốt và chuyển lương theo kỳ: cả tập đoàn, từng công ty (khu vực) hoặc từng người.
/// Người đã nhận rồi thì cảnh báo, chọn bỏ qua hoặc chuyển lại; mọi lựa chọn đều vào nhật ký.
class PayrollRunsPage extends ConsumerStatefulWidget {
  const PayrollRunsPage({super.key});

  @override
  ConsumerState<PayrollRunsPage> createState() => _PayrollRunsPageState();
}

class _PayrollRunsPageState extends ConsumerState<PayrollRunsPage> {
  late final List<String> _periods;
  late String _selectedPeriod;
  final _selected = <String>{};
  var _busy = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _periods = [_period(DateTime(now.year, now.month)), _period(DateTime(now.year, now.month - 1))];
    _selectedPeriod = _periods.first;
  }

  AppLocalizations get _l10n => AppLocalizations.of(context);

  void _openRun(String id) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _RunSheet(id: id),
      );

  Future<bool> _confirm(String body) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_l10n.payoutConfirmTitle(_selectedPeriod)),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(_l10n.payoutConfirm)),
          ],
        ),
      ) ??
      false;

  /// Cả công ty: chưa chốt thì chạy Saga, đợt lỗi thì chạy lại phần chưa chi,
  /// đã chốt rồi thì chuyển qua /payouts để được hỏi về người đã nhận.
  Future<_RegionOutcome> _attempt(String region, DuplicateMode mode, List<String>? employeeIds) async {
    final repo = ref.read(payrollRunRepositoryForRegionProvider)(region);
    try {
      if (employeeIds == null && mode == DuplicateMode.ask) {
        try {
          return _RegionOutcome(region, run: await repo.start(_selectedPeriod), note: _l10n.payoutStarted);
        } on AppFailure catch (e) {
          if (e.serverCode == 'run_failed') {
            final failed = (await repo.runs()).firstWhere((r) => r.period == _selectedPeriod);
            return _RegionOutcome(region, run: await repo.retry(failed.id), note: _l10n.payoutRetried);
          }
          if (e.serverCode != 'run_exists') rethrow;
        }
      }
      return _RegionOutcome(
        region,
        result: await repo.transfer(_selectedPeriod, employeeIds: employeeIds, duplicates: mode),
      );
    } on Object catch (e) {
      return _RegionOutcome(region, error: e);
    }
  }

  Future<void> _pay(List<String> regions, {List<String>? employeeIds}) async {
    setState(() => _busy = true);
    var outcomes = const <_RegionOutcome>[];
    try {
      outcomes = await Future.wait([for (final r in regions) _attempt(r, DuplicateMode.ask, employeeIds)]);
      final duplicates = outcomes.where((o) => o.needsDecision).toList();
      if (duplicates.isNotEmpty && mounted) {
        final mode = await _askDuplicates(duplicates, perPerson: employeeIds != null);
        final again = mode == null
            ? const <_RegionOutcome>[]
            : await Future.wait([for (final o in duplicates) _attempt(o.region, mode, employeeIds)]);
        outcomes = [...outcomes.where((o) => !o.needsDecision), ...again];
      }
      ref
        ..invalidate(payrollRunsProvider)
        ..invalidate(payoutBoardProvider(_selectedPeriod))
        ..invalidate(payoutLogProvider(_selectedPeriod));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _selected.clear();
        });
      }
    }
    if (outcomes.any((o) => (o.result?.accepted ?? 0) > 0)) _followProgress();
    if (outcomes.isNotEmpty && mounted) await _showOutcomes(outcomes);
  }

  Timer? _progress;

  /// Server chuyển ở nền: tải lại danh sách và nhật ký mỗi 3 giây trong 3 phút
  void _followProgress() {
    _progress?.cancel();
    final period = _selectedPeriod;
    var ticks = 0;
    _progress = Timer.periodic(const Duration(seconds: 3), (t) {
      if (++ticks > 60) t.cancel();
      ref
        ..invalidate(payoutBoardProvider(period))
        ..invalidate(payoutLogProvider(period));
    });
  }

  @override
  void dispose() {
    _progress?.cancel();
    super.dispose();
  }

  Future<DuplicateMode?> _askDuplicates(List<_RegionOutcome> found, {required bool perPerson}) {
    final l10n = _l10n;
    final lines = [
      for (final o in found)
        if (perPerson)
          for (final d in o.result!.duplicates) l10n.payoutDuplicatePerson(d.employeeId, d.transfers)
        else
          l10n.payoutDuplicateRegion(l10n.regionName(o.region), o.result!.duplicates.length),
    ];
    return showDialog<DuplicateMode>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: context.tbt.warning),
        title: Text(l10n.payoutDuplicateTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final line in lines)
                Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(line)),
              const SizedBox(height: 8),
              Text(l10n.payoutDuplicateBody, style: TextStyle(color: context.tbt.textSecondary)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, DuplicateMode.resend), child: Text(l10n.payoutResend)),
          FilledButton(onPressed: () => Navigator.pop(context, DuplicateMode.skip), child: Text(l10n.payoutSkipPaid)),
        ],
      ),
    );
  }

  String _describe(_RegionOutcome o) {
    final l10n = _l10n;
    if (o.error case final error?) {
      final failure = error is AppFailure ? error : const AppFailure(FailureKind.unknown);
      return failure.isConnectionProblem ? l10n.payoutUnreachable : failure.message(l10n);
    }
    if (o.note case final note?) return note;
    final r = o.result!;
    if (r.accepted > 0) {
      return [
        l10n.payoutAccepted(r.accepted),
        if (r.skipped > 0) l10n.payoutResultSummary(0, 0, r.skipped),
        if (r.missing.isNotEmpty) l10n.payoutResultMissing(r.missing.length),
      ].join('\n');
    }
    if (r.paid + r.resent + r.skipped + r.failed == 0 && r.missing.isEmpty) return l10n.payoutNothing;
    return [
      l10n.payoutResultSummary(r.paid, r.resent, r.skipped),
      if (r.failed > 0) l10n.payoutResultFailed(r.failed),
      if (r.missing.isNotEmpty) l10n.payoutResultMissing(r.missing.length),
    ].join('\n');
  }

  Future<void> _showOutcomes(List<_RegionOutcome> outcomes) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheet) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(_l10n.payoutResultTitle, style: Theme.of(sheet).textTheme.titleLarge),
              ),
              for (final o in outcomes)
                ListTile(
                  leading: Icon(
                    o.error != null ? Icons.error_outline : Icons.check_circle_outline,
                    color: o.error != null ? sheet.tbt.danger : sheet.tbt.success,
                  ),
                  title: Text(_l10n.regionName(o.region)),
                  subtitle: Text(_describe(o)),
                  trailing: o.run == null ? null : const Icon(Icons.chevron_right),
                  onTap: o.run == null
                      ? null
                      : () {
                          Navigator.pop(sheet);
                          ref.read(payrollRegionProvider.notifier).select(o.region);
                          _openRun(o.run!.id);
                        },
                ),
            ],
          ),
        ),
      );

  Future<void> _payRegion(String region) async {
    if (await _confirm(_l10n.payoutConfirmRegion(_l10n.regionName(region)))) await _pay([region]);
  }

  Future<void> _payGroup() async {
    if (await _confirm(_l10n.payoutConfirmGroup(Env.regions.length))) await _pay(Env.regions);
  }

  Future<void> _payPeople(String region) async {
    final ids = _selected.toList()..sort();
    if (await _confirm(_l10n.payoutConfirmPeople(ids.length, _l10n.regionName(region)))) {
      await _pay([region], employeeIds: ids);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roles = ref.watch(authControllerProvider.select((s) => s.value?.roles)) ?? const [];
    final isGroup = roles.any(groupPayrollRoles.contains);
    final region = ref.watch(payrollRegionProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.payrollRuns),
          bottom: _busy ? const PreferredSize(preferredSize: Size.fromHeight(2), child: LinearProgressIndicator()) : null,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isGroup) ...[
                    Text(l10n.payoutCompany, style: TextStyle(color: context.tbt.textSecondary)),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final r in Env.regions)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(l10n.regionName(r)),
                                selected: r == region,
                                onSelected: (_) {
                                  setState(_selected.clear);
                                  ref.read(payrollRegionProvider.notifier).select(r);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SegmentedButton<String>(
                    segments: [for (final p in _periods) ButtonSegment(value: p, label: Text(p))],
                    selected: {_selectedPeriod},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => setState(() {
                      _selectedPeriod = s.first;
                      _selected.clear();
                    }),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _payRegion(region),
                        icon: const Icon(Icons.send),
                        label: Text(l10n.payoutPayRegion(l10n.regionName(region))),
                      ),
                      if (isGroup)
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _payGroup,
                          icon: const Icon(Icons.public),
                          label: Text(l10n.payoutPayGroup),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: [
                Tab(text: l10n.payoutTabPeople),
                Tab(text: l10n.payoutTabRuns),
                Tab(text: l10n.payoutTabLog),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PeopleTab(
                    period: _selectedPeriod,
                    selected: _selected,
                    onToggle: (id) => setState(() => _selected.contains(id) ? _selected.remove(id) : _selected.add(id)),
                  ),
                  _RunsTab(onOpen: _openRun),
                  _LogTab(period: _selectedPeriod),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _selected.isEmpty
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: FilledButton.icon(
                    onPressed: _busy ? null : () => _payPeople(region),
                    icon: const Icon(Icons.send),
                    label: Text(l10n.payoutPaySelected(_selected.length)),
                  ),
                ),
              ),
      ),
    );
  }
}

class _PeopleTab extends ConsumerWidget {
  const _PeopleTab({required this.period, required this.selected, required this.onToggle});

  final String period;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return switch (ref.watch(payoutBoardProvider(period))) {
      AsyncValue(:final value?) when value.lines.isEmpty =>
        EmptyView(message: l10n.payoutNotCalculated, icon: Icons.payments_outlined),
      AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: () => ref.refresh(payoutBoardProvider(period).future),
          child: ListView(
            children: [
              if (value.lines.any((l) => l.net == null))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Text(l10n.payoutAmountHidden, style: TextStyle(color: context.tbt.textSecondary)),
                ),
              for (final line in value.lines)
                CheckboxListTile(
                  value: selected.contains(line.employeeId),
                  onChanged: (_) => onToggle(line.employeeId),
                  title: Text(line.employeeId),
                  subtitle: Text(
                    [
                      if (line.paid) l10n.payoutPaidTimes(line.transfers) else l10n.payoutUnpaid,
                      if (line.net case final net?)
                        NumberFormat.simpleCurrency(locale: locale, name: line.currency).format(net),
                    ].join(' · '),
                    style: TextStyle(color: line.paid ? context.tbt.success : context.tbt.warning),
                  ),
                ),
            ],
          ),
        ),
      AsyncValue(:final error?) =>
        ErrorView(error: error, onRetry: () => ref.invalidate(payoutBoardProvider(period))),
      _ => const SkeletonList(),
    };
  }
}

class _RunsTab extends ConsumerWidget {
  const _RunsTab({required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return switch (ref.watch(payrollRunsProvider)) {
      AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noRuns, icon: Icons.payments),
      AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: () => ref.refresh(payrollRunsProvider.future),
          child: ListView(
            children: [
              for (final run in value)
                ListTile(
                  title: Text(run.period),
                  trailing: RunStatusChip(run.status),
                  onTap: () => onOpen(run.id),
                ),
            ],
          ),
        ),
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(payrollRunsProvider)),
      _ => const SkeletonList(),
    };
  }
}

class _LogTab extends ConsumerWidget {
  const _LogTab({required this.period});

  final String period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final time = DateFormat.yMd(locale).add_Hm();
    return switch (ref.watch(payoutLogProvider(period))) {
      AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noPayoutLog, icon: Icons.receipt_long),
      AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: () => ref.refresh(payoutLogProvider(period).future),
          child: ListView(
            children: [
              for (final item in value)
                ListTile(
                  leading: Icon(
                    switch (item.action) {
                      'paid' || 'resent' => Icons.check_circle_outline,
                      'failed' => Icons.error_outline,
                      'duplicate_warning' => Icons.warning_amber_rounded,
                      'in_doubt' => Icons.help_outline,
                      _ => Icons.skip_next,
                    },
                    color: switch (item.action) {
                      'paid' || 'resent' => context.tbt.success,
                      'failed' => context.tbt.danger,
                      'duplicate_warning' || 'in_doubt' => context.tbt.warning,
                      _ => context.tbt.textSecondary,
                    },
                  ),
                  title: Text('${_actionName(l10n, item.action)} · ${item.employeeId}'),
                  subtitle: Text(
                    l10n.payoutLogLine(item.source == 'saga' ? l10n.payoutLogSaga : item.actor, time.format(item.at)),
                  ),
                  trailing: switch ((item.amount, item.currency)) {
                    (final amount?, final currency?) => Text(
                        NumberFormat.simpleCurrency(locale: locale, name: currency)
                            .format(double.tryParse(amount) ?? 0),
                      ),
                    _ => null,
                  },
                ),
            ],
          ),
        ),
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(payoutLogProvider(period))),
      _ => const SkeletonList(),
    };
  }

  String _actionName(AppLocalizations l10n, String action) => switch (action) {
        'paid' => l10n.payoutLogPaid,
        'resent' => l10n.payoutLogResent,
        'skipped' => l10n.payoutLogSkipped,
        'duplicate_warning' => l10n.payoutLogWarned,
        'in_doubt' => l10n.payoutLogInDoubt,
        _ => l10n.payoutLogFailed,
      };
}


class RunStatusChip extends StatelessWidget {
  const RunStatusChip(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      'completed' => (l10n.runCompleted, context.tbt.success),
      'failed' => (l10n.runFailed, context.tbt.danger),
      'needs_attention' => (l10n.runNeedsAttention, context.tbt.warning),
      _ => (l10n.runRunning, context.tbt.brandGold),
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
              style: TextStyle(color: context.tbt.textSecondary)),
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
                'done' => context.tbt.success,
                'failed' => context.tbt.danger,
                _ => context.tbt.brandGold,
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
