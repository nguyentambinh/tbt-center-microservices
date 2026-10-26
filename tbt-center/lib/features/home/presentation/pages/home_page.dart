/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/session.dart';
import '../../../../core/auth/work_region.dart';
import '../../../../core/config/env.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/locale/l10n_names.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gem_heading.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../core/widgets/tbt_logo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../audit/presentation/providers/audit_providers.dart';
import '../../../notification/presentation/providers/notification_providers.dart';
import '../../../project_contract/presentation/providers/project_providers.dart';
import '../../../organization/presentation/providers/organization_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../recruitment/presentation/providers/candidate_providers.dart';

typedef _Feature = ({IconData icon, String title, String hint, String route});

const managerRoles = {'hr', 'admin', 'executive', 'finance'};

/// Màn chính: chức năng theo role
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  List<(String, List<_Feature>)> _sections(
    AppLocalizations l10n,
    Session session,
  ) {
    final roles = session.roles;
    bool any(Set<String> set) => roles.any(set.contains);
    final executive = roles.contains('executive');
    final admin = roles.contains('admin');
    final hr = roles.contains('hr');
    final finance = roles.contains('finance');
    final sections = [
      // Văn phòng quản lý, quản trị không có việc cá nhân: chỉ người có hồ sơ nhân viên
      (
        l10n.sectionMyWork,
        [
          if (session.isEmployee) ...[
            (icon: Icons.event_available_outlined, title: l10n.attendance, hint: l10n.attendanceHint, route: Routes.attendance),
            (icon: Icons.payments_outlined, title: l10n.payslips, hint: l10n.payslipsHint, route: Routes.payslips),
            (icon: Icons.engineering_outlined, title: l10n.myProjects, hint: l10n.myProjectsHint, route: Routes.myProjects),
            (icon: Icons.trending_up, title: l10n.raiseRequests, hint: l10n.raiseRequestsHint, route: Routes.raiseRequests),
            (icon: Icons.logout, title: l10n.resignations, hint: l10n.resignationsHint, route: Routes.resignations),
          ],
          if (roles.contains('candidate'))
            (icon: Icons.work_outline, title: l10n.myApplication, hint: l10n.myApplicationHint, route: Routes.myApplication),
        ],
      ),
      (
        l10n.sectionGroup,
        [
          if (session.isGroup && !admin)
            (icon: Icons.public, title: l10n.groupOverview, hint: l10n.groupOverviewHint, route: Routes.groupOverview),
        ],
      ),
      (
        l10n.sectionManage,
        [
          // Văn phòng quản lý: duyệt và làm thẳng, không có chức năng đề xuất
          if (executive) ...[
            (icon: Icons.inbox_outlined, title: l10n.approvalInbox, hint: l10n.approvalInboxHint, route: Routes.approvals),
            (icon: Icons.trending_up, title: l10n.raiseRequests, hint: l10n.raiseRequestsHint, route: Routes.raiseRequests),
            (icon: Icons.workspace_premium_outlined, title: l10n.nominations, hint: l10n.nominationsHint, route: Routes.nominations),
            (icon: Icons.logout, title: l10n.resignations, hint: l10n.resignationsHint, route: Routes.resignations),
          ],
          if (executive || hr || finance) ...[
            (icon: Icons.badge_outlined, title: l10n.employees, hint: l10n.employeesHint, route: Routes.employees),
            (icon: Icons.apartment_outlined, title: l10n.projects, hint: l10n.projectsHint, route: Routes.projects),
          ],
          if (hr) ...[
            (icon: Icons.groups_outlined, title: l10n.candidates, hint: l10n.candidatesHint, route: Routes.candidates),
            (icon: Icons.work_outline, title: l10n.jobPositions, hint: l10n.jobPositionsHint, route: Routes.jobPositions),
          ],
          if (executive || hr) ...[
            (icon: Icons.account_tree_outlined, title: l10n.departments, hint: l10n.departmentsHint, route: Routes.departments),
            (icon: Icons.emoji_events_outlined, title: l10n.rankings, hint: l10n.rankingsHint, route: Routes.rankings),
          ],
          if (hr) (icon: Icons.workspace_premium_outlined, title: l10n.nominations, hint: l10n.nominationsHint, route: Routes.nominations),
          if (executive || hr || finance)
            (icon: Icons.outbox_outlined, title: l10n.reportSubmissions, hint: l10n.reportSubmissionsHint, route: Routes.reportSubmissions),
        ],
      ),
      (
        l10n.sectionFinance,
        [
          if (executive || finance) (icon: Icons.account_balance_wallet_outlined, title: l10n.finance, hint: l10n.financeHint, route: Routes.finance),
          if (session.isGroup && (executive || finance))
            (icon: Icons.insights_outlined, title: l10n.groupReport, hint: l10n.groupReportHint, route: Routes.groupReport),
          if (finance) (icon: Icons.account_balance_outlined, title: l10n.payrollRuns, hint: l10n.payrollRunsHint, route: Routes.payrollRuns),
        ],
      ),
      (
        l10n.sectionAdmin,
        [
          if (admin) (icon: Icons.admin_panel_settings_outlined, title: l10n.adminConsole, hint: l10n.adminConsoleHint, route: Routes.adminConsole),
        ],
      ),
      (
        l10n.sectionKnowledge,
        [
          if (session.isEmployee || executive)
            (icon: Icons.menu_book_outlined, title: l10n.knowledge, hint: l10n.knowledgeHint, route: Routes.knowledge),
        ],
      ),
      (
        l10n.sectionAudit,
        [
          if (any(auditReaderRoles)) (icon: Icons.fact_check_outlined, title: l10n.auditLog, hint: l10n.auditLogHint, route: Routes.auditLog),
        ],
      ),
    ];
    // Vai trò quản lý: Tập đoàn, Quản lý, Tài chính, Quản trị lên trước việc cá nhân
    final ordered = any(managerRoles) ? [sections[1], sections[2], sections[3], sections[4], sections[0], ...sections.skip(5)] : sections;
    return [
      for (final s in ordered)
        if (s.$2.isNotEmpty) s,
    ];
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.signOut)),
        ],
      ),
    );
    if (ok == true) await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value;
    if (session == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final gem = session.gem;
    var index = 0;

    return Scaffold(
      bottomNavigationBar: const TbtBottomNav(current: Routes.home),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 128,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton.outlined(
                  tooltip: l10n.signOut,
                  onPressed: () => _confirmSignOut(context, ref),
                  style: IconButton.styleFrom(side: BorderSide(color: context.tbt.glassBorder)),
                  icon: const Icon(Icons.logout, size: 20),
                ),
              ),
            ],
            // Logo lớn cuộn chậm hơn nội dung (parallax), thu gọn thì hiện logo nhỏ
            flexibleSpace: LayoutBuilder(
              builder: (context, box) {
                final top = MediaQuery.paddingOf(context).top;
                final expanded = ((box.maxHeight - top - kToolbarHeight) / (128 - kToolbarHeight)).clamp(0.0, 1.0);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Padding(
                        padding: EdgeInsets.only(top: top + 8),
                        child: Center(child: Opacity(opacity: expanded, child: TbtLogo(gem: gem, height: 64))),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: top + 12,
                      child: Opacity(
                        opacity: 1 - expanded,
                        child: TbtLogo(gem: gem, height: 32, showTagline: false),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            // Danh sách ngắn nên dựng hết một lần
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideIn(
                    child: GemHeading(
                      l10n.welcome(session.displayName),
                      gem: gem,
                      style: text.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [for (final role in session.roles) l10n.roleName(role), if (session.isGroup) l10n.roleGroup else l10n.regionName(session.region)].join(' · '),
                    style: text.bodyMedium?.copyWith(color: context.tbt.textSecondary),
                  ),
                  if (session.isGroup) ...[
                    const SizedBox(height: 10),
                    const RegionPicker(),
                  ],
                  const SizedBox(height: 20),
                  if (session.roles.any({'hr', 'executive'}.contains)) ...[
                    const _TodoPanel(),
                    const SizedBox(height: 20),
                  ],
                  for (final (title, features) in _sections(l10n, session)) ...[
                    SectionLabel(title),
                    FadeSlideIn(
                      index: ++index,
                      child: Card(
                        child: Column(
                          children: [
                            for (final (i, feature) in features.indexed) ...[
                              if (i > 0) const Divider(height: 1, indent: 76),
                              _FeatureTile(feature: feature),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tài khoản tập đoàn chọn nước đang xem; mọi màn nghiệp vụ gọi về khu vực này
class RegionPicker extends ConsumerWidget {
  const RegionPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final region = ref.watch(workRegionProvider);
    return Align(
      alignment: Alignment.centerLeft,
      child: MenuAnchor(
        menuChildren: [
          for (final r in Env.regions)
            MenuItemButton(
              leadingIcon: Icon(r == region ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 18),
              onPressed: () => ref.read(workRegionProvider.notifier).select(r),
              child: Text(l10n.regionName(r)),
            ),
        ],
        builder: (context, menu, _) => ActionChip(
          avatar: const Icon(Icons.public, size: 18),
          tooltip: l10n.chooseRegion,
          label: Text(l10n.viewingRegion(l10n.regionName(region))),
          onPressed: () => menu.isOpen ? menu.close() : menu.open(),
        ),
      ),
    );
  }
}

/// Việc đang chờ HR, quản lý: đơn chờ duyệt, hồ sơ ứng viên mới
class _TodoPanel extends ConsumerWidget {
  const _TodoPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final leaves = ref.watch(pendingLeavesProvider);
    final overtime = ref.watch(pendingOvertimeProvider);
    final candidates = ref.watch(candidateListProvider(null));
    final profileChanges = ref.watch(changeRequestsProvider('pending'));
    final executive = ref.watch(authControllerProvider).value?.roles.contains('executive') ?? false;
    final nominations = executive ? ref.watch(pendingNominationsProvider).value ?? 0 : 0;
    final proposals = executive ? ref.watch(pendingProposalsProvider).value ?? 0 : 0;
    final loading = leaves.isLoading || overtime.isLoading || candidates.isLoading;
    final newCandidates =
        candidates.value?.where((c) => c.status == 'submitted' || c.status == 'analyzed').length ?? 0;
    const approvals = '${Routes.attendance}?tab=approvals';
    final rows = [
      (count: leaves.value?.length ?? 0, label: l10n.todoLeaves, icon: Icons.event_busy_outlined, route: approvals),
      (count: overtime.value?.length ?? 0, label: l10n.todoOvertime, icon: Icons.more_time_outlined, route: approvals),
      (count: newCandidates, label: l10n.todoCandidates, icon: Icons.person_search_outlined, route: Routes.candidates),
      (count: profileChanges.value?.length ?? 0, label: l10n.todoProfileChanges, icon: Icons.manage_accounts_outlined, route: Routes.changeRequests),
      (count: nominations, label: l10n.todoNominations, icon: Icons.workspace_premium_outlined, route: Routes.nominations),
      (count: proposals, label: l10n.todoProposals, icon: Icons.fact_check_outlined, route: Routes.projectProposals),
    ].where((row) => row.count > 0).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.todoTitle, style: text.titleLarge)),
                  if (loading)
                    const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            if (rows.isEmpty && !loading)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Text(l10n.todoNone, style: text.bodyMedium?.copyWith(color: context.tbt.textSecondary)),
              ),
            for (final row in rows)
              ListTile(
                leading: Icon(row.icon),
                title: Text(row.label(row.count)),
                trailing: Icon(Icons.chevron_right, color: context.tbt.textSecondary),
                onTap: () => context.push(row.route),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.16), shape: BoxShape.circle),
        child: Icon(feature.icon, color: color, size: 22),
      ),
      title: Text(feature.title),
      subtitle: Text(feature.hint, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Icon(Icons.chevron_right, color: context.tbt.textSecondary),
      onTap: () => context.push(feature.route),
    );
  }
}

/// Thanh điều hướng dưới kiểu kính mờ
class TbtBottomNav extends ConsumerWidget {
  const TbtBottomNav({super.key, required this.current});

  final String current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final unread = ref.watch(inboxProvider).value?.unread ?? 0;
    final items = [
      (
        icon: Icons.home_rounded,
        label: l10n.home,
        route: Routes.home,
        badge: 0,
      ),
      (
        icon: Icons.notifications_rounded,
        label: l10n.notifications,
        route: Routes.notifications,
        badge: unread,
      ),
      (
        icon: Icons.person_rounded,
        label: l10n.profileTab,
        route: Routes.profile,
        badge: 0,
      ),
      (
        icon: Icons.settings_rounded,
        label: l10n.settings,
        route: Routes.settings,
        badge: 0,
      ),
    ];
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.tbt.glassBorder)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.tbt.glassTop,
                context.tbt.glassBottom,
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 76,
              child: Row(
                children: [
                  for (final item in items)
                    Expanded(
                      child: _NavItem(
                        icon: item.icon,
                        label: item.label,
                        badge: item.badge,
                        selected: item.route == current,
                        // Từ Trang chủ mở tab mới; giữa các tab thì thay màn để quay lại luôn về Trang chủ
                        onTap: () => switch (item.route) {
                          _ when item.route == current => null,
                          Routes.home => context.go(Routes.home),
                          _ when current == Routes.home => context.push(item.route),
                          _ => context.pushReplacement(item.route),
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final size = selected ? 46.0 : 34.0;
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: InkResponse(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: size,
              height: size,
              // Căn giữa để Badge chỉ ôm biểu tượng, không giãn theo cả vòng tròn
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? color : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Badge(
                isLabelVisible: badge > 0,
                label: Text(badge > 99 ? '99+' : '$badge'),
                child: Icon(
                  icon,
                  size: selected ? 24 : 22,
                  color: selected ? Theme.of(context).colorScheme.onPrimary : context.tbt.navIdle,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: selected ? 12 : 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? context.tbt.textMain : context.tbt.navIdle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Công cụ debug: gọi thử máy chủ khu vực qua Kong kèm token
class RegionCheckCard extends ConsumerStatefulWidget {
  const RegionCheckCard({super.key, required this.session});

  final Session session;

  @override
  ConsumerState<RegionCheckCard> createState() => _RegionCheckCardState();
}

class _RegionCheckCardState extends ConsumerState<RegionCheckCard> {
  bool _loading = false;
  Response<Map<String, dynamic>>? _result;

  Future<void> _check() async {
    setState(() => _loading = true);
    try {
      final response = await ref
          .read(apiClientProvider)
          .get<Map<String, dynamic>>(
            '${Env.kongUrl(widget.session.region)}/hr/',
          );
      if (mounted) setState(() => _result = response);
    } on DioException catch (e) {
      reportFailure(e.error ?? e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final result = _result;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.regionCheckTitle, style: text.titleLarge),
            const SizedBox(height: 4),
            Text(
              l10n.regionCheckHint,
              style: text.bodySmall?.copyWith(color: context.tbt.textSecondary),
            ),
            const SizedBox(height: 16),
            if (result != null) ...[
              Text(
                l10n.regionCheckOk('${result.data?['service']}'),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              if (result.extra[fromCache] == true)
                Text(l10n.savedDataNote, style: text.bodySmall),
              if (result.headers.value('x-correlation-id') case final id?)
                Text(
                  'X-Correlation-Id: $id',
                  style: text.bodySmall?.copyWith(
                    color: context.tbt.textSecondary,
                  ),
                ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: _loading ? null : _check,
              child: _loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.regionCheckButton),
            ),
          ],
        ),
      ),
    );
  }
}
