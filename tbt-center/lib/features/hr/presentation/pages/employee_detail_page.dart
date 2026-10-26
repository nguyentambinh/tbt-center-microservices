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

import '../../../../core/locale/hometowns.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../core/widgets/gem_heading.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../organization/presentation/providers/organization_providers.dart';
import '../../../organization/presentation/widgets/org_actions.dart';
import '../../domain/entities/employee.dart';
import '../providers/employee_providers.dart';
import '../widgets/executive_actions.dart';

class EmployeeDetailPage extends ConsumerWidget {
  const EmployeeDetailPage({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(employeeDetailProvider(employeeId));
    final roles = ref.watch(authControllerProvider).value?.roles ?? const <String>[];
    final canManage = roles.contains('hr');
    // Văn phòng quản lý: thăng chức, đổi lương, thưởng phạt có hiệu lực ngay
    final executive = roles.contains('executive');
    final value = detail.value;
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (executive && value != null && !value.archived)
            ExecutiveActionsMenu(
              employeeId: value.summary.id,
              name: value.summary.fullName(familyFirst: ref.watch(authControllerProvider).value?.region == 'vn'),
              onDone: () {
                ref.invalidate(employeeDetailProvider(employeeId));
                ref.invalidate(employeeListProvider);
              },
            ),
          if (canManage && value != null) _ManageMenu(employee: value),
        ],
      ),
      body: switch (detail) {
        AsyncValue(:final value?) when value.archived => Column(
            children: [
              MaterialBanner(
                leading: Icon(Icons.inventory_2_outlined, color: Theme.of(context).colorScheme.error),
                content: Text(l10n.profileArchivedBanner(value.archivedReason ?? '-')),
                actions: [if (canManage) TextButton(onPressed: () => _restore(context, ref, employeeId), child: Text(l10n.restoreProfile)) else const SizedBox.shrink()],
              ),
              Expanded(child: EmployeeProfileBody(employee: value)),
            ],
          ),
        AsyncValue(:final value?) => EmployeeProfileBody(employee: value),
        AsyncValue(:final error?) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(employeeDetailProvider(employeeId)),
          ),
        _ => const SkeletonList(),
      },
    );
  }
}

Future<void> _restore(BuildContext context, WidgetRef ref, String id) async {
  final l10n = AppLocalizations.of(context);
  try {
    await ref.read(organizationRepositoryProvider).restore(id);
    ref.invalidate(employeeDetailProvider(id));
    ref.invalidate(employeeListProvider);
    showDone(l10n.restoreDone);
  } on Object catch (e) {
    reportFailure(e);
  }
}

/// HR: điều chuyển, đề cử thăng chức, bảo lưu hồ sơ
class _ManageMenu extends ConsumerWidget {
  const _ManageMenu({required this.employee});

  final EmployeeDetail employee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = employee.summary;
    final name = s.fullName(familyFirst: ref.watch(authControllerProvider).value?.region == 'vn');
    void refresh() {
      ref.invalidate(employeeDetailProvider(s.id));
      ref.invalidate(employeeListProvider);
    }

    return PopupMenuButton<String>(
      onSelected: (v) async {
        switch (v) {
          case 'move':
            if (await transferEmployee(context, ref, s.id, fromDepartment: employee.departmentId)) refresh();
          case 'nominate':
            await nominateEmployee(context, ref, employeeId: s.id, name: name);
          case 'archive':
            if (await archiveEmployee(context, ref, employeeId: s.id, name: name)) refresh();
          case 'restore':
            await _restore(context, ref, s.id);
        }
      },
      itemBuilder: (context) => [
        if (!employee.archived) ...[
          PopupMenuItem(value: 'move', child: ListTile(leading: const Icon(Icons.drive_file_move_outline), title: Text(l10n.moveToDepartment))),
          PopupMenuItem(value: 'nominate', child: ListTile(leading: const Icon(Icons.workspace_premium_outlined), title: Text(l10n.nominatePromotion))),
          PopupMenuItem(
            value: 'archive',
            child: ListTile(
              leading: Icon(Icons.inventory_2_outlined, color: Theme.of(context).colorScheme.error),
              title: Text(l10n.archiveProfile, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ),
        ] else
          PopupMenuItem(value: 'restore', child: ListTile(leading: const Icon(Icons.unarchive_outlined), title: Text(l10n.restoreProfile))),
      ],
    );
  }
}

/// Nội dung hồ sơ nhân viên, dùng ở màn chi tiết (HR) và mục Cá nhân
class EmployeeProfileBody extends ConsumerWidget {
  const EmployeeProfileBody({super.key, required this.employee});

