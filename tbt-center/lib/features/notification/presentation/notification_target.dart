/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/error/error_reporter.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/remote_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../attendance/presentation/pages/attendance_page.dart';
import '../../attendance/presentation/providers/attendance_providers.dart';
import '../../attendance/presentation/widgets/overtime_widgets.dart';
import '../../hr/presentation/providers/employee_providers.dart';
import '../../payroll/presentation/pages/raise_requests_page.dart';
import '../../payroll/presentation/providers/payroll_providers.dart';
import '../../profile/presentation/pages/profile_page.dart';
import '../../profile/presentation/providers/profile_providers.dart';
import '../../project_contract/presentation/pages/project_proposals_page.dart';
import '../../recruitment/presentation/pages/candidates_page.dart';
import '../../resignations/presentation/resignations_page.dart';
import '../domain/entities/app_notification.dart';
import 'providers/notification_providers.dart';

/// Màn liên quan khi không mở được dialog chi tiết
String? notificationRoute(String kind) => switch (kind) {
      'leave_requested' || 'overtime_requested' => '${Routes.attendance}?tab=approvals',
      'leave_approved' || 'leave_rejected' || 'overtime_approved' || 'overtime_rejected' => Routes.attendance,
      'candidate_applied' || 'interview_confirmed_hr' || 'interview_proposed' => Routes.candidates,
      'candidate_status' || 'interview_scheduled' || 'interview_confirmed' => Routes.myApplication,
      'payroll_paid' || 'payroll_failed' || 'payroll_needs_attention' => Routes.payrollRuns,
      'payslip_issued' => Routes.payslips,
      'finance_closed' => Routes.groupReport,
      'audit_log' => Routes.auditLog,
      'position_changed' => Routes.profile,
      'salary_changed' || 'bonus_granted' || 'penalty_applied' => Routes.payslips,
      'project_accepted' => Routes.finance,
      'project_proposed' || 'project_countered' || 'project_approved' || 'project_rejected' => Routes.projectProposals,
      'profile_change_requested' => Routes.changeRequests,
      'profile_change_approved' || 'profile_change_rejected' => Routes.profile,
      'promotion_nominated' || 'promotion_approved_hr' || 'promotion_rejected_hr' => Routes.nominations,
      'promotion_approved' || 'promotion_rejected' || 'employee_transferred' || 'department_head_assigned' => Routes.profile,
      'raise_requested' || 'raise_forwarded' || 'raise_approved' || 'raise_rejected' || 'raise_returned' => Routes.raiseRequests,
      'report_submitted' || 'report_acknowledged' || 'report_returned' => Routes.reportSubmissions,
      'resignation_requested' || 'resignation_withdrawn' || 'resignation_approved' || 'resignation_rejected' => Routes.resignations,
      _ => null,
    };

/// Bấm một thông báo: đánh dấu đã đọc, mở thẳng đơn hoặc người liên quan trong dialog chi tiết để xử lý
Future<void> openNotification(BuildContext context, WidgetRef ref, AppNotification n) async {
  if (!n.read) {
    try {
      await ref.read(notificationRepositoryProvider).markRead([n.id]);
      ref.invalidate(inboxProvider);
    } on Object {
      // Đánh dấu lỗi thì lần mở hộp thư sau vẫn còn chấm, không chặn việc mở đơn
    }
  }
  if (!context.mounted) return;
  final target = '${n.params['ref'] ?? ''}';
  final region = ref.read(authControllerProvider).value?.region ?? 'vn';
  final route = notificationRoute(n.kind);
  final Widget? detail = target.isEmpty
      ? null
      : switch (n.kind) {
          'leave_requested' => _LeaveTarget(id: target),
          'overtime_requested' => _OvertimeTarget(id: target),
          'candidate_applied' || 'interview_confirmed_hr' || 'interview_proposed' => CandidateSheet(id: target),
          'raise_requested' || 'raise_forwarded' || 'raise_approved' || 'raise_rejected' || 'raise_returned' => _RaiseTarget(id: target, region: region),
          'resignation_requested' || 'resignation_withdrawn' || 'resignation_approved' || 'resignation_rejected' => _ResignationTarget(id: target, region: region),
          'profile_change_requested' => _ChangeTarget(employeeId: target),
          'project_proposed' || 'project_countered' when int.tryParse(target) != null => ProposalSheet(region: region, id: int.parse(target)),
          _ => null,
        };
  if (detail == null) {
    if (route != null) await context.push(route);
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => detail is CandidateSheet || detail is ProposalSheet ? detail : _TargetFrame(route: route, child: detail),
  );
}

