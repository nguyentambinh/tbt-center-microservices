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

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/organization.dart';
import '../providers/organization_providers.dart';
import '../widgets/org_actions.dart';

/// Bảng xếp hạng nhân viên xuất sắc theo giờ làm, tăng ca, ngày công
class RankingsPage extends ConsumerStatefulWidget {
  const RankingsPage({super.key});

  @override
  ConsumerState<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends ConsumerState<RankingsPage> {
  int? _months = 3;
  String? _department;

  Future<void> _actions(OrgPerson p) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.badge_outlined), title: Text(l10n.viewProfile), onTap: () => Navigator.pop(context, 'profile')),
            ListTile(leading: const Icon(Icons.workspace_premium_outlined), title: Text(l10n.nominatePromotion), onTap: () => Navigator.pop(context, 'nominate')),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (choice == 'profile') context.push('${Routes.employees}/${Uri.encodeComponent(p.id)}');
    if (choice == 'nominate') await nominateEmployee(context, ref, employeeId: p.id, name: p.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = (months: _months ?? 12, departmentId: _department);
    final rankings = ref.watch(rankingsProvider(query));
    final departments = ref.watch(departmentsProvider).value ?? const <Department>[];
    final canNominate = ref.watch(authControllerProvider).value?.roles.any({'hr', 'admin'}.contains) ?? false;
    final number = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.rankings)),
      body: Column(
        children: [
          FilterBar(
            children: [
              FilterSpinner<int>(
                label: l10n.filterPeriod,
                value: _months,
                options: [for (final m in const [1, 3, 6, 12]) (value: m, label: l10n.lastMonths(m))],
                onChanged: (v) => setState(() => _months = v),
              ),
              FilterSpinner<String>(
                label: l10n.filterDepartment,
                width: 200,
                value: _department,
                options: [for (final d in departments) (value: d.id, label: d.name)],
                onChanged: (v) => setState(() => _department = v),
              ),
            ],
          ),
          Expanded(
            child: switch (rankings) {
              AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noRankings, icon: Icons.emoji_events_outlined),
              AsyncValue(:final value?) => RefreshIndicator(
                  onRefresh: () => ref.refresh(rankingsProvider(query).future),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(l10n.rankingFormula, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.tbt.textSecondary)),
                      ),
                      for (final p in value)
                        FadeSlideIn(
                          child: Card(
                            child: ListTile(
                              leading: _RankBadge(rank: p.rank, initials: p.initials, photoUrl: p.photoUrl),
                              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                [
                                  [p.position, p.department].whereType<String>().join(' · '),
                                  l10n.rankingDetail(number.format(p.workHours), number.format(p.overtimeHours), p.days),
                                ].join('\n'),
                              ),
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(number.format(p.score), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                                  Text(l10n.points, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                              onTap: () => canNominate ? _actions(p) : context.push('${Routes.employees}/${Uri.encodeComponent(p.id)}'),
                            ),
                          ),
                        ),
                      if (canNominate)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.workspace_premium_outlined),
                            label: Text(l10n.nominations),
                            onPressed: () => context.push(Routes.nominations),
                          ),
                        ),
                    ],
                  ),
                ),
              AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(rankingsProvider(query))),
              _ => const SkeletonList(),
            },
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.initials, this.photoUrl});

  final int rank;
  final String initials;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    const medals = [Color(0xFFE6B422), Color(0xFFB8C0C8), Color(0xFFCD7F32)];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InitialsAvatar(initials: initials, photoUrl: photoUrl),
        Positioned(
          right: -4,
          bottom: -4,
          child: CircleAvatar(
            radius: 11,
            backgroundColor: rank <= 3 ? medals[rank - 1] : Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text('$rank', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: rank <= 3 ? Colors.black : null)),
          ),
        ),
      ],
    );
  }
}
