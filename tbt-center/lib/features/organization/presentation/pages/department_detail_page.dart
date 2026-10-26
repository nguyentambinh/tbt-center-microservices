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

import '../../../../core/error/error_reporter.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/organization.dart';
import '../providers/organization_providers.dart';
import '../widgets/head_tag.dart';
import '../widgets/org_actions.dart';

/// Thành viên phòng ban: trưởng phòng đầu tiên, còn lại theo tổng giờ làm
class DepartmentDetailPage extends ConsumerWidget {
  const DepartmentDetailPage({super.key, required this.departmentId});

  final String departmentId;

  void _refresh(WidgetRef ref) {
    ref.invalidate(departmentDetailProvider(departmentId));
    ref.invalidate(departmentsProvider);
    ref.invalidate(unassignedProvider);
  }

  Future<void> _setHead(BuildContext context, WidgetRef ref, OrgPerson person) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(organizationRepositoryProvider).setHead(departmentId, person.id);
      _refresh(ref);
      showDone(l10n.headAssigned(person.name));
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  Future<void> _addMembers(BuildContext context, WidgetRef ref, DepartmentDetail detail) async {
    final l10n = AppLocalizations.of(context);
    final source = await pickDepartment(context, ref, exclude: departmentId, title: l10n.addMembersFrom);
    if (source == null || !context.mounted) return;
    final DepartmentDetail from;
    try {
      from = await ref.read(departmentDetailProvider(source.id).future);
    } on Object catch (e) {
      reportFailure(e);
      return;
    }
    if (!context.mounted) return;
    final picked = <String>{};
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: Text(l10n.addMembersTitle(detail.department.name)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final p in from.members)
                  CheckboxListTile(
                    value: picked.contains(p.id),
                    // Trưởng phòng và người cuối cùng của phòng không chuyển đi được
                    enabled: !p.isHead && from.members.length - picked.length > 1 || picked.contains(p.id),
                    title: Text(p.name),
                    subtitle: Text(p.isHead ? l10n.departmentHead : (p.position ?? '')),
                    onChanged: (v) => setDialog(() => v == true ? picked.add(p.id) : picked.remove(p.id)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(onPressed: picked.isEmpty ? null : () => Navigator.pop(context, true), child: Text(l10n.moveHere)),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      final result = await ref.read(organizationRepositoryProvider).transfer(departmentId, picked.toList());
      _refresh(ref);
      ref.invalidate(departmentDetailProvider(source.id));
      showDone(result.failed.isEmpty ? l10n.membersMoved(result.moved.length) : l10n.membersMovedPartly(result.moved.length, result.failed.length));
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  Future<void> _dissolve(BuildContext context, WidgetRef ref, DepartmentDetail detail) async {
    final l10n = AppLocalizations.of(context);
    var reason = dissolutionReasons.first;
    Department? mergeInto;
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          icon: Icon(Icons.domain_disabled_outlined, color: Theme.of(context).colorScheme.error),
          title: Text(l10n.dissolveTitle(detail.department.name)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dissolveReason, style: Theme.of(context).textTheme.labelLarge),
                RadioGroup<String>(
                  groupValue: reason,
                  onChanged: (v) => setDialog(() => reason = v ?? reason),
                  child: Column(
                    children: [
                      for (final code in dissolutionReasons)
                        RadioListTile<String>(value: code, contentPadding: EdgeInsets.zero, title: Text(dissolutionReasonLabel(l10n, code))),
                    ],
                  ),
                ),
                if (detail.members.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(l10n.dissolveMembersMove(detail.members.length)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.call_merge),
                    label: Text(mergeInto?.name ?? l10n.chooseReceivingDepartment),
                    onPressed: () async {
                      final picked = await pickDepartment(context, ref, exclude: departmentId, title: l10n.chooseReceivingDepartment);
                      if (picked != null) setDialog(() => mergeInto = picked);
                    },
                  ),
                ],
                const SizedBox(height: 12),
                TextField(controller: note, maxLines: 2, decoration: InputDecoration(labelText: l10n.note)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: detail.members.isNotEmpty && mergeInto == null ? null : () => Navigator.pop(context, true),
              child: Text(l10n.dissolveConfirm),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(organizationRepositoryProvider).dissolve(departmentId, reasonCode: reason, note: note.text.trim().isEmpty ? null : note.text.trim(), mergeInto: mergeInto?.id);
      ref.invalidate(departmentsProvider);
      showDone(l10n.dissolveDone(detail.department.name));
      if (context.mounted) context.pop();
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(departmentDetailProvider(departmentId));
    return Scaffold(
      appBar: AppBar(
        title: Text(detail.value?.department.name ?? l10n.departments),
        actions: [
          if (detail.value case final d?)
            PopupMenuButton<String>(
              onSelected: (v) => v == 'dissolve' ? _dissolve(context, ref, d) : _addMembers(context, ref, d),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'add', child: Text(l10n.addMembers)),
                PopupMenuItem(value: 'dissolve', child: Text(l10n.dissolveDepartment, style: TextStyle(color: Theme.of(context).colorScheme.error))),
              ],
            ),
        ],
      ),
      floatingActionButton: detail.value == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _addMembers(context, ref, detail.value!),
              icon: const Icon(Icons.group_add_outlined),
              label: Text(l10n.addMembers),
            ),
      body: switch (detail) {
        AsyncValue(:final value?) => _members(context, ref, value),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(departmentDetailProvider(departmentId))),
        _ => const SkeletonList(),
      },
    );
  }

  Widget _members(BuildContext context, WidgetRef ref, DepartmentDetail detail) {
    final l10n = AppLocalizations.of(context);
    final hours = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    if (detail.members.isEmpty) return EmptyView(message: l10n.departmentEmpty, icon: Icons.group_off_outlined);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(departmentDetailProvider(departmentId).future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              [detail.department.company, l10n.departmentMembers(detail.members.length)].whereType<String>().join(' · '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.tbt.textSecondary),
            ),
          ),
          for (final p in detail.members)
            FadeSlideIn(
              child: ListTile(
                leading: InitialsAvatar(initials: p.initials, photoUrl: p.photoUrl),
                title: Row(
                  children: [
                    Flexible(child: Text(p.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))),
                    if (p.isHead) ...[const SizedBox(width: 8), const HeadTag()],
                  ],
                ),
                subtitle: Text([p.position, l10n.memberHours(hours.format(p.totalHours))].whereType<String>().join(' · ')),
                onTap: () => context.push('${Routes.employees}/${Uri.encodeComponent(p.id)}'),
                // Trưởng phòng phải giao lại cho người khác trước khi chuyển đi
                trailing: p.isHead ? null : PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'head') await _setHead(context, ref, p);
                    if (v == 'move' && context.mounted && await transferEmployee(context, ref, p.id, fromDepartment: departmentId)) _refresh(ref);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'head', child: Text(l10n.setHead)),
                    PopupMenuItem(value: 'move', child: Text(l10n.moveToDepartment)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
