/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/organization.dart';
import '../providers/organization_providers.dart';
import '../widgets/org_actions.dart';

/// Người mới nhận việc chưa có phòng ban; AI gợi ý xếp phòng hoặc lập phòng mới
class UnassignedPage extends ConsumerStatefulWidget {
  const UnassignedPage({super.key});

  @override
  ConsumerState<UnassignedPage> createState() => _UnassignedPageState();
}

class _UnassignedPageState extends ConsumerState<UnassignedPage> {
  PlacementSuggestion? _suggestion;
  bool _asking = false;
  final _done = <String>{};

  Future<void> _ask() async {
    setState(() => _asking = true);
    try {
      final language = Localizations.localeOf(context).languageCode;
      final result = await ref.read(organizationRepositoryProvider).suggest(language: language);
      if (mounted) setState(() => _suggestion = result);
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _asking = false);
    }
  }

  void _refresh() {
    ref.invalidate(unassignedProvider);
    ref.invalidate(departmentsProvider);
    ref.invalidate(departmentDetailProvider);
  }

  Future<void> _accept(String departmentId, List<String> employeeIds, String departmentName) async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await ref.read(organizationRepositoryProvider).transfer(departmentId, employeeIds);
      setState(() => _done.addAll(result.moved));
      _refresh();
      showDone(l10n.transferDone(departmentName));
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  Future<void> _createAndMove(({String name, String reason, List<String> employeeIds}) proposal) async {
    final l10n = AppLocalizations.of(context);
    final repository = ref.read(organizationRepositoryProvider);
    try {
      final filters = await ref.read(employeeFiltersProvider.future);
      if (filters.companies.isEmpty) return;
      final created = await repository.createDepartment(proposal.name, filters.companies.first.id);
      showDone(l10n.departmentCreated(created.name));
      await _accept(created.id, proposal.employeeIds, created.name);
      ref.invalidate(employeeFiltersProvider);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final people = ref.watch(unassignedProvider);
    final departments = {for (final d in ref.watch(departmentsProvider).value ?? const <Department>[]) d.id: d};
    return Scaffold(
      appBar: AppBar(title: Text(l10n.unassignedStaff)),
      body: switch (people) {
        AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noUnassigned, icon: Icons.how_to_reg_outlined),
        AsyncValue(:final value?) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              FilledButton.icon(
                onPressed: _asking ? null : _ask,
                icon: _asking ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
                label: Text(_asking ? l10n.aiThinking : l10n.aiSuggestPlacement),
              ),
              if (_suggestion case final s?) ...[
                const SizedBox(height: 8),
                Text(s.byAi ? l10n.suggestionByAi : l10n.suggestionByRules, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.tbt.textSecondary)),
              ],
              const SizedBox(height: 12),
              for (final p in value)
                FadeSlideIn(child: _PersonCard(person: p, suggestion: _suggestion, departments: departments, done: _done.contains(p.id), onAccept: _accept)),
              if (_suggestion case final s? when s.newDepartments.isNotEmpty) ...[
                const SizedBox(height: 16),
                SectionLabel(l10n.newDepartmentProposals),
                for (final n in s.newDepartments)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(n.reason),
                          const SizedBox(height: 4),
                          Text(
                            [for (final id in n.employeeIds) value.where((p) => p.id == id).firstOrNull?.name ?? id].join(', '),
                            style: TextStyle(color: context.tbt.textSecondary),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.tonal(
                              onPressed: n.employeeIds.every(_done.contains) ? null : () => _createAndMove(n),
                              child: Text(l10n.createDepartmentAndMove),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(unassignedProvider)),
        _ => const SkeletonList(),
      },
    );
  }
}

class _PersonCard extends ConsumerWidget {
  const _PersonCard({required this.person, required this.suggestion, required this.departments, required this.done, required this.onAccept});

  final OrgPerson person;
  final PlacementSuggestion? suggestion;
  final Map<String, Department> departments;
  final bool done;
  final Future<void> Function(String departmentId, List<String> employeeIds, String departmentName) onAccept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pick = suggestion?.assignments.where((a) => a.employeeId == person.id).firstOrNull;
    final target = pick == null ? null : departments[pick.departmentId];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: InitialsAvatar(initials: person.initials, photoUrl: person.photoUrl),
              title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(person.position ?? ''),
              trailing: done ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
            ),
            if (!done)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: target == null
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.drive_file_move_outline),
                          label: Text(l10n.chooseDepartment),
                          onPressed: () => transferEmployee(context, ref, person.id),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.suggestedDepartment(target.name), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                          Text(pick!.reason, style: TextStyle(color: context.tbt.textSecondary)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(onPressed: () => transferEmployee(context, ref, person.id), child: Text(l10n.chooseOther)),
                              FilledButton(onPressed: () => onAccept(target.id, [person.id], target.name), child: Text(l10n.acceptSuggestion)),
                            ],
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
