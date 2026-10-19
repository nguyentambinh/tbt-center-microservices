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

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/employee.dart';
import '../providers/employee_providers.dart';

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
      appBar: AppBar(title: Text(l10n.employees)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchEmployees,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
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

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.familyFirst});

  final EmployeeSummary employee;
  final bool familyFirst;

  @override
  Widget build(BuildContext context) {
    final subtitle = [employee.position, employee.department].whereType<String>().join(' · ');
    return ListTile(
      leading: InitialsAvatar(initials: employee.initials),
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
