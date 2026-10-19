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
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/project_providers.dart';

/// Dự án theo hợp đồng và khách hàng (R100), cho tài chính, HR, quản lý.
class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => ref.read(projectSearchProvider.notifier).set(value));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final text = Theme.of(context).textTheme;
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.projects)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.searchProjects),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: switch (projects) {
              AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noProjects),
              AsyncValue(:final value?) => RefreshIndicator(
                  onRefresh: () => ref.refresh(projectsProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: value.length,
                    itemBuilder: (context, i) {
                      final p = value[i];
                      final money = NumberFormat.compactSimpleCurrency(locale: locale, name: p.currency);
                      return Card(
                        child: ListTile(
                          title: Text(p.name ?? p.id, style: text.titleMedium),
                          subtitle: Text(
                            '${p.id} · ${p.customerName ?? '-'}\n'
                            '${l10n.expectedAcceptance}: ${p.expectedAcceptance == null ? '-' : money.format(p.expectedAcceptance)}',
                            style: TextStyle(color: context.tbt.textSecondary),
                          ),
                          isThreeLine: true,
                          trailing: Text(l10n.employeesCount(p.members)),
                          onTap: () => context.push('${Routes.projects}/${Uri.encodeComponent(p.id)}'),
                        ),
                      );
                    },
                  ),
                ),
              AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(projectsProvider)),
              _ => const SkeletonList(),
            },
          ),
        ],
      ),
    );
  }
}
