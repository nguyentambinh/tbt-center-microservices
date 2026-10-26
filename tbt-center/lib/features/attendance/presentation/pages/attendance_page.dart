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

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../notification/presentation/notification_target.dart' show RequesterHeader;
import '../../domain/entities/attendance.dart';
import '../../domain/entities/work_time.dart';
import '../providers/attendance_providers.dart';
import '../widgets/clock_card.dart';
import '../widgets/leave_evidence.dart';
import '../widgets/leave_form.dart';
import '../widgets/overtime_widgets.dart';

abstract final class LeaveStatusLabel {
  static String of(AppLocalizations l10n, String status) => switch (status) {
        'approved' => l10n.statusApproved,
        'rejected' => l10n.statusRejected,
        _ => l10n.statusPending,
      };
}

class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key, this.openApprovals = false});

  final bool openApprovals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final roles = ref.watch(authControllerProvider).value?.roles ?? const [];
    final canApprove = roles.any(leaveApproverRoles.contains);

    return DefaultTabController(
      length: canApprove ? 4 : 3,
      initialIndex: canApprove && openApprovals ? 3 : 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.attendance),
          actions: [
            IconButton(tooltip: l10n.workCalendar, icon: const Icon(Icons.calendar_month), onPressed: () => context.push(Routes.workCalendar)),
            IconButton(tooltip: l10n.clockStats, icon: const Icon(Icons.bar_chart), onPressed: () => context.push(Routes.clockStats)),
          ],
          bottom: TabBar(isScrollable: canApprove, tabAlignment: canApprove ? TabAlignment.start : null, tabs: [
            Tab(text: l10n.tabTimesheet),
            Tab(text: l10n.tabLeave),
            Tab(text: l10n.tabOvertime),
            if (canApprove) Tab(text: l10n.tabApprovals),
          ]),
        ),
        body: TabBarView(children: [
          const _TimesheetTab(),
          const _MyLeavesTab(),
          const MyOvertimeTab(),
          if (canApprove) const _ApprovalsTab(),
        ]),
      ),
    );
  }
}

class _TimesheetTab extends ConsumerStatefulWidget {
  const _TimesheetTab();

  @override
  ConsumerState<_TimesheetTab> createState() => _TimesheetTabState();
}

class _TimesheetTabState extends ConsumerState<_TimesheetTab> {
  late DateTime _month = DateTime(ref.read(regionTodayProvider).year, ref.read(regionTodayProvider).month);

  void _shift(int months) => setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final sheet = ref.watch(timesheetProvider(_month));
    final hours = NumberFormat.decimalPattern(locale);

    return Column(
      children: [
        const ClockCard(),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _shift(-1)),
            Expanded(
              child: Text(
                toBeginningOfSentenceCase(DateFormat.yMMMM(locale).format(_month), locale),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _shift(1)),
          ],
        ),
        Expanded(
          child: switch (sheet) {
            AsyncValue(:final value?) when value.days.isEmpty => EmptyView(message: l10n.noTimesheets),
            AsyncValue(:final value?) => ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      l10n.totalHours(hours.format(value.totalHours), value.days.length),
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  for (final day in value.days)
                    ListTile(
                      title: Text(DateFormat.MMMEd(locale).format(day.date)),
                      subtitle: Text(l10n.checkInOut(day.checkIn ?? '--:--', day.checkOut ?? '--:--')),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${hours.format(day.totalHours)} h'),
                          if (day.overtimeHours > 0)
                            Text(
                              l10n.overtimeHours(hours.format(day.overtimeHours)),
                              style: TextStyle(color: context.tbt.brandGold, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(timesheetProvider(_month))),
            _ => const SkeletonList(),
          },
        ),
      ],
    );
  }
}

class _MyLeavesTab extends ConsumerWidget {
  const _MyLeavesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final leaves = ref.watch(myLeavesProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.newLeave),
        onPressed: () => showLeaveForm(context),
      ),
      body: switch (leaves) {
        AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noLeaves, icon: Icons.beach_access),
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(myLeavesProvider.future),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final leave in value)
                  LeaveTile(
                    leave: leave,
                    mine: true,
                    onTap: () => showRequestDetail(context, employeeId: leave.employeeId, child: LeaveTile(leave: leave, mine: true)),
                  ),
              ],
            ),
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(myLeavesProvider)),
        _ => const SkeletonList(),
      },
    );
  }
}

class _ApprovalsTab extends ConsumerWidget {
  const _ApprovalsTab();