/// Khung dialog: nội dung đơn, dưới cùng có nút mở màn đầy đủ
class _TargetFrame extends StatelessWidget {
  const _TargetFrame({required this.child, this.route});

  final Widget child;
  final String? route;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              child,
              if (route case final r?)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(r);
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l10n.openFullPage),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Người gửi đơn: ảnh, họ tên, chức vụ, phòng ban (HR, quản lý mới thấy mã)
class RequesterHeader extends ConsumerWidget {
  const RequesterHeader({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final familyFirst = ref.watch(authControllerProvider).value?.region == 'vn';
    final detail = ref.watch(employeeDetailProvider(employeeId));
    final s = detail.value?.summary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: SizedBox.square(dimension: 48, child: RemotePhoto(url: s?.photoUrl, aspectRatio: 1, radius: 24, icon: Icons.person)),
      title: Text(s == null ? employeeId : s.fullName(familyFirst: familyFirst), style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        [l10n.requestFrom, ?s?.position, ?s?.department, employeeId].join(' · '),
        style: TextStyle(color: context.tbt.textSecondary),
      ),
    );
  }
}

class _Handled extends StatelessWidget {
  const _Handled();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text(AppLocalizations.of(context).requestAlreadyHandled, textAlign: TextAlign.center, style: TextStyle(color: context.tbt.textSecondary)),
      );
}

Future<void> _run(BuildContext context, WidgetRef ref, Future<Object?> Function() action, String done) async {
  try {
    await action();
    ref
      ..invalidate(pendingLeavesProvider)
      ..invalidate(pendingOvertimeProvider);
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done), behavior: SnackBarBehavior.floating));
  } on Object catch (e) {
    reportFailure(e);
  }
}

class _LeaveTarget extends ConsumerWidget {
  const _LeaveTarget({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return switch (ref.watch(pendingLeavesProvider)) {
      AsyncValue(:final value?) => switch (value.where((l) => l.id == id).firstOrNull) {
          final leave? => Column(children: [
              RequesterHeader(employeeId: leave.employeeId),
              LeaveTile(leave: leave, actions: [
                TextButton(onPressed: () => _run(context, ref, () => ref.read(attendanceRepositoryProvider).decide(leave.id, approve: false), l10n.leaveDecided), child: Text(l10n.reject)),
                FilledButton(onPressed: () => _run(context, ref, () => ref.read(attendanceRepositoryProvider).decide(leave.id, approve: true), l10n.leaveDecided), child: Text(l10n.approve)),
              ]),
            ]),
          null => const _Handled(),
        },
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(pendingLeavesProvider)),
      _ => const SizedBox(height: 160, child: SkeletonList()),
    };
  }
}

class _OvertimeTarget extends ConsumerWidget {
  const _OvertimeTarget({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return switch (ref.watch(pendingOvertimeProvider)) {
      AsyncValue(:final value?) => switch (value.where((o) => o.id == id).firstOrNull) {
          final request? => Column(children: [
              RequesterHeader(employeeId: request.employeeId),
              OvertimeTile(request: request, actions: [
                TextButton(onPressed: () => _run(context, ref, () => ref.read(workTimeRepositoryProvider).decideOvertime(request.id, approve: false), l10n.leaveDecided), child: Text(l10n.reject)),
                FilledButton(onPressed: () => _run(context, ref, () => ref.read(workTimeRepositoryProvider).decideOvertime(request.id, approve: true), l10n.leaveDecided), child: Text(l10n.approve)),
              ]),
            ]),
          null => const _Handled(),
        },
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(pendingOvertimeProvider)),
      _ => const SizedBox(height: 160, child: SkeletonList()),
    };
  }
}

