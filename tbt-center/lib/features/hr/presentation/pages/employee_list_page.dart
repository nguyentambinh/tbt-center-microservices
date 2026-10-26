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
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/export/table_export.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../organization/presentation/providers/organization_providers.dart';
import '../../domain/entities/employee.dart';
import '../providers/employee_providers.dart';
import '../../../../core/widgets/input_rules.dart';

class EmployeeListPage extends ConsumerStatefulWidget {
  const EmployeeListPage({super.key});

  @override
  ConsumerState<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends ConsumerState<EmployeeListPage> {
  final _scroll = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      // Gần cuối danh sách thì tự tải trang tiếp theo.
      if (_scroll.position.extentAfter < 300) _loadMore();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    // Đợi người dùng gõ xong một nhịp rồi mới gọi server.
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(employeeListProvider.notifier).search(text.trim());
    });
  }

  Future<void> _loadMore() async {
    try {
      await ref.read(employeeListProvider.notifier).loadMore();
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(employeeListProvider);
    final familyFirst = ref.watch(authControllerProvider).value?.region == 'vn';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.employees),
        actions: [
          IconButton(tooltip: l10n.orgTree, icon: const Icon(Icons.account_tree_outlined), onPressed: () => context.push(Routes.orgTree)),
          ExportMenuButton(table: () {
            final items = ref.read(employeeListProvider).value?.items;
            if (items == null) return null;
            return ExportTable(
              title: l10n.employees,
              headers: [l10n.exportId, l10n.fullName, l10n.filterPosition, l10n.filterDepartment, l10n.filterCompany, l10n.fieldEmail],
              rows: [for (final e in items) [e.id, '${e.familyName} ${e.givenName}', e.position, e.department, e.company, e.email]],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              inputFormatters: InputRules.search,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchEmployees,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          _Filters(filter: list.value?.filter ?? const EmployeeFilter()),
          if (list.isLoading || (list.value?.searching ?? false)) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: switch (list) {
              AsyncValue(:final value?) => _buildList(context, value, familyFirst),
              AsyncValue(:final error?) => ErrorView(
                  error: error,
                  onRetry: () => ref.read(employeeListProvider.notifier).refresh(),
                ),
              _ => const SkeletonList(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, EmployeeListState state, bool familyFirst) {
    final l10n = AppLocalizations.of(context);
    if (state.items.isEmpty) return EmptyView(message: l10n.noEmployees, icon: Icons.person_search);

    return RefreshIndicator(
      onRefresh: () => ref.read(employeeListProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.items.length + 2,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                [l10n.employeeCount(state.total), if (state.fromCache) l10n.savedDataNote].join('  ·  '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.tbt.textSecondary),
              ),
            );
          }
          if (index == state.items.length + 1) return _Footer(state: state, onLoadMore: _loadMore);
          return _EmployeeTile(employee: state.items[index - 1], familyFirst: familyFirst);
        },
      ),
    );
  }
}

/// Lọc hồ sơ theo phòng ban, chức vụ, công ty, trạng thái
class _Filters extends ConsumerWidget {
  const _Filters({required this.filter});

  final EmployeeFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final options = ref.watch(employeeFiltersProvider).value;
    final controller = ref.read(employeeListProvider.notifier);
    EmployeeFilter copy({Object? departmentId = _keep, Object? positionId = _keep, Object? companyId = _keep, Object? status = _keep}) => EmployeeFilter(
          departmentId: departmentId == _keep ? filter.departmentId : departmentId as String?,
          positionId: positionId == _keep ? filter.positionId : positionId as String?,
          companyId: companyId == _keep ? filter.companyId : companyId as String?,
          status: status == _keep ? filter.status : status as String?,
        );
    return FilterBar(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      children: [
        FilterSpinner<String>(
          label: l10n.filterDepartment,
          value: filter.departmentId,
          options: [for (final d in options?.departments ?? const <({String id, String name})>[]) (value: d.id, label: d.name)],
          onChanged: (v) => controller.applyFilter(copy(departmentId: v)),
        ),
        FilterSpinner<String>(
          label: l10n.filterPosition,
          value: filter.positionId,
          options: [for (final p in options?.positions ?? const <({String id, String name})>[]) (value: p.id, label: p.name)],
          onChanged: (v) => controller.applyFilter(copy(positionId: v)),
        ),
        FilterSpinner<String>(
          label: l10n.filterCompany,
          width: 200,
          value: filter.companyId,
          options: [for (final c in options?.companies ?? const <({String id, String name})>[]) (value: c.id, label: c.name)],
          onChanged: (v) => controller.applyFilter(copy(companyId: v)),
        ),
        FilterSpinner<String>(
          label: l10n.filterStatus,
          value: filter.status,
          options: [(value: 'active', label: l10n.statusWorking), (value: 'archived', label: l10n.statusArchived)],
          onChanged: (v) => controller.applyFilter(copy(status: v)),
        ),
      ],
    );
  }
}

const _keep = Object();

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.familyFirst});

  final EmployeeSummary employee;
  final bool familyFirst;

  @override
  Widget build(BuildContext context) {
    final subtitle = [employee.position, employee.department].whereType<String>().join(' · ');
    return ListTile(
      leading: InitialsAvatar(initials: employee.initials, photoUrl: employee.photoUrl),
      title: Text(employee.fullName(familyFirst: familyFirst)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Icon(Icons.chevron_right, color: context.tbt.textSecondary),
      onTap: () => context.push('/employees/${Uri.encodeComponent(employee.id)}'),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onLoadMore});

  final EmployeeListState state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (state.loadingMore) {
      return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
    }
    if (!state.hasMore) return const SizedBox(height: 24);
    return Center(
      child: TextButton(onPressed: onLoadMore, child: Text(AppLocalizations.of(context).loadMore)),
    );
  }
}
