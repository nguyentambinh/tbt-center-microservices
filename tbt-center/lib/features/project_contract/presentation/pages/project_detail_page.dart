/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';

/// Tài chính, quản trị, lãnh đạo được nghiệm thu; khớp với service project_contract.
const projectAcceptRoles = {'finance', 'admin', 'executive'};

class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  Future<void> _accept(BuildContext context, WidgetRef ref, ProjectSummary project, String amount) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.acceptProject),
        content: Text(l10n.acceptProjectConfirm(amount)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.acceptProject)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(projectRepositoryProvider).accept(project.id);
      ref
        ..invalidate(projectDetailProvider(project.id))
        ..invalidate(projectsProvider);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final project = ref.watch(projectDetailProvider(projectId));
    final roles = ref.watch(authControllerProvider).value?.roles ?? const <String>[];
    final summary = project.value?.summary;
    final canAccept = summary != null && !summary.accepted && roles.any(projectAcceptRoles.contains);
    return Scaffold(
      appBar: AppBar(title: Text(projectId)),
      bottomNavigationBar: canAccept
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  icon: const Icon(Icons.task_alt),
                  label: Text(l10n.acceptProject),
                  onPressed: () => _accept(
                    context,
                    ref,
                    summary,
                    NumberFormat.simpleCurrency(locale: locale, name: summary.currency)
                        .format(summary.expectedAcceptance ?? 0),
                  ),
                ),
              ),
            )
          : null,
      body: switch (project) {
        AsyncValue(:final value?) => _DetailView(project: value),
        AsyncValue(:final error?) =>
          ErrorView(error: error, onRetry: () => ref.invalidate(projectDetailProvider(projectId))),
        _ => const SkeletonList(),
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.project});

  final ProjectDetail project;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final text = Theme.of(context).textTheme;
    final s = project.summary;
    final money = NumberFormat.simpleCurrency(locale: locale, name: s.currency);
    String day(DateTime? d) => d == null ? '-' : DateFormat.yMMMd(locale).format(d);
    String amount(double? v) => v == null ? '-' : money.format(v);

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
              Flexible(child: Text(value, textAlign: TextAlign.end)),
            ],
          ),
        );

    Widget section(String title, List<Widget> children) => Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(title, style: text.titleLarge), const SizedBox(height: 8), ...children],
            ),
          ),
        );

    final customer = project.customer;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(s.name ?? s.id, style: text.headlineSmall),
        const SizedBox(height: 8),
        Chip(
          avatar: Icon(s.accepted ? Icons.task_alt : Icons.construction, size: 16),
          label: Text(s.accepted ? l10n.projectAcceptedOn(day(s.acceptedOn)) : l10n.projectInProgress),
        ),
        for (final n in project.notices)
          Text(
            l10n.customerNotice(n.channel == 'email' ? 'Email' : 'SMS', n.status == 'sent' ? l10n.noticeSent : l10n.noticeQueued),
            style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        const SizedBox(height: 12),
        section(l10n.projectMoney, [
          row(l10n.deposit, amount(s.deposit)),
          row(l10n.expectedAcceptance, amount(s.expectedAcceptance)),
        ]),
        if (customer != null)
          section(l10n.customer, [
            row(l10n.fullName, customer.name),
            if (customer.contact != null) row(l10n.fieldPhone, customer.contact!),
            if (customer.address != null) row(l10n.fieldAddress, customer.address!),
            if (customer.contact == null)
              Text(l10n.customerContactHidden, style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ]),
        section(l10n.contracts, [
          if (project.contracts.isEmpty) Text(l10n.noData),
          for (final c in project.contracts)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(c.name ?? c.contractId),
              subtitle: Text('${day(c.startDate)} – ${day(c.endDate ?? c.expectedEndDate)}'),
            ),
        ]),
        section(l10n.projectMembers, [
          if (project.members.isEmpty) Text(l10n.noData),
          for (final m in project.members)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(m.employeeId),
              subtitle: m.projectSalary == null ? null : Text(amount(m.projectSalary)),
              trailing: Text(l10n.hoursValue(NumberFormat.decimalPattern(locale).format(m.hours))),
            ),
        ]),
      ],
    );
  }
}