class _RaiseTarget extends ConsumerWidget {
  const _RaiseTarget({required this.id, required this.region});

  final String id;
  final String region;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = (region: region, status: null);
    final roles = ref.watch(authControllerProvider).value?.roles.toSet() ?? const <String>{};
    return switch (ref.watch(raiseRequestsProvider(query))) {
      AsyncValue(:final value?) => switch (value.where((r) => '${r.id}' == id).firstOrNull) {
          final request? => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                if (roles.any({'hr', 'admin', 'executive'}.contains)) RequesterHeader(employeeId: request.employeeId),
                RaiseCard(
                  request: request,
                  region: region,
                  roles: roles,
                  showEmployee: false,
                  onRun: (action, done) async {
                    try {
                      await action();
                      ref.invalidate(raiseRequestsProvider);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done), behavior: SnackBarBehavior.floating));
                      }
                    } on Object catch (e) {
                      reportFailure(e);
                    }
                  },
                ),
              ]),
            ),
          null => const _Handled(),
        },
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(raiseRequestsProvider(query))),
      _ => const SizedBox(height: 160, child: SkeletonList()),
    };
  }
}

class _ResignationTarget extends ConsumerWidget {
  const _ResignationTarget({required this.id, required this.region});

  final String id;
  final String region;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.watch(authControllerProvider).value?.roles.any(resignationHandlerRoles.contains) ?? false;
    return switch (ref.watch(resignationsProvider(region))) {
      AsyncValue(:final value?) => switch (value.where((r) => '${r.id}' == id).firstOrNull) {
          final resignation? => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                if (handler) RequesterHeader(employeeId: resignation.employeeId),
                ResignationCard(
                  resignation: resignation,
                  region: region,
                  handler: handler,
                  onRun: (action, done) async {
                    try {
                      await action();
                      ref.invalidate(resignationsProvider(region));
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done), behavior: SnackBarBehavior.floating));
                      }
                    } on Object catch (e) {
                      reportFailure(e);
                    }
                  },
                ),
              ]),
            ),
          null => const _Handled(),
        },
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(resignationsProvider(region))),
      _ => const SizedBox(height: 160, child: SkeletonList()),
    };
  }
}

class _ChangeTarget extends ConsumerWidget {
  const _ChangeTarget({required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return switch (ref.watch(changeRequestsProvider('pending'))) {
      AsyncValue(:final value?) => switch (value.where((r) => r.employeeId == employeeId).firstOrNull) {
          final request? => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                RequesterHeader(employeeId: employeeId),
                ChangeRequestTile(
                  request: request,
                  locale: locale,
                  actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                      onPressed: () => _decideChange(context, ref, request.id, approve: false),
                      child: Text(l10n.reject),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _decideChange(context, ref, request.id, approve: true),
                      child: Text(l10n.approve),
                    ),
                  ]),
                ),
              ]),
            ),
          null => const _Handled(),
        },
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(changeRequestsProvider('pending'))),
      _ => const SizedBox(height: 160, child: SkeletonList()),
    };
  }

  Future<void> _decideChange(BuildContext context, WidgetRef ref, int id, {required bool approve}) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(profileRepositoryProvider).decide(id, approve: approve);
      ref.invalidate(changeRequestsProvider);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.statusChanged), behavior: SnackBarBehavior.floating));
      }
    } on Object catch (e) {
      reportFailure(e);
    }
  }
}
