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
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recruitment/presentation/widgets/stage_widgets.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notification_providers.dart';

/// Hộp thông báo (R18, R97): đơn nghỉ, tăng ca, phát lương, hồ sơ ứng tuyển.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  Future<void> _markAllRead(WidgetRef ref) async {
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
      ref.invalidate(inboxProvider);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final inbox = ref.watch(inboxProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          if (inbox.value case Inbox(unread: > 0))
            TextButton(onPressed: () => _markAllRead(ref), child: Text(l10n.markAllRead)),
        ],
      ),
      body: switch (inbox) {
        AsyncValue(:final value?) when value.items.isEmpty =>
          EmptyView(message: l10n.noNotifications, icon: Icons.notifications_none),
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(inboxProvider.future),
            child: ListView(
              children: [for (final n in value.items) _NotificationTile(notification: n)],
            ),
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(inboxProvider)),
        _ => const SkeletonList(),
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final accent = Theme.of(context).colorScheme.primary;
    final route = _routeFor(notification.kind);
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
      onTap: route == null ? null : () => context.push(route),
    );
  }

  static IconData _iconFor(String kind) => switch (kind) {
        'leave_requested' || 'leave_approved' || 'leave_rejected' => Icons.beach_access_outlined,
        'overtime_requested' || 'overtime_approved' || 'overtime_rejected' => Icons.more_time,
        'candidate_applied' || 'candidate_status' => Icons.work_outline,
        'payroll_paid' || 'payroll_failed' || 'payslip_issued' => Icons.payments_outlined,
        'payroll_needs_attention' => Icons.warning_amber_outlined,
        'finance_closed' => Icons.lock_outline,
        'project_accepted' => Icons.task_alt,
        _ => Icons.notifications_outlined,
      };

  /// Bấm vào thông báo thì mở màn liên quan.
  static String? _routeFor(String kind) => switch (kind) {
        'leave_requested' || 'leave_approved' || 'leave_rejected' => Routes.attendance,
        'overtime_requested' || 'overtime_approved' || 'overtime_rejected' => Routes.attendance,
        'candidate_applied' => Routes.candidates,
        'candidate_status' => Routes.myApplication,
        'payroll_paid' || 'payroll_failed' || 'payroll_needs_attention' => Routes.payrollRuns,
        'payslip_issued' => Routes.payslips,
        'finance_closed' => Routes.groupReport,
        'project_accepted' => Routes.finance,
        _ => null,
      };
}

/// Ghép câu thông báo theo ngôn ngữ đang chọn từ loại và tham số server gửi.
String notificationText(AppLocalizations l10n, AppNotification n, String locale) {
  final p = n.params;
  String day(Object? value) {
    final date = DateTime.tryParse('$value');
    return date == null ? '-' : DateFormat.yMMMd(locale).format(date);
  }

  String number(Object? value) => value is num ? NumberFormat.decimalPattern(locale).format(value) : '$value';
  return switch (n.kind) {
    'leave_requested' => l10n.nLeaveRequested('${p['employeeId']}', number(p['days']), day(p['fromDate'])),
    'leave_approved' => l10n.nLeaveApproved(day(p['fromDate'])),
    'leave_rejected' => l10n.nLeaveRejected(day(p['fromDate'])),
    'overtime_requested' => l10n.nOvertimeRequested('${p['employeeId']}', number(p['hours']), day(p['workDate'])),
    'overtime_approved' => l10n.nOvertimeApproved(day(p['workDate'])),
    'overtime_rejected' => l10n.nOvertimeRejected(day(p['workDate'])),
    'candidate_applied' => l10n.nCandidateApplied('${p['appliedPosition'] ?? '-'}'),
    'candidate_status' => l10n.nCandidateStatus(stageName(l10n, '${p['status']}')),
    'payroll_paid' => l10n.nPayrollPaid('${p['period']}'),
    'payroll_failed' => l10n.nPayrollFailed('${p['period'] ?? '-'}'),
    'payslip_issued' => l10n.nPayslipIssued('${p['period']}'),
    'payroll_needs_attention' => l10n.nPayrollNeedsAttention('${p['period'] ?? '-'}'),
    'finance_closed' => l10n.nFinanceClosed('${p['period']}'),
    'project_accepted' => l10n.nProjectAccepted('${p['projectId']}'),
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
