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

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/config/env.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/locale/l10n_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/organization.dart';
import '../providers/organization_providers.dart';
import '../widgets/org_actions.dart';
import '../../../../core/widgets/input_rules.dart';

/// Đề cử thăng chức: HR theo dõi, Ban lãnh đạo duyệt (đổi chức vụ và tăng lương)
class NominationsPage extends ConsumerStatefulWidget {
  const NominationsPage({super.key});

  @override
  ConsumerState<NominationsPage> createState() => _NominationsPageState();
}

class _NominationsPageState extends ConsumerState<NominationsPage> {
  String? _status = 'pending';
  String? _region;

  Future<void> _decide(String region, Nomination n, bool approve) async {
    final l10n = AppLocalizations.of(context);
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? l10n.approvePromotion : l10n.reject),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (approve) Text(l10n.approvePromotionHint(n.employeeName, n.proposedPosition, NumberFormat.decimalPattern().format(n.raisePercent))),
            const SizedBox(height: 12),
            TextField(inputFormatters: InputRules.note, controller: note, decoration: InputDecoration(labelText: l10n.decisionNote), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(approve ? l10n.approve : l10n.reject)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final raised = await ref.read(regionOrganizationProvider(region)).decideNomination(n.id, approve: approve, note: note.text.trim().isEmpty ? null : note.text.trim());
      ref.invalidate(nominationsProvider);
      ref.invalidate(pendingNominationsProvider);
      showDone(!approve ? l10n.promotionRejected : raised ? l10n.promotionApproved : l10n.promotionApprovedNoRaise);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider).value;
    final executive = session?.roles.contains('executive') ?? false;
    final region = _region ?? session?.region ?? 'vn';
    final query = (region: region, status: _status);
    final items = ref.watch(nominationsProvider(query));
    final locale = Localizations.localeOf(context).toString();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nominations)),
      body: Column(
        children: [
          FilterBar(
            children: [
              FilterSpinner<String>(
                label: l10n.filterStatus,
                value: _status,
                options: [
                  (value: 'pending', label: l10n.statusPending),
                  (value: 'approved', label: l10n.statusApproved),
                  (value: 'rejected', label: l10n.statusRejected),
                ],
                onChanged: (v) => setState(() => _status = v),
              ),
              // Ban lãnh đạo duyệt đề cử của mọi khu vực
              if (executive)
                FilterSpinner<String>(
                  label: l10n.filterRegion,
                  value: region,
                  options: [for (final r in Env.regions) (value: r, label: l10n.regionName(r))],
                  onChanged: (v) => setState(() => _region = v ?? session?.region),
                ),
            ],
          ),
          Expanded(
            child: switch (items) {
              AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noNominations, icon: Icons.workspace_premium_outlined),
              AsyncValue(:final value?) => RefreshIndicator(
                  onRefresh: () => ref.refresh(nominationsProvider(query).future),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    children: [
                      for (final n in value)
                        FadeSlideIn(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      InitialsAvatar(initials: n.employeeName.isEmpty ? '?' : n.employeeName[0], photoUrl: n.photoUrl),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(n.employeeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            Text('${n.currentPosition ?? '-'}  →  ${n.proposedPosition}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                          ],
                                        ),
                                      ),
                                      _StatusChip(status: n.status),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(l10n.raiseBy(NumberFormat.decimalPattern(locale).format(n.raisePercent))),
                                  Text(n.reason, style: TextStyle(color: context.tbt.textSecondary)),
                                  if (n.createdAt != null)
                                    Text(DateFormat.yMMMd(locale).add_Hm().format(n.createdAt!.toLocal()), style: Theme.of(context).textTheme.bodySmall),
                                  if (n.note != null && n.note!.isNotEmpty) Text('${l10n.decisionNote}: ${n.note}'),
                                  // Đề cử lên cấp tập đoàn chỉ văn phòng tập đoàn duyệt
                                  if (executive && n.pending && (!n.toGroup || (session?.isGroup ?? false)))
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton(onPressed: () => _decide(region, n, false), child: Text(l10n.reject)),
                                        const SizedBox(width: 8),
                                        FilledButton(onPressed: () => _decide(region, n, true), child: Text(l10n.approve)),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(nominationsProvider(query))),
              _ => const SkeletonList(),
            },
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      'approved' => (l10n.statusApproved, scheme.primary),
      'rejected' => (l10n.statusRejected, scheme.error),
      _ => (l10n.statusPending, context.tbt.textSecondary),
    };
    return Chip(label: Text(label, style: TextStyle(color: color)), visualDensity: VisualDensity.compact);
  }
}
