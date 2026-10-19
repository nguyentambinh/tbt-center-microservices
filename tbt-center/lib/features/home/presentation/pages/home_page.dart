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
import '../../../audit/presentation/providers/audit_providers.dart';
import '../../../notification/presentation/providers/notification_providers.dart';

typedef _Feature = ({IconData icon, String title, String hint, String route});

/// Màn chính: chức năng theo role
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  List<(String, List<_Feature>)> _sections(
    AppLocalizations l10n,
    Session session,
  ) {
    final roles = session.roles;
    bool any(Set<String> set) => roles.any(set.contains);
    final sections = [
      (
        l10n.sectionMyWork,
        [
          if (any(staffRoles)) ...[
            (
              icon: Icons.event_available_outlined,
              title: l10n.attendance,
              hint: l10n.attendanceHint,
              route: Routes.attendance,
            ),
            (
              icon: Icons.payments_outlined,
              title: l10n.payslips,
              hint: l10n.payslipsHint,
              route: Routes.payslips,
            ),
            (
              icon: Icons.engineering_outlined,
              title: l10n.myProjects,
              hint: l10n.myProjectsHint,
              route: Routes.myProjects,
            ),
          ],
          if (roles.contains('candidate'))
            (
              icon: Icons.work_outline,
              title: l10n.myApplication,
              hint: l10n.myApplicationHint,
              route: Routes.myApplication,
            ),
        ],
      ),
      (
        l10n.sectionManage,
        [
          if (any(projectViewerRoles)) ...[
            (
              icon: Icons.badge_outlined,
              title: l10n.employees,
              hint: l10n.employeesHint,
              route: Routes.employees,
            ),
            (
              icon: Icons.apartment_outlined,
              title: l10n.projects,
              hint: l10n.projectsHint,
              route: Routes.projects,
            ),
          ],
          if (any({'hr', 'admin', 'executive'}))
            (
              icon: Icons.groups_outlined,
              title: l10n.candidates,
              hint: l10n.candidatesHint,
              route: Routes.candidates,
            ),
        ],
      ),
      (
        l10n.sectionFinance,
        [
          if (any(financeViewerRoles)) ...[
            (
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.finance,
              hint: l10n.financeHint,
              route: Routes.finance,
            ),
            (
              icon: Icons.insights_outlined,
              title: l10n.groupReport,
              hint: l10n.groupReportHint,
              route: Routes.groupReport,
            ),
            (
              icon: Icons.account_balance_outlined,
              title: l10n.payrollRuns,
              hint: l10n.payrollRunsHint,
              route: Routes.payrollRuns,
            ),
          ],
        ],
      ),
      (
        l10n.sectionKnowledge,
        [
          if (any(staffRoles))
            (icon: Icons.menu_book_outlined, title: l10n.knowledge, hint: l10n.knowledgeHint, route: Routes.knowledge),
        ],
      ),
      (
        l10n.sectionAudit,
        [
          if (any(auditReaderRoles))
            (
              icon: Icons.fact_check_outlined,
              title: l10n.auditLog,
              hint: l10n.auditLogHint,
              route: Routes.auditLog,
            ),
        ],
      ),
    ];
    return [
      for (final s in sections)
        if (s.$2.isNotEmpty) s,
    ];
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
            expandedHeight: 170,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Tooltip(
                  message: l10n.signOut,
                  child: FilledButton(
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).signOut(),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Icon(Icons.logout, size: 20),
                  ),
                ),
              ),
            ],
            // Logo lớn cuộn chậm hơn nội dung (parallax), thu gọn thì hiện logo nhỏ
            flexibleSpace: LayoutBuilder(
              builder: (context, box) {
                final top = MediaQuery.paddingOf(context).top;
                final expanded = ((box.maxHeight - top - kToolbarHeight) / 106).clamp(0.0, 1.0);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Padding(
                        padding: EdgeInsets.only(top: top + 40),
                        child: Center(child: Opacity(opacity: expanded, child: TbtLogo(gem: gem, height: 92))),
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
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final role in session.roles)
                        Chip(label: Text(l10n.roleName(role))),
                      Chip(
                        avatar: Icon(Icons.public, size: 18, color: gem.color),
                        label: Text(l10n.regionName(session.region)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  for (final (title, features) in _sections(l10n, session)) ...[
                    SectionLabel(title),
                    for (final feature in features) ...[
                      FadeSlideIn(
                        index: ++index,
                        child: _FeatureCard(feature: feature),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 8),
                  ],
                  _RegionCheckCard(session: session),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return PressableScale(
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(feature.icon, color: AppColors.background, size: 24),
          ),
          title: Text(feature.title),
          subtitle: Text(
            feature.hint,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
          onTap: () => context.push(feature.route),
        ),
      ),
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
            border: const Border(top: BorderSide(color: AppColors.glassBorder)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.05),
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
                        onTap: () {
                          if (item.route != current) context.push(item.route);
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
                  color: selected ? AppColors.background : Colors.white60,
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
                color: selected ? Colors.white : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionCheckCard extends ConsumerStatefulWidget {
  const _RegionCheckCard({required this.session});

  final Session session;

  @override
  ConsumerState<_RegionCheckCard> createState() => _RegionCheckCardState();
}

class _RegionCheckCardState extends ConsumerState<_RegionCheckCard> {
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
              style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
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
                    color: AppColors.textSecondary,
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
