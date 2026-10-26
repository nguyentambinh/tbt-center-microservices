/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_gateway.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/auth/session.dart';
import '../../../../core/locale/hometowns.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../hr/presentation/pages/employee_detail_page.dart';
import '../../domain/change_request.dart';
import '../providers/profile_providers.dart';

/// Chữ hiển thị của từng trường được đề xuất sửa
String profileFieldLabel(AppLocalizations l10n, String key) => switch (key) {
      'email' => l10n.fieldEmail,
      'phone' => l10n.fieldPhone,
      'address' => l10n.fieldAddress,
      'facebook' => l10n.fieldFacebook,
      'xHandle' => l10n.fieldXHandle,
      'hometownCode' => l10n.fieldHometown,
      'heightCm' => l10n.fieldHeight,
      'weightKg' => l10n.fieldWeight,
      'visionScore' => l10n.fieldVision,
      'medicalHistory' => l10n.fieldMedicalHistory,
      _ => key,
    };

String changeStatusLabel(AppLocalizations l10n, String status) => switch (status) {
      'approved' => l10n.statusApproved,
      'rejected' => l10n.statusRejected,
      _ => l10n.statusPending,
    };

/// Mục Cá nhân ở thanh điều hướng: nhân viên xem hồ sơ của mình và đề xuất sửa; tài khoản không phải nhân viên xem thông tin tài khoản
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider).value;
    final isEmployee = session?.employeeId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProfile),
        actions: [
          IconButton(
            tooltip: l10n.changePassword,
            icon: const Icon(Icons.password),
            onPressed: () => _changePassword(context, ref),
          ),
          if (isEmployee)
            IconButton(
              tooltip: l10n.changeHistory,
              icon: const Icon(Icons.history),
              onPressed: () => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => const _HistorySheet()),
            ),
        ],
      ),
      bottomNavigationBar: const TbtBottomNav(current: Routes.profile),
      floatingActionButton: isEmployee
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.edit_note),
              label: Text(l10n.proposeChange),
              onPressed: () => context.push(Routes.profileEdit),
            )
          : null,
      body: session == null
          ? const SizedBox.shrink()
          : isEmployee
              ? const _EmployeeProfile()
              : _AccountView(session: session),
    );
  }
}

Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  try {
    await ref.read(authControllerProvider.notifier).changePassword(locale: Localizations.localeOf(context).languageCode);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordChanged), behavior: SnackBarBehavior.floating));
  } on SignInCancelled {
    // Đóng trang đổi mật khẩu thì giữ nguyên
  } on Object catch (e) {
    reportFailure(e);
  }
}

class _EmployeeProfile extends ConsumerWidget {
  const _EmployeeProfile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(myProfileProvider);
    final pending = ref.watch(myChangeRequestsProvider).value?.any((r) => r.pending) ?? false;
    return switch (profile) {
      AsyncValue(:final value?) => Column(
          children: [
            if (pending)
              MaterialBanner(
                leading: const Icon(Icons.hourglass_top),
                content: Text(l10n.changeRequestPending),
                actions: const [SizedBox.shrink()],
              ),
            Expanded(child: EmployeeProfileBody(employee: value)),
          ],
        ),
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(myProfileProvider)),
      _ => const SkeletonList(),
    };
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    Widget row(String label, String? value) => ListTile(
          dense: true,
          title: Text(label, style: TextStyle(color: context.tbt.textSecondary)),
          trailing: Text(value ?? '-'),
        );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(session.displayName, style: text.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              row(l10n.accountInfo, session.username),
              row(l10n.fieldEmail, session.claims['email'] as String?),
              row(l10n.fieldPhone, session.claims['phone_number'] as String?),
            ],
          ),
        ),
        if (session.roles.isEmpty)
          FilledButton.icon(
            icon: const Icon(Icons.work_outline),
            label: Text(l10n.myApplication),
            onPressed: () => context.push(Routes.myApplication),
          ),
      ],
    );
  }
}

class _HistorySheet extends ConsumerWidget {
  const _HistorySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final requests = ref.watch(myChangeRequestsProvider);
    return SafeArea(
      child: switch (requests) {
        AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noChangeRequests),
        AsyncValue(:final value?) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(l10n.changeHistory, style: Theme.of(context).textTheme.titleLarge),
              for (final r in value) ChangeRequestTile(request: r, locale: locale),
            ],
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(myChangeRequestsProvider)),
        _ => const SkeletonList(),
      },
    );
  }
}

/// Một đề xuất: thời gian, trạng thái, các trường muốn đổi, lý do, ghi chú của HR
class ChangeRequestTile extends StatelessWidget {
  const ChangeRequestTile({super.key, required this.request, required this.locale, this.showName = false, this.actions});

  final ChangeRequest request;
  final String locale;
  final bool showName;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final color = switch (request.status) {
      'approved' => Colors.green.shade600,
      'rejected' => scheme.error,
      _ => scheme.primary,
    };
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    showName ? request.employeeName : DateFormat.yMMMd(locale).add_Hm().format(request.requestedAt),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Chip(label: Text(changeStatusLabel(l10n, request.status)), side: BorderSide(color: color), labelStyle: TextStyle(color: color)),
              ],
            ),
            if (showName)
              Text(DateFormat.yMMMd(locale).add_Hm().format(request.requestedAt), style: TextStyle(color: context.tbt.textSecondary)),
            const SizedBox(height: 6),
            for (final MapEntry(:key, :value) in request.changes.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(child: Text(profileFieldLabel(l10n, key), style: TextStyle(color: context.tbt.textSecondary))),
                    Flexible(child: Text(key == 'hometownCode' ? hometownName(value) ?? '-' : '${value ?? '-'}', textAlign: TextAlign.end)),
                  ],
                ),
              ),
            if (request.reason case final reason? when reason.isNotEmpty) Text('${l10n.reason}: $reason'),
            if (request.note case final note? when note.isNotEmpty) Text('${l10n.note}: $note', style: TextStyle(color: color)),
            ?actions,
          ],
        ),
      ),
    );
  }
}