  Future<void> _decide(BuildContext context, WidgetRef ref, Future<void> Function() send) async {
    try {
      await send();
      ref
        ..invalidate(pendingLeavesProvider)
        ..invalidate(myLeavesProvider)
        ..invalidate(pendingOvertimeProvider)
        ..invalidate(myOvertimeProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).leaveDecided), behavior: SnackBarBehavior.floating),
        );
      }
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final leaves = ref.watch(pendingLeavesProvider);
    final overtime = ref.watch(pendingOvertimeProvider);
    final attendance = ref.read(attendanceRepositoryProvider);
    final workTime = ref.read(workTimeRepositoryProvider);
    final me = ref.watch(authControllerProvider).value?.employeeId;

    if (leaves.error ?? overtime.error case final error?) {
      return ErrorView(
        error: error,
        onRetry: () => ref
          ..invalidate(pendingLeavesProvider)
          ..invalidate(pendingOvertimeProvider),
      );
    }
    final (pendingLeaves, pendingOvertime) = (leaves.value, overtime.value);
    if (pendingLeaves == null || pendingOvertime == null) return const SkeletonList();
    if (pendingLeaves.isEmpty && pendingOvertime.isEmpty) {
      return EmptyView(message: l10n.noPending, icon: Icons.task_alt);
    }

    List<Widget> leaveActions(LeaveRequest leave) => leave.employeeId == me
        ? [Text(l10n.waitingSuperior, style: TextStyle(color: context.tbt.textSecondary))]
        : [
            TextButton(onPressed: () => _decide(context, ref, () => attendance.decide(leave.id, approve: false)), child: Text(l10n.reject)),
            FilledButton(onPressed: () => _decide(context, ref, () => attendance.decide(leave.id, approve: true)), child: Text(l10n.approve)),
          ];
    List<Widget> overtimeActions(OvertimeRequest request) => request.employeeId == me
        ? [Text(l10n.waitingSuperior, style: TextStyle(color: context.tbt.textSecondary))]
        : [
            TextButton(onPressed: () => _decide(context, ref, () => workTime.decideOvertime(request.id, approve: false)), child: Text(l10n.reject)),
            FilledButton(onPressed: () => _decide(context, ref, () => workTime.decideOvertime(request.id, approve: true)), child: Text(l10n.approve)),
          ];
    Widget leaveTile(LeaveRequest leave) => LeaveTile(
          leave: leave,
          showEmployee: true,
          mine: leave.employeeId == me,
          actions: leaveActions(leave),
          onTap: () => showRequestDetail(context, employeeId: leave.employeeId, child: LeaveTile(leave: leave, mine: leave.employeeId == me, actions: leaveActions(leave))),
        );
    Widget overtimeTile(OvertimeRequest request) => OvertimeTile(
          request: request,
          showEmployee: true,
          mine: request.employeeId == me,
          actions: overtimeActions(request),
          onTap: () => showRequestDetail(context, employeeId: request.employeeId, child: OvertimeTile(request: request, mine: request.employeeId == me, actions: overtimeActions(request))),
        );
    // Đơn của nhân viên cần mình duyệt lên trước, đơn của chính mình (chờ cấp trên) để riêng
    final otherLeaves = [for (final l in pendingLeaves) if (l.employeeId != me) l];
    final otherOvertime = [for (final o in pendingOvertime) if (o.employeeId != me) o];
    final myLeaves = [for (final l in pendingLeaves) if (l.employeeId == me) l];
    final myOvertime = [for (final o in pendingOvertime) if (o.employeeId == me) o];
    Widget heading(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        );

    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(pendingLeavesProvider)
          ..invalidate(pendingOvertimeProvider);
      },
      child: ListView(
        children: [
          heading(l10n.approvalsOthers(otherLeaves.length + otherOvertime.length)),
          for (final leave in otherLeaves) leaveTile(leave),
          for (final request in otherOvertime) overtimeTile(request),
          if (myLeaves.isNotEmpty || myOvertime.isNotEmpty) ...[
            heading(l10n.approvalsMine(myLeaves.length + myOvertime.length)),
            for (final leave in myLeaves) leaveTile(leave),
            for (final request in myOvertime) overtimeTile(request),
          ],
        ],
      ),
    );
  }
}

class LeaveTile extends StatelessWidget {
  const LeaveTile({super.key, required this.leave, this.showEmployee = false, this.actions = const [], this.mine = false, this.onTap});

  final LeaveRequest leave;
  final bool showEmployee;
  final List<Widget> actions;

  /// Bấm vào thẻ để xem chi tiết đơn
  final VoidCallback? onTap;

  /// Đơn của chính mình: còn chờ duyệt thì thêm được minh chứng
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final format = DateFormat.yMMMd(locale);
    final (label, color) = switch (leave.status) {
      LeaveStatus.pending => (l10n.statusPending, context.tbt.brandGold),
      LeaveStatus.approved => (l10n.statusApproved, context.tbt.success),
      LeaveStatus.rejected => (l10n.statusRejected, context.tbt.danger),
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(leave.leaveType, style: Theme.of(context).textTheme.titleMedium)),
                if (mine && showEmployee) ...[MineTag(), const SizedBox(width: 6)],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.7)),
                  ),
                  child: Text(label, style: TextStyle(color: color, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${format.format(leave.fromDate)} – ${format.format(leave.toDate)}  ·  ${l10n.leaveDays(leave.days)}',
              style: TextStyle(color: context.tbt.textSecondary),
            ),
            if (showEmployee) Text(leave.employeeId, style: TextStyle(color: context.tbt.textSecondary)),
            if (leave.reason case final reason? when reason.isNotEmpty) Text(reason),
            LeaveEvidence(leave: leave, canUpload: mine && leave.status == LeaveStatus.pending, showSummary: !mine),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [...actions.expand((a) => [a, const SizedBox(width: 8)])]),
            ],
          ],
        ),
      ),
      ),
    );
  }
}

/// Nhãn "Đơn của bạn" trong danh sách duyệt
class MineTag extends StatelessWidget {
  const MineTag({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: context.tbt.info.withValues(alpha: 0.18)),
        child: Text(AppLocalizations.of(context).requestMineTag, style: TextStyle(color: context.tbt.info, fontSize: 11, fontWeight: FontWeight.bold)),
      );
}

/// Bảng chi tiết một đơn: người gửi (ảnh, chức vụ, phòng ban), nội dung, minh chứng, nút duyệt nếu có
Future<void> showRequestDetail(BuildContext context, {required String employeeId, required Widget child}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [RequesterHeader(employeeId: employeeId), child]),
          ),
        ),
      ),
    );
