/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/config/env.dart';
import '../../../core/error/error_reporter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../../core/widgets/motion.dart';
import '../../../l10n/app_localizations.dart';
import '../data/resignation_repository.dart';
import '../domain/resignation.dart';

final resignationRepositoryProvider = Provider.family<ResignationRepository, String>(
  (ref, region) => ResignationRepository(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region)),
);

final resignationsProvider = FutureProvider.autoDispose.family<List<Resignation>, String>(
  (ref, region) => ref.watch(resignationRepositoryProvider(region)).list(),
);

/// Ai xử lý đơn thôi việc
const resignationHandlerRoles = {'hr', 'admin'};

String resignationStatusLabel(AppLocalizations l10n, String status) => switch (status) {
      'pending' => l10n.resignationPending,
      'approved' => l10n.resignationApproved,
      'completed' => l10n.resignationCompleted,
      'rejected' => l10n.statusRejected,
      _ => l10n.resignationWithdrawn,
    };

/// Xin thôi việc: nhân viên gửi đơn báo trước 30 ngày, HR duyệt rồi hoàn tất sau ngày làm cuối
class ResignationsPage extends ConsumerWidget {
  const ResignationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider).value;
    final region = session?.region ?? 'vn';
    final handler = session?.roles.any(resignationHandlerRoles.contains) ?? false;
    final items = ref.watch(resignationsProvider(region));
    final hasOpen = items.value?.any((r) => r.open && r.employeeId == session?.employeeId) ?? true;

    Future<void> run(Future<Object?> Function() action, String done) async {
      try {
        await action();
        ref.invalidate(resignationsProvider(region));
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done), behavior: SnackBarBehavior.floating));
      } on Object catch (e) {
        reportFailure(e);
      }
    }

    Future<void> submit() async {
      final input = await showDialog<({DateTime lastDay, String reason})>(context: context, builder: (_) => const _ResignationDialog());
      if (input == null) return;
      await run(() => ref.read(resignationRepositoryProvider(region)).submit(lastDay: input.lastDay, reason: input.reason), l10n.resignationSent);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resignations)),
      floatingActionButton: session?.employeeId != null && !hasOpen && !handler
          ? FloatingActionButton.extended(onPressed: submit, icon: const Icon(Icons.logout), label: Text(l10n.newResignation))
          : null,
      body: switch (items) {
        AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noResignations, icon: Icons.logout),
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(resignationsProvider(region).future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [for (final r in value) FadeSlideIn(child: ResignationCard(resignation: r, region: region, handler: handler, onRun: run))],
            ),
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(resignationsProvider(region))),
        _ => const SkeletonList(),
      },
    );
  }
}

class ResignationCard extends ConsumerWidget {
  const ResignationCard({super.key, required this.resignation, required this.region, required this.handler, required this.onRun});

  final Resignation resignation;
  final String region;
  final bool handler;
  final Future<void> Function(Future<Object?> Function() action, String done) onRun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final r = resignation;
    final repo = ref.read(resignationRepositoryProvider(region));
    final mine = ref.watch(authControllerProvider).value?.employeeId == r.employeeId;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(r.lastDay);
    final color = switch (r.status) {
      'approved' || 'completed' => context.tbt.success,
      'rejected' || 'withdrawn' => context.tbt.danger,
      _ => context.tbt.brandGold,
    };

    Future<void> complete() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.resignationComplete),
          content: Text(l10n.resignationCompleteConfirm(r.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.resignationComplete)),
          ],
        ),
      );
      if (ok == true) await onRun(() => repo.respond(r.id, action: 'complete'), l10n.resignationCompletedDone);
    }

    final buttons = <Widget>[
      if (mine && r.status == 'pending') TextButton(onPressed: () => onRun(() => repo.respond(r.id, action: 'withdraw'), l10n.statusChanged), child: Text(l10n.resignationWithdraw)),
      if (handler && !mine && r.status == 'pending') ...[
        FilledButton(onPressed: () => onRun(() => repo.respond(r.id, action: 'approve'), l10n.statusChanged), child: Text(l10n.approve)),
        TextButton(onPressed: () => onRun(() => repo.respond(r.id, action: 'reject'), l10n.statusChanged), child: Text(l10n.reject)),
      ],
      if (handler && !mine && r.canComplete(DateTime.now())) FilledButton(onPressed: complete, child: Text(l10n.resignationComplete)),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(handler ? '${r.name} (${r.employeeId})' : l10n.resignations, style: const TextStyle(fontWeight: FontWeight.bold))),
              Text(resignationStatusLabel(l10n, r.status), style: TextStyle(color: color, fontSize: 12)),
            ]),
            const SizedBox(height: 6),
            Text(l10n.resignationLastDayOn(date), style: Theme.of(context).textTheme.titleMedium),
            Text(r.reason),
            if (r.decidedBy != null) Text(r.decidedBy!, style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
            if (buttons.isNotEmpty) ...[const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: buttons)],
          ],
        ),
      ),
    );
  }
}

class _ResignationDialog extends StatefulWidget {
  const _ResignationDialog();

  @override
  State<_ResignationDialog> createState() => _ResignationDialogState();
}

class _ResignationDialogState extends State<_ResignationDialog> {
  final _reason = TextEditingController();
  late final DateTime _earliest = () {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + resignationNoticeDays);
  }();
  late DateTime _lastDay = _earliest;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_lastDay);
    return AlertDialog(
      title: Text(l10n.resignations),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(l10n.resignationLastDay),
            subtitle: Text('$date\n${l10n.resignationNotice(resignationNoticeDays)}'),
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: _lastDay, firstDate: _earliest, lastDate: _earliest.add(const Duration(days: 365)));
              if (picked != null) setState(() => _lastDay = picked);
            },
          ),
          TextField(
            controller: _reason,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.resignationReason),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: _reason.text.trim().isEmpty ? null : () => Navigator.pop(context, (lastDay: _lastDay, reason: _reason.text.trim())),
          child: Text(l10n.send),
        ),
      ],
    );
  }
}
