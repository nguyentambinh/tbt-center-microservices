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

import '../../../../core/error/error_reporter.dart';
import '../../../../core/locale/event_names.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../recruitment/presentation/widgets/stage_widgets.dart';
import '../../../../core/widgets/filter_bar.dart';
import '../../domain/entities/app_notification.dart';
import '../notification_target.dart';
import '../providers/notification_providers.dart';

/// Nhóm của từng loại thông báo, để lọc
String notificationGroup(String kind) => switch (kind) {
      'leave_requested' || 'leave_approved' || 'leave_rejected' || 'overtime_requested' || 'overtime_approved' || 'overtime_rejected' => 'attendance',
      'candidate_applied' || 'candidate_status' || 'interview_scheduled' || 'interview_confirmed' || 'interview_confirmed_hr' || 'interview_proposed' => 'recruitment',
      'payroll_paid' || 'payroll_failed' || 'payslip_issued' || 'payroll_needs_attention' || 'salary_changed' || 'bonus_granted' || 'penalty_applied' => 'payroll',
      'finance_closed' => 'finance',
      'project_accepted' || 'project_proposed' || 'project_countered' || 'project_approved' || 'project_rejected' => 'project',
      'profile_change_requested' || 'profile_change_approved' || 'profile_change_rejected' => 'profile',
      'promotion_nominated' || 'promotion_approved' || 'promotion_rejected' || 'promotion_approved_hr' || 'promotion_rejected_hr' || 'employee_transferred' || 'department_head_assigned' || 'position_changed' => 'organization',
      _ => 'other',
    };

/// Hộp thông báo (R18, R97): đơn nghỉ, tăng ca, phát lương, hồ sơ ứng tuyển, hồ sơ cá nhân; lọc theo đã đọc và nhóm.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool? _read;
  String? _group;

  Future<void> _markAllRead() async {
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
      ref.invalidate(inboxProvider);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inbox = ref.watch(inboxProvider);
    final groups = [
      (value: 'attendance', label: l10n.attendance),
      (value: 'recruitment', label: l10n.candidates),
      (value: 'payroll', label: l10n.payslips),
      (value: 'finance', label: l10n.finance),
      (value: 'project', label: l10n.projects),
      (value: 'profile', label: l10n.myProfile),
      (value: 'organization', label: l10n.departments),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          if (inbox.value case Inbox(unread: > 0))
            TextButton(onPressed: _markAllRead, child: Text(l10n.markAllRead)),
        ],
      ),
      bottomNavigationBar: const TbtBottomNav(current: Routes.notifications),
      body: Column(
        children: [
          FilterBar(
            children: [
              FilterSpinner<bool>(
                label: l10n.filterStatus,
                value: _read,
                options: [(value: false, label: l10n.filterUnread), (value: true, label: l10n.filterRead)],
                onChanged: (v) => setState(() => _read = v),
              ),
              FilterSpinner<String>(label: l10n.filterType, value: _group, options: groups, onChanged: (v) => setState(() => _group = v)),
            ],
          ),
          Expanded(
            child: switch (inbox) {
              AsyncValue(:final value?) when value.items.isEmpty =>
                EmptyView(message: l10n.noNotifications, icon: Icons.notifications_none),
              AsyncValue(:final value?) => RefreshIndicator(
                  onRefresh: () => ref.refresh(inboxProvider.future),
                  child: ListView(
                    children: [
                      for (final n in value.items)
                        if ((_read == null || n.read == _read) && (_group == null || notificationGroup(n.kind) == _group))
                          _NotificationTile(notification: n),
                    ],
                  ),
                ),
              AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(inboxProvider)),
              _ => const SkeletonList(),
            },
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final accent = Theme.of(context).colorScheme.primary;
    return ListTile(
      leading: Icon(_iconFor(notification.kind), color: notification.read ? context.tbt.textSecondary : accent),
      title: Text(
        notificationText(l10n, notification, locale),
        style: TextStyle(fontWeight: notification.read ? FontWeight.normal : FontWeight.w600),
      ),
      subtitle: Text(
        DateFormat.yMMMd(locale).add_Hm().format(notification.createdAt),
        style: TextStyle(color: context.tbt.textSecondary),
      ),
      trailing: notification.read ? null : Icon(Icons.circle, size: 10, color: accent),
      onTap: () => openNotification(context, ref, notification),
    );
  }

  static IconData _iconFor(String kind) => switch (kind) {
        'leave_requested' || 'leave_approved' || 'leave_rejected' => Icons.beach_access_outlined,
        'overtime_requested' || 'overtime_approved' || 'overtime_rejected' => Icons.more_time,
        'candidate_applied' || 'candidate_status' => Icons.work_outline,
        'interview_scheduled' || 'interview_confirmed' || 'interview_confirmed_hr' || 'interview_proposed' => Icons.event,
        'payroll_paid' || 'payroll_failed' || 'payslip_issued' => Icons.payments_outlined,
        'payroll_needs_attention' => Icons.warning_amber_outlined,
        'finance_closed' => Icons.lock_outline,
        'project_accepted' => Icons.task_alt,
        'project_proposed' || 'project_countered' || 'project_approved' || 'project_rejected' => Icons.fact_check_outlined,
        'profile_change_requested' || 'profile_change_approved' || 'profile_change_rejected' => Icons.manage_accounts_outlined,
        'promotion_nominated' || 'promotion_approved' || 'promotion_rejected' || 'promotion_approved_hr' || 'promotion_rejected_hr' => Icons.workspace_premium_outlined,
        'employee_transferred' || 'department_head_assigned' => Icons.account_tree_outlined,
        'raise_requested' || 'raise_forwarded' || 'raise_approved' || 'raise_rejected' || 'raise_returned' => Icons.trending_up,
        'report_submitted' || 'report_acknowledged' || 'report_returned' => Icons.outbox_outlined,
        'resignation_requested' || 'resignation_withdrawn' || 'resignation_approved' || 'resignation_rejected' => Icons.logout,
        'audit_log' => Icons.fact_check_outlined,
        'position_changed' => Icons.workspace_premium_outlined,
        'salary_changed' => Icons.payments_outlined,
        'bonus_granted' => Icons.card_giftcard_outlined,
        'penalty_applied' => Icons.gavel_outlined,
        _ => Icons.notifications_outlined,
      };
}

