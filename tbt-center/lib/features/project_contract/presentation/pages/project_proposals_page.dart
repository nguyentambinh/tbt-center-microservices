/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/config/env.dart';
import '../../../../core/locale/l10n_names.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/proposal.dart';
import '../providers/project_providers.dart';
import '../widgets/project_widgets.dart';
import '../widgets/proposal_form.dart';

String proposalStatusLabel(AppLocalizations l10n, String status) => switch (status) {
      'awaiting_executive' => l10n.propAwaitingExecutive,
      'awaiting_proposer' => l10n.propAwaitingProposer,
      'approved' => l10n.propApproved,
      _ => l10n.propRejected,
    };

Color proposalStatusColor(BuildContext context, String status) => switch (status) {
      'approved' => context.tbt.success,
      'rejected' => context.tbt.danger,
      'awaiting_proposer' => context.tbt.info,
      _ => context.tbt.brandGold,
    };

/// Đề xuất dự án: bên lập và Ban lãnh đạo sửa qua lại tới khi cùng xác nhận
class ProjectProposalsPage extends ConsumerStatefulWidget {
  const ProjectProposalsPage({super.key});

  @override
  ConsumerState<ProjectProposalsPage> createState() => _ProjectProposalsPageState();
}

class _ProjectProposalsPageState extends ConsumerState<ProjectProposalsPage> {
  String? _status;
  String? _region;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider).value;
    final executive = session?.roles.contains('executive') ?? false;
    final region = _region ?? session?.region ?? 'vn';
    final query = (region: region, status: _status);
    final items = ref.watch(proposalsProvider(query));
    final days = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.projectProposals)),
      body: Column(
        children: [
          FilterBar(
            children: [
              FilterSpinner<String>(
                label: l10n.filterStatus,
                value: _status,
                options: [for (final s in ['awaiting_executive', 'awaiting_proposer', 'approved', 'rejected']) (value: s, label: proposalStatusLabel(l10n, s))],
                onChanged: (v) => setState(() => _status = v),
              ),
              if (executive)
                FilterSpinner<String>(
                  label: l10n.filterRegion,
                  value: region,
                  options: [for (final r in Env.regions) (value: r, label: l10n.regionName(r))],
                  onChanged: (v) => setState(() => _region = v),
                ),
            ],
          ),
          Expanded(
            child: switch (items) {
              AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noProposals, icon: Icons.fact_check_outlined),
              AsyncValue(:final value?) => RefreshIndicator(
                  onRefresh: () => ref.refresh(proposalsProvider(query).future),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      for (final p in value)
                        FadeSlideIn(
                          child: Card(
                            child: ListTile(
                              title: Text(p.data.name ?? '#${p.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text([p.data.customerName, l10n.proposalVersion(p.version), days.format(p.updatedAt)].whereType<String>().join(' · ')),
                              trailing: TagChip(label: proposalStatusLabel(l10n, p.status), color: proposalStatusColor(context, p.status)),
                              onTap: () => showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                showDragHandle: true,
                                builder: (_) => ProposalSheet(region: region, id: p.id),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(proposalsProvider(query))),
              _ => const SkeletonList(),
            },
          ),
        ],
      ),
    );
  }
}

class ProposalSheet extends ConsumerStatefulWidget {
  const ProposalSheet({super.key, required this.region, required this.id});

  final String region;
  final int id;

  @override
  ConsumerState<ProposalSheet> createState() => _ProposalSheetState();
}

class _ProposalSheetState extends ConsumerState<ProposalSheet> {
  bool _busy = false;

  ({String region, int id}) get _key => (region: widget.region, id: widget.id);

