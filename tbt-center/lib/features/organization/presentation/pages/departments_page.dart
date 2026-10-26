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

import '../../../../core/error/error_reporter.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/organization.dart';
import '../providers/organization_providers.dart';
import '../widgets/head_tag.dart';
import '../widgets/org_actions.dart';

/// Danh sách phòng ban: thêm, giải thể, mở chi tiết để điều chuyển
class DepartmentsPage extends ConsumerStatefulWidget {
  const DepartmentsPage({super.key});

  @override
  ConsumerState<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends ConsumerState<DepartmentsPage> {
  String? _company;

  Future<void> _create(List<Department> all) async {
    final l10n = AppLocalizations.of(context);
    final EmployeeFilters filters;
    try {
      filters = await ref.read(employeeFiltersProvider.future);
    } on Object catch (e) {
      reportFailure(e);
      return;
    }
    if (!mounted || filters.companies.isEmpty) return;
    final name = TextEditingController();
    var company = _company ?? filters.companies.first.id;
    final form = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: Text(l10n.departmentAdd),
          content: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  autofocus: true,
                  decoration: InputDecoration(labelText: l10n.departmentName),
                  validator: (v) {
                    final text = (v ?? '').trim();
                    if (text.isEmpty) return l10n.fieldRequired;
                    if (all.any((d) => d.name.toLowerCase() == text.toLowerCase() && d.companyId == company)) return l10n.departmentNameTaken;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: company,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.filterCompany),
                  items: [for (final c in filters.companies) DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))],
                  onChanged: (v) => setDialog(() => company = v ?? company),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                if (form.currentState!.validate()) Navigator.pop(context, true);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      final created = await ref.read(organizationRepositoryProvider).createDepartment(name.text.trim(), company);
      ref.invalidate(departmentsProvider);
      ref.invalidate(employeeFiltersProvider);
      showDone(l10n.departmentCreated(created.name));
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final departments = ref.watch(departmentsProvider);
    final unassigned = ref.watch(unassignedProvider).value?.length ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.departments),
        actions: [IconButton(tooltip: l10n.orgTree, icon: const Icon(Icons.account_tree_outlined), onPressed: () => context.push(Routes.orgTree))],
      ),
      floatingActionButton: departments.hasValue
          ? FloatingActionButton.extended(
              onPressed: () => _create(departments.value!),
              icon: const Icon(Icons.add),
              label: Text(l10n.departmentAdd),
            )
          : null,
      body: switch (departments) {
        AsyncValue(:final value?) => _buildList(context, value, unassigned),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(departmentsProvider)),
        _ => const SkeletonList(),
      },
    );
  }

  Widget _buildList(BuildContext context, List<Department> all, int unassigned) {
    final l10n = AppLocalizations.of(context);
    final companies = <String, String>{for (final d in all) if (d.companyId != null) d.companyId!: d.company ?? d.companyId!};
    final shown = all.where((d) => _company == null || d.companyId == _company).toList();
    return RefreshIndicator(
      onRefresh: () {
        ref.invalidate(unassignedProvider);
        return ref.refresh(departmentsProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          FilterBar(
            children: [
              FilterSpinner<String>(
                label: l10n.filterCompany,
                width: 220,
                value: _company,
                options: [for (final e in companies.entries) (value: e.key, label: e.value)],
                onChanged: (v) => setState(() => _company = v),
              ),
            ],
          ),
          if (unassigned > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                  title: Text(l10n.unassignedCount(unassigned), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(l10n.unassignedHint),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.unassigned),
                ),
              ),
            ),
          if (shown.isEmpty) EmptyView(message: l10n.noDepartments, icon: Icons.apartment_outlined),
          for (final d in shown)
            FadeSlideIn(
              child: ListTile(
                leading: CircleAvatar(child: Text('${d.members}')),
                title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (d.company case final c?) Text(c, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (d.headName case final head?)
                      Row(children: [const HeadTag(), const SizedBox(width: 6), Flexible(child: Text(head, overflow: TextOverflow.ellipsis))])
                    else
                      Text(l10n.noHead, style: TextStyle(color: context.tbt.caution)),
                  ],
                ),
                trailing: Icon(Icons.chevron_right, color: context.tbt.textSecondary),
                onTap: () => context.push('${Routes.departments}/${Uri.encodeComponent(d.id)}'),
              ),
            ),
        ],
      ),
    );
  }
}