/// Ghép câu thông báo theo ngôn ngữ đang chọn từ loại và tham số server gửi.
String notificationText(AppLocalizations l10n, AppNotification n, String locale) {
  final p = n.params;
  String day(Object? value) {
    final date = DateTime.tryParse('$value');
    return date == null ? '-' : DateFormat.yMMMd(locale).format(date);
  }

  String time(Object? value) {
    final at = DateTime.tryParse('$value');
    return at == null ? '-' : DateFormat.yMMMd(locale).add_Hm().format(at.toLocal());
  }

  String number(Object? value) => value is num ? NumberFormat.decimalPattern(locale).format(value) : '$value';
  String money(Object? amount, Object? currency) {
    final value = num.tryParse('$amount');
    return '${value == null ? '$amount' : NumberFormat.decimalPattern(locale).format(value)} ${currency ?? ''}'.trim();
  }

  String report(Object? kind) => kind == 'hr' ? l10n.reportKindHr : kind == 'finance' ? l10n.reportKindFinance : '$kind';
  return switch (n.kind) {
    'leave_requested' => l10n.nLeaveRequested('${p['employeeId']}', number(p['days']), day(p['fromDate'])),
    'leave_approved' => l10n.nLeaveApproved(day(p['fromDate'])),
    'leave_rejected' => l10n.nLeaveRejected(day(p['fromDate'])),
    'overtime_requested' => l10n.nOvertimeRequested('${p['employeeId']}', number(p['hours']), day(p['workDate'])),
    'overtime_approved' => l10n.nOvertimeApproved(day(p['workDate'])),
    'overtime_rejected' => l10n.nOvertimeRejected(day(p['workDate'])),
    'candidate_applied' => l10n.nCandidateApplied('${p['appliedPosition'] ?? '-'}'),
    'candidate_status' => l10n.nCandidateStatus(stageName(l10n, '${p['status']}')),
    'interview_scheduled' => l10n.nInterviewScheduled('${p['appliedPosition'] ?? '-'}', time(p['scheduledAt'])),
    'interview_confirmed' => l10n.nInterviewConfirmed(time(p['scheduledAt'])),
    'interview_confirmed_hr' => l10n.nInterviewConfirmedHr('${p['appliedPosition'] ?? '-'}', time(p['scheduledAt'])),
    'interview_proposed' => l10n.nInterviewProposed('${p['appliedPosition'] ?? '-'}', time(p['scheduledAt'])),
    'payroll_paid' => l10n.nPayrollPaid('${p['period']}'),
    'payroll_failed' => l10n.nPayrollFailed('${p['period'] ?? '-'}'),
    'payslip_issued' => l10n.nPayslipIssued('${p['period']}'),
    'payroll_needs_attention' => l10n.nPayrollNeedsAttention('${p['period'] ?? '-'}'),
    'finance_closed' => l10n.nFinanceClosed('${p['period']}'),
    'audit_log' => l10n.nAuditLog(eventName(l10n, '${p['event']}'), p['by'] == null ? '' : l10n.nAuditLogBy('${p['by']}')),
    'position_changed' => l10n.nPositionChanged('${p['position'] ?? '-'}'),
    'salary_changed' => l10n.nSalaryChanged(money(p['amount'], p['currency'])),
    'bonus_granted' => l10n.nBonusGranted(money(p['amount'], p['currency']), '${p['reason'] ?? '-'}'),
    'penalty_applied' => l10n.nPenaltyApplied(money(p['amount'], p['currency']), '${p['reason'] ?? '-'}'),
    'project_accepted' => l10n.nProjectAccepted('${p['projectId']}'),
    'project_proposed' => l10n.nProjectProposed('${p['name'] ?? '-'}'),
    'project_countered' => l10n.nProjectCountered('${p['name'] ?? '-'}'),
    'project_approved' => l10n.nProjectApproved('${p['name'] ?? '-'}'),
    'project_rejected' => l10n.nProjectRejected('${p['name'] ?? '-'}'),
    'profile_change_requested' => l10n.nProfileChangeRequested('${p['employeeId']}'),
    'profile_change_approved' => l10n.nProfileChangeApproved,
    'profile_change_rejected' => l10n.nProfileChangeRejected('${p['note'] ?? '-'}'),
    'promotion_nominated' => l10n.nPromotionNominated('${p['employeeId']}', '${p['proposedPosition'] ?? '-'}'),
    'promotion_approved' => l10n.nPromotionApproved('${p['proposedPosition'] ?? '-'}'),
    'promotion_rejected' => l10n.nPromotionRejected('${p['proposedPosition'] ?? '-'}'),
    'promotion_approved_hr' => l10n.nPromotionApprovedHr('${p['employeeId']}'),
    'promotion_rejected_hr' => l10n.nPromotionRejectedHr('${p['employeeId']}'),
    'employee_transferred' => l10n.nEmployeeTransferred,
    'department_head_assigned' => l10n.nDepartmentHeadAssigned,
    'raise_requested' => l10n.nRaiseRequested('${p['employeeId'] ?? '-'}'),
    'raise_forwarded' => l10n.nRaiseForwarded('${p['employeeId'] ?? '-'}'),
    'raise_approved' => l10n.nRaiseApproved,
    'raise_rejected' => l10n.nRaiseRejected,
    'raise_returned' => l10n.nRaiseReturned,
    'report_submitted' => l10n.nReportSubmitted(report(p['reportKind']), '${p['period'] ?? '-'}'),
    'report_acknowledged' => l10n.nReportAcknowledged(report(p['reportKind']), '${p['period'] ?? '-'}'),
    'report_returned' => l10n.nReportReturned(report(p['reportKind']), '${p['period'] ?? '-'}'),
    'resignation_requested' => l10n.nResignationRequested('${p['employeeId'] ?? '-'}', day(p['lastDay'])),
    'resignation_approved' => l10n.nResignationApproved(day(p['lastDay'])),
    'resignation_rejected' => l10n.nResignationRejected,
    'resignation_withdrawn' => l10n.nResignationWithdrawn('${p['employeeId'] ?? '-'}'),
    _ => l10n.nGeneric,
  };
}

/// Chuông ở thanh trên màn chính, kèm số thông báo chưa đọc.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(inboxProvider).value?.unread ?? 0;
    return IconButton(
      tooltip: AppLocalizations.of(context).notifications,
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
      onPressed: () => context.push(Routes.notifications),
    );
  }
}
