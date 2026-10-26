/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/config/env.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/locale/l10n_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/payroll.dart';
import '../providers/payroll_providers.dart';

String raiseStatusLabel(AppLocalizations l10n, String status) => switch (status) {
      'awaiting_hr' => l10n.raiseAwaitingHr,
      'awaiting_approver' => l10n.raiseAwaitingApprover,
      'awaiting_employee' => l10n.raiseAwaitingEmployee,
      'approved' => l10n.statusApproved,
      'rejected' => l10n.statusRejected,
      _ => l10n.raiseWithdrawn,
    };

/// Đề xuất tăng lương: nhân viên gửi → HR chuyển lên → quản trị hoặc Ban điều hành duyệt
class RaiseRequestsPage extends ConsumerStatefulWidget {
  const RaiseRequestsPage({super.key});

  @override
  ConsumerState<RaiseRequestsPage> createState() => _RaiseRequestsPageState();
}

class _RaiseRequestsPageState extends ConsumerState<RaiseRequestsPage> {
  String? _region;
  String? _status;

  Set<String> get _roles => ref.watch(authControllerProvider).value?.roles.toSet() ?? const {};

  Future<void> _request(String region) async {
    final l10n = AppLocalizations.of(context);
    // Chờ có lương hiện tại để chặn mức không cao hơn ngay trên form
    final double? current;
    final List<BonusPenalty> recent;
    try {
      final mine = await ref.read(myPayrollProvider.future);
      current = mine.baseSalary;
      final since = DateTime.now().subtract(const Duration(days: 365));
      recent = [for (final b in mine.bonusesPenalties) if (b.date.isAfter(since)) b];
    } on Object catch (e) {
      reportFailure(e);
      return;
    }
    if (!mounted) return;
    final result = await _amountDialog(context, title: l10n.newRaiseRequest, minimum: current, askReason: true, attached: recent);
    if (result == null) return;
    await _run(() => ref.read(regionPayrollRepositoryProvider(region)).requestRaise(amount: result.amount!, reason: result.note!), l10n.raiseSent);
  }

  Future<void> _run(Future<Object?> Function() action, String done) async {
    try {
      await action();
      ref.invalidate(raiseRequestsProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done), behavior: SnackBarBehavior.floating));
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider).value;
    final executive = _roles.contains('executive');
    final region = _region ?? session?.region ?? 'vn';
    final query = (region: region, status: _status);
    final items = ref.watch(raiseRequestsProvider(query));
    final reviewer = _roles.any({'hr', 'admin', 'executive'}.contains);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.raiseRequests)),
      floatingActionButton: session?.employeeId != null && !executive
          ? FloatingActionButton.extended(onPressed: () => _request(region), icon: const Icon(Icons.trending_up), label: Text(l10n.newRaiseRequest))
          : null,
      body: Column(
        children: [
          FilterBar(children: [
            FilterSpinner<String>(
              label: l10n.filterStatus,
              value: _status,
              options: [for (final s in ['awaiting_hr', 'awaiting_approver', 'awaiting_employee', 'approved', 'rejected']) (value: s, label: raiseStatusLabel(l10n, s))],
              onChanged: (v) => setState(() => _status = v),
            ),
            if (executive)
              FilterSpinner<String>(
                label: l10n.filterRegion,
                value: region,
                options: [for (final r in Env.regions) (value: r, label: l10n.regionName(r))],
                onChanged: (v) => setState(() => _region = v),
              ),
          ]),
          Expanded(
            child: switch (items) {
              AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noRaiseRequests, icon: Icons.trending_up),
              AsyncValue(:final value?) => RefreshIndicator(
                  onRefresh: () => ref.refresh(raiseRequestsProvider(query).future),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    children: [for (final r in value) FadeSlideIn(child: RaiseCard(request: r, region: region, roles: _roles, showEmployee: reviewer, onRun: _run))],
                  ),
                ),
              AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(raiseRequestsProvider(query))),
              _ => const SkeletonList(),
            },
          ),
        ],
      ),
    );
  }
}

class RaiseCard extends ConsumerWidget {
  const RaiseCard({super.key, required this.request, required this.region, required this.roles, required this.showEmployee, required this.onRun});

  final RaiseRequest request;
  final String region;
  final Set<String> roles;
  final bool showEmployee;
  final Future<void> Function(Future<Object?> Function() action, String done) onRun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    String money(double v) => NumberFormat.simpleCurrency(locale: locale, name: request.currency).format(v);
    final r = request;
    final repo = ref.read(regionPayrollRepositoryProvider(region));
    final mine = ref.watch(authControllerProvider).value?.employeeId == r.employeeId;
    final approver = roles.contains('executive');
    final hr = roles.contains('hr');
    final percent = r.currentSalary == 0 ? 0 : (r.proposed - r.currentSalary) / r.currentSalary * 100;
    final color = switch (r.status) {
      'approved' => context.tbt.success,
      'rejected' || 'withdrawn' => context.tbt.danger,
      _ => context.tbt.brandGold,
    };

    Future<void> act(String action, String done, {bool askAmount = false}) async {
      ({double? amount, String? note})? input;
      if (askAmount || action == 'return' || action == 'reject') {
        input = await _amountDialog(context, title: l10n.raiseActionTitle, minimum: askAmount ? r.proposed : null, askAmount: askAmount, initial: r.proposed);
        if (input == null) return;
      }
      await onRun(() => repo.respondRaise(r.id, action: action, amount: input?.amount, note: input?.note), done);
    }

