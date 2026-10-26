/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../core/widgets/remote_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/domain/entities/work_calendar.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../payroll/presentation/providers/payroll_providers.dart';
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

class _DetailView extends ConsumerWidget {
  const _DetailView({required this.project});

  final ProjectDetail project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Expanded(child: Text(label, style: TextStyle(color: context.tbt.textSecondary))),
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
        RemotePhoto(url: s.imageUrl),
        const SizedBox(height: 16),
        Text(s.name ?? s.id, style: text.headlineSmall),
        const SizedBox(height: 8),
        Chip(
          avatar: Icon(s.accepted ? Icons.task_alt : Icons.construction, size: 16),
          label: Text(s.accepted ? l10n.projectAcceptedOn(day(s.acceptedOn)) : l10n.projectInProgress),
        ),
        if (s.overdue) Chip(avatar: Icon(Icons.alarm, size: 16, color: context.tbt.danger), label: Text(l10n.projectOverdue, style: TextStyle(color: context.tbt.danger))),
        for (final n in project.notices)
          Text(
            l10n.customerNotice(n.channel == 'email' ? 'Email' : 'SMS', n.status == 'sent' ? l10n.noticeSent : l10n.noticeQueued),
            style: text.bodySmall?.copyWith(color: context.tbt.textSecondary),
          ),
        const SizedBox(height: 12),
        // Nhân viên thường không được xem tiền dự án: server không trả hai trường này
        if (s.deposit != null || s.expectedAcceptance != null)
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
              Text(l10n.customerContactHidden, style: text.bodySmall?.copyWith(color: context.tbt.textSecondary)),
          ]),
        section(l10n.contracts, [
          if (project.contracts.isEmpty) Text(l10n.noData),
          for (final c in project.contracts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name ?? c.contractId, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${c.contractId} · ${day(c.startDate)} – ${day(c.endDate ?? c.expectedEndDate)}', style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
                  if (c.summary case final summary? when summary.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(summary)),
                  if (c.fileUrl case final url?)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.description_outlined),
                        label: Text(l10n.openContract),
                        onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                      ),
                    ),
                ],
              ),
            ),
        ]),
        if (project.members.any((m) => m.isMe)) _MySchedule(project: s),
        section(l10n.projectMembers, [
          if (project.members.isEmpty) Text(l10n.noData),
          for (final m in [...project.members]..sort((a, b) => (b.isMe ? 1 : 0) - (a.isMe ? 1 : 0)))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: m.isMe ? Theme.of(context).colorScheme.primary : null,
                child: Icon(Icons.person, size: 18, color: m.isMe ? Theme.of(context).colorScheme.onPrimary : null),
              ),
              title: Text(m.isMe ? l10n.me : (m.name ?? m.employeeId ?? '-'), style: TextStyle(fontWeight: m.isMe ? FontWeight.bold : null)),
              // Mã nhân viên chỉ người quản lý thấy
              subtitle: Text(
                [
                  ?m.employeeId,
                  if (m.projectSalary != null) m.isMe ? l10n.myProjectPay(amount(m.projectSalary)) : amount(m.projectSalary),
                ].join(' · '),
              ),
              trailing: Text(l10n.hoursValue(NumberFormat.decimalPattern(locale).format(m.hours))),
            ),
        ]),
      ],
    );
  }
}

/// Lịch làm việc của tôi trong tháng này, trong thời gian của dự án: ngày, giờ vào ra, tiền ước tính
class _MySchedule extends ConsumerWidget {
  const _MySchedule({required this.project});

  final ProjectSummary project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final days = ref.watch(calendarProvider(month)).value ?? const <CalendarDay>[];
    final salary = ref.watch(myPayrollProvider).value;
    final money = NumberFormat.simpleCurrency(locale: locale, name: salary?.currency ?? project.currency);
    final start = project.startDate;
    final end = project.endDate;
    final inProject = [
      for (final d in days)
        if (d.hasShift && (start == null || !d.date.isBefore(start)) && (end == null || !d.date.isAfter(end))) d,
    ];
    final shown = inProject.where((d) => !d.date.isAfter(now)).toList().reversed.take(7).toList();
    final base = salary?.baseSalary;
    final total = base == null ? null : inProject.fold<double>(0, (s, d) => s + estimatedDayPay(d, base));
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.mySchedule, style: Theme.of(context).textTheme.titleLarge),
            Text(l10n.myScheduleHint(inProject.where((d) => d.worked).length), style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
            if (total != null) Text(l10n.myScheduleEarned(money.format(total)), style: TextStyle(color: context.tbt.success, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (shown.isEmpty) Text(l10n.noData, style: TextStyle(color: context.tbt.textSecondary)),
            for (final d in shown)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(DateFormat.MMMEd(locale).format(d.date)),
                subtitle: Text(d.worked ? '${d.checkIn} – ${d.checkOut ?? '...'} · ${l10n.hoursValue(NumberFormat.decimalPattern(locale).format(d.totalHours))}' : (d.onLeave ? (d.leaveType ?? '') : l10n.notCheckedIn)),
                trailing: base == null || !d.worked ? null : Text(money.format(estimatedDayPay(d, base))),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => context.push(Routes.workCalendar), child: Text(l10n.openFullPage)),
            ),
          ],
        ),
      ),
    );
  }
}