  Future<void> _respond(String action, {ProposalData? data}) async {
    final l10n = AppLocalizations.of(context);
    String? note;
    if (action != 'approve') {
      final controller = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.note),
          content: TextField(controller: controller, maxLines: 3, decoration: InputDecoration(hintText: l10n.proposalNoteHint)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.send)),
          ],
        ),
      );
      if (ok != true) return;
      note = controller.text.trim().isEmpty ? null : controller.text.trim();
    }
    setState(() => _busy = true);
    try {
      final updated = await ref.read(regionProjectRepositoryProvider(widget.region)).respond(widget.id, action: action, data: data, note: note);
      ref
        ..invalidate(proposalDetailProvider(_key))
        ..invalidate(proposalsProvider)
        ..invalidate(pendingProposalsProvider);
      if (updated.status == 'approved') ref.invalidate(projectsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(updated.status == 'approved' ? l10n.proposalApprovedDone(updated.projectId ?? '') : l10n.statusChanged), behavior: SnackBarBehavior.floating),
        );
      }
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _counter(ProjectProposal p) async {
    final l10n = AppLocalizations.of(context);
    var edited = p.data;
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => StatefulBuilder(
          builder: (context, setPage) {
            final errors = edited.errors(rateToUsd: rateToUsd(edited.currency));
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.proposalEdit),
                actions: [TextButton(onPressed: errors.isEmpty ? () => Navigator.pop(context, true) : null, child: Text(l10n.send))],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [ProposalForm(initial: p.data, showMemberRule: true, onChanged: (d) => setPage(() => edited = d))],
              ),
            );
          },
        ),
      ),
    );
    if (ok == true) await _respond('counter', data: edited);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(proposalDetailProvider(_key));
    final roles = ref.watch(authControllerProvider).value?.roles ?? const <String>{};
    final executive = roles.contains('executive');
    final proposer = roles.any(proposerRoles.contains);
    final days = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final when = DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_Hm();
    final money = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: switch (detail) {
        AsyncValue(:final value?) => Builder(builder: (context) {
            final p = value;
            final d = p.data;
            final tier = d.value == null ? 1 : projectTier(d.value! / rateToUsd(d.currency));
            final myTurn = executive && p.status == 'awaiting_executive' || proposer && !executive && p.status == 'awaiting_proposer';
            String day(DateTime? v) => v == null ? '—' : days.format(v);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Text(d.name ?? '#${p.id}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  TagChip(label: proposalStatusLabel(l10n, p.status), color: proposalStatusColor(context, p.status)),
                  TagChip(label: tierLabel(l10n, tier), color: context.tbt.brandGold, icon: Icons.layers_outlined),
                ]),
                const SizedBox(height: 12),
                Text('${d.customerName ?? '—'}${d.customerContact == null ? '' : ' · ${d.customerContact}'}'),
                if (d.contractType != null) Text(d.contractType!),
                Text('${l10n.contractValue}: ${d.value == null ? '—' : money.format(d.value)} ${d.currency ?? ''}'),
                if (d.deposit != null) Text('${l10n.depositAmount}: ${money.format(d.deposit)} ${d.currency ?? ''}'),
                Text('${day(d.startDate)} → ${day(d.endDate)} · ${l10n.acceptanceDate}: ${day(d.acceptanceDate)}'),
                Text(l10n.employeesCount(d.memberIds.length)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: [
                  if (p.contractUrl case final url?)
                    OutlinedButton.icon(onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication), icon: const Icon(Icons.description_outlined), label: Text(l10n.openContract)),
                  if (p.imageUrl case final url?)
                    OutlinedButton.icon(onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication), icon: const Icon(Icons.image_outlined), label: Text(l10n.openImage)),
                  if (p.projectId case final id?)
                    FilledButton.tonalIcon(onPressed: () => context.push('${Routes.projects}/${Uri.encodeComponent(id)}'), icon: const Icon(Icons.open_in_new), label: Text(l10n.openProject)),
                ]),
                if (myTurn) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    FilledButton.icon(onPressed: _busy ? null : () => _respond('approve'), icon: const Icon(Icons.check), label: Text(executive ? l10n.approve : l10n.acceptEdits)),
                    OutlinedButton.icon(onPressed: _busy ? null : () => _counter(p), icon: const Icon(Icons.edit_outlined), label: Text(l10n.proposalEdit)),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _respond(executive ? 'reject' : 'withdraw'),
                      icon: const Icon(Icons.block),
                      label: Text(executive ? l10n.reject : l10n.withdrawProposal),
                      style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                    ),
                  ]),
                ] else if (p.open)
                  Padding(padding: const EdgeInsets.only(top: 12), child: Text(l10n.waitingOtherSide, style: TextStyle(color: context.tbt.textSecondary))),
                const Divider(height: 32),
                Text(l10n.progress, style: Theme.of(context).textTheme.titleLarge),
                for (final e in p.events)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.history),
                    title: Text(proposalActionLabel(l10n, e.action)),
                    subtitle: Text([e.actor, when.format(e.at), e.note].whereType<String>().join(' · ')),
                  ),
              ],
            );
          }),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(proposalDetailProvider(_key))),
        _ => const SkeletonList(),
      },
    );
  }
}

String proposalActionLabel(AppLocalizations l10n, String action) => switch (action) {
      'submitted' => l10n.propActSubmitted,
      'executive_counter' || 'proposer_counter' => l10n.propActCounter,
      'executive_approve' || 'proposer_approve' => l10n.propActApprove,
      'executive_reject' => l10n.propActReject,
      'proposer_withdraw' => l10n.propActWithdraw,
      _ => action,
    };