    final buttons = <Widget>[
      if (mine && (r.status == 'awaiting_hr' || r.status == 'awaiting_employee'))
        OutlinedButton(onPressed: () => act('edit', l10n.raiseSent, askAmount: true), child: Text(l10n.raiseEdit)),
      if (mine && r.open) TextButton(onPressed: () => act('withdraw', l10n.statusChanged), child: Text(l10n.withdrawProposal)),
      if (hr && !mine && !r.skipHr && r.status == 'awaiting_hr') ...[
        FilledButton(onPressed: () => act('forward', l10n.raiseForwarded, askAmount: true), child: Text(l10n.raiseForward)),
        OutlinedButton(onPressed: () => act('return', l10n.statusChanged), child: Text(l10n.raiseReturn)),
        TextButton(onPressed: () => act('reject', l10n.statusChanged), child: Text(l10n.reject)),
      ],
      if (approver && !mine && r.status == 'awaiting_approver') ...[
        FilledButton(onPressed: () => act('approve', l10n.raiseApprovedDone), child: Text(l10n.approve)),
        OutlinedButton(onPressed: () => act('return', l10n.statusChanged), child: Text(l10n.raiseReturn)),
        TextButton(onPressed: () => act('reject', l10n.statusChanged), child: Text(l10n.reject)),
      ],
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(showEmployee ? r.employeeId : l10n.raiseRequests, style: const TextStyle(fontWeight: FontWeight.bold))),
              Text(raiseStatusLabel(l10n, r.status), style: TextStyle(color: color, fontSize: 12)),
            ]),
            const SizedBox(height: 6),
            Text('${money(r.currentSalary)} → ${money(r.proposed)}  (+${percent.toStringAsFixed(1)}%)', style: Theme.of(context).textTheme.titleMedium),
            if (r.proposed != r.requested) Text(l10n.raiseRequestedFirst(money(r.requested)), style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
            Text(r.reason),
            if (r.bonusesPenalties.isNotEmpty) BonusPenaltyList(items: r.bonusesPenalties),
            for (final e in r.events.where((e) => e.note != null && e.note!.isNotEmpty))
              Text('${e.actor}: ${e.note}', style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
            if (buttons.isNotEmpty) ...[const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: buttons)],
          ],
        ),
      ),
    );
  }
}

/// Hộp nhập mức lương (không thấp hơn [minimum]) và lý do hoặc ghi chú
Future<({double? amount, String? note})?> _amountDialog(
  BuildContext context, {
  required String title,
  double? minimum,
  double? initial,
  bool askAmount = true,
  bool askReason = false,
  List<BonusPenalty> attached = const [],
}) {
  final l10n = AppLocalizations.of(context);
  final amount = TextEditingController(text: initial == null ? '' : NumberFormat('#0').format(initial));
  final note = TextEditingController();
  return showDialog<({double? amount, String? note})>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialog) {
        final value = double.tryParse(amount.text);
        final low = askAmount && (value == null || (minimum != null && (askReason ? value <= minimum : value < minimum)));
        final noReason = askReason && note.text.trim().isEmpty;
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (askAmount)
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.proposedSalary,
                    helperText: minimum == null ? null : l10n.raiseMinimum(NumberFormat.decimalPattern().format(minimum)),
                  ),
                  onChanged: (_) => setDialog(() {}),
                ),
              TextField(
                controller: note,
                maxLines: 3,
                decoration: InputDecoration(labelText: askReason ? l10n.raiseReason : l10n.note),
                onChanged: (_) => setDialog(() {}),
              ),
              if (askReason && attached.isNotEmpty) BonusPenaltyList(items: attached),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: low || noReason ? null : () => Navigator.pop(context, (amount: askAmount ? value : null, note: note.text.trim().isEmpty ? null : note.text.trim())),
              child: Text(l10n.send),
            ),
          ],
        );
      },
    ),
  );
}

/// Thưởng phạt 12 tháng gửi kèm đề xuất: từng khoản và cộng dồn
class BonusPenaltyList extends StatelessWidget {
  const BonusPenaltyList({super.key, required this.items});

  final List<BonusPenalty> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final money = NumberFormat.simpleCurrency(locale: locale, name: items.first.currency);
    final net = items.fold<double>(0, (s, b) => s + (b.isBonus ? b.total : -b.total));
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: context.tbt.glassBorder), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.attachedBonuses, style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
          for (final b in items.take(8))
            Row(children: [
              Icon(b.isBonus ? Icons.trending_up : Icons.trending_down, size: 16, color: b.isBonus ? context.tbt.success : context.tbt.danger),
              const SizedBox(width: 6),
              Expanded(child: Text('${DateFormat.yMd(locale).format(b.date)} · ${b.isBonus ? l10n.bonus : l10n.penalty}', style: const TextStyle(fontSize: 12))),
              Text('${b.isBonus ? '+' : '-'}${money.format(b.total)}', style: TextStyle(fontSize: 12, color: b.isBonus ? context.tbt.success : context.tbt.danger)),
            ]),
          if (items.length > 8) Text(l10n.moreItems(items.length - 8), style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
          const Divider(height: 12),
          Text(l10n.bonusNet(money.format(net)), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