  final EmployeeDetail employee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final session = ref.watch(authControllerProvider).value;
    final gem = session?.gem;
    final s = employee.summary;
    String? date(Object? value) => switch (value) {
          final DateTime d => DateFormat.yMMMd(locale).format(d),
          final String text when DateTime.tryParse(text) != null =>
            DateFormat.yMMMd(locale).format(DateTime.parse(text)),
          _ => value?.toString(),
        };

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Row(
          children: [
            InitialsAvatar(initials: s.initials, radius: 36, photoUrl: s.photoUrl),
            const SizedBox(width: 16),
            Expanded(
              child: gem == null
                  ? Text(s.fullName(familyFirst: session?.region == 'vn'))
                  : GemHeading(
                      s.fullName(familyFirst: session?.region == 'vn'),
                      gem: gem,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          [s.position, s.department].whereType<String>().join(' · '),
          style: TextStyle(color: context.tbt.textSecondary),
        ),
        const SizedBox(height: 16),
        _Section(title: l10n.sectionWork, rows: {
          l10n.fieldId: s.id,
          l10n.fieldCompany: s.company,
          l10n.fieldDepartment: s.department,
          l10n.fieldPosition: s.position,
          l10n.fieldBirthYear: employee.birthYear?.toString(),
          l10n.fieldGender: switch (employee.gender) {
            1 => l10n.genderMale,
            0 => l10n.genderFemale,
            _ => null,
          },
          l10n.fieldHiredOn: date(employee.hiredOn),
          l10n.fieldLaborContract: employee.laborContract,
        }),
        _Section(title: l10n.sectionContact, rows: {
          l10n.fieldEmail: s.email,
          l10n.fieldPhone: employee.contact['phone']?.toString(),
          l10n.fieldAddress: employee.contact['address']?.toString(),
          l10n.fieldHometown: hometownName(employee.contact['hometownCode']),
        }),
        _Section(title: l10n.sectionHealth, rows: {
          l10n.fieldHeight: _unit(employee.health['heightCm'], 'cm'),
          l10n.fieldWeight: _unit(employee.health['weightKg'], 'kg'),
          l10n.fieldVision: _unit(employee.health['visionScore'], '/10'),
          l10n.fieldMedicalHistory: employee.health['medicalHistory']?.toString(),
          l10n.fieldUpdatedOn: date(employee.health['updatedOn']),
        }),
        _Section(title: l10n.sectionInsurance, rows: {
          l10n.fieldInsuranceType: employee.insurance['type']?.toString(),
          l10n.fieldInsuranceNumber: employee.insurance['number']?.toString(),
          l10n.fieldExpiresOn: date(employee.insurance['expiresOn']),
        }),
        _RelativesSection(relatives: employee.relatives),
      ],
    );
  }

  static String? _unit(Object? value, String unit) => value == null ? null : '$value $unit';
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final Map<String, String?> rows;

  @override
  Widget build(BuildContext context) {
    final filled = rows.entries.where((e) => e.value != null && e.value!.isNotEmpty).toList();
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: text.titleLarge),
            const SizedBox(height: 8),
            if (filled.isEmpty)
              Text(AppLocalizations.of(context).noData, style: TextStyle(color: context.tbt.textSecondary)),
            for (final row in filled)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(row.key, style: text.bodyMedium?.copyWith(color: context.tbt.textSecondary)),
                    ),
                    Expanded(child: Text(row.value!, style: text.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RelativesSection extends StatelessWidget {
  const _RelativesSection({required this.relatives});

  final List<Relative> relatives;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(l10n.sectionRelatives, style: Theme.of(context).textTheme.titleLarge),
            ),
            if (relatives.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.noData, style: TextStyle(color: context.tbt.textSecondary)),
              ),
            for (final r in relatives)
              ListTile(
                title: Text(r.fullName),
                subtitle: Text([r.relationship, r.phone, r.address].whereType<String>().join(' · ')),
              ),
          ],
        ),
      ),
    );
  }
}
