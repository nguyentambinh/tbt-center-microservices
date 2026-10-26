/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import '../pages/org_tree_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/organization.dart';
import '../providers/organization_providers.dart';

void showDone(String message) => scaffoldMessengerKey.currentState
  ?..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));

String dissolutionReasonLabel(AppLocalizations l10n, String code) => switch (code) {
      'no_longer_needed' => l10n.dissolveNoLongerNeeded,
      'restructured' => l10n.dissolveRestructured,
      'underperforming' => l10n.dissolveUnderperforming,
      'outsourced' => l10n.dissolveOutsourced,
      _ => l10n.dissolveBusinessClosed,
    };

/// Chọn phòng ban đích; [exclude] là phòng hiện tại
Future<Department?> pickDepartment(BuildContext context, WidgetRef ref, {String? exclude, String? title}) async {
  final l10n = AppLocalizations.of(context);
  final List<Department> all;
  try {
    all = await ref.read(departmentsProvider.future);
  } on Object catch (e) {
    reportFailure(e);
    return null;
  }
  if (!context.mounted) return null;
  final options = all.where((d) => d.id != exclude).toList();
  return showModalBottomSheet<Department>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      builder: (context, scroll) => ListView(
        controller: scroll,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(title ?? l10n.moveToDepartment, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          for (final d in options)
            ListTile(
              leading: const Icon(Icons.apartment_outlined),
              title: Text(d.name),
              subtitle: Text([d.company, l10n.departmentMembers(d.members)].whereType<String>().join(' · ')),
              onTap: () => Navigator.pop(context, d),
            ),
        ],
      ),
    ),
  );
}

/// Điều chuyển một nhân viên sang phòng khác
Future<bool> transferEmployee(BuildContext context, WidgetRef ref, String employeeId, {String? fromDepartment}) async {
  final l10n = AppLocalizations.of(context);
  final target = await pickDepartment(context, ref, exclude: fromDepartment);
  if (target == null) return false;
  try {
    await ref.read(organizationRepositoryProvider).transfer(target.id, [employeeId]);
    ref.invalidate(departmentsProvider);
    ref.invalidate(departmentDetailProvider);
    ref.invalidate(unassignedProvider);
    showDone(l10n.transferDone(target.name));
    return true;
  } on Object catch (e) {
    reportFailure(e);
    return false;
  }
}

/// Đề cử thăng chức gửi Ban lãnh đạo
Future<void> nominateEmployee(BuildContext context, WidgetRef ref, {required String employeeId, required String name}) async {
  final l10n = AppLocalizations.of(context);
  // Thăng chức theo cây chức vụ: chỉ chọn được chức vụ cấp cao hơn hiện tại
  final List<({String id, String name, int level})> higher;
  try {
    higher = await ref.read(organizationRepositoryProvider).positionsAbove(employeeId);
  } on Object catch (e) {
    reportFailure(e);
    return;
  }
  if (!context.mounted) return;
  if (higher.isEmpty) {
    showDone(l10n.noHigherPosition);
    return;
  }
  final position = TextEditingController();
  final percent = TextEditingController(text: '10');
  final reason = TextEditingController();
  final form = GlobalKey<FormState>();
  // Phạm vi: trong nước theo cây chức vụ, hoặc lên Nhân sự/Tài chính tập đoàn (văn phòng tập đoàn duyệt)
  String? groupRole;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
      title: Text(l10n.nominateTitle(name)),
      content: Form(
        key: form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String?>(
                isExpanded: true,
                initialValue: null,
                decoration: InputDecoration(labelText: l10n.nominationScope),
                items: [
                  DropdownMenuItem(child: Text(l10n.nominationScopeRegion)),
                  DropdownMenuItem(value: 'hr', child: Text(l10n.nominationScopeGroupHr)),
                  DropdownMenuItem(value: 'finance', child: Text(l10n.nominationScopeGroupFinance)),
                ],
                onChanged: (v) => setState(() => groupRole = v),
              ),
              const SizedBox(height: 12),
              if (groupRole == null)
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.proposedPosition),
                items: [
                  for (final p in higher)
                    DropdownMenuItem(value: p.name, child: Text('${p.name} · ${levelName(l10n, p.level)}', overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => position.text = v ?? '',
                validator: (v) => (v ?? '').isEmpty ? l10n.fieldRequired : null,
              )
              else
                Text(l10n.nominationGroupNote, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              TextFormField(
                controller: percent,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.raisePercent, suffixText: '%'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  return n == null || n <= 0 || n > 100 ? l10n.raisePercentInvalid : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: reason,
                maxLines: 3,
                decoration: InputDecoration(labelText: l10n.nominationReason),
                validator: (v) => (v ?? '').trim().isEmpty ? l10n.fieldRequired : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () {
            if (form.currentState!.validate()) Navigator.pop(context, true);
          },
          child: Text(l10n.sendToExecutives),
        ),
      ],
    ),
    ),
  );
  if (ok != true) return;
  try {
    await ref.read(organizationRepositoryProvider).nominate(
          employeeId: employeeId,
          proposedPosition: groupRole == null ? position.text.trim() : 'group:$groupRole',
          raisePercent: double.parse(percent.text.replaceAll(',', '.')),
          reason: reason.text.trim(),
          groupRole: groupRole,
        );
    ref.invalidate(nominationsProvider);
    showDone(l10n.nominationSent);
  } on Object catch (e) {
    reportFailure(e);
  }
}

/// Bảo lưu hồ sơ: cảnh báo dự án đang tham gia, đồng ý thì rút khỏi tất cả
Future<bool> archiveEmployee(BuildContext context, WidgetRef ref, {required String employeeId, required String name}) async {
  final l10n = AppLocalizations.of(context);
  final repository = ref.read(organizationRepositoryProvider);
  final List<Map<String, dynamic>> projects;
  try {
    projects = await repository.projectsOf(employeeId);
  } on Object catch (e) {
    reportFailure(e);
    return false;
  }
  if (!context.mounted) return false;
  final reason = TextEditingController();
  final form = GlobalKey<FormState>();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(Icons.inventory_2_outlined, color: Theme.of(context).colorScheme.error),
      title: Text(l10n.archiveTitle(name)),
      content: Form(
        key: form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(projects.isEmpty ? l10n.archiveNoProjects : l10n.archiveProjectsWarning(projects.length)),
              for (final p in projects)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Icon(Icons.engineering_outlined, size: 18, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${p['name'] ?? p['projectId']}')),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Text(l10n.archiveKeepsPersonal),
              const SizedBox(height: 12),
              TextFormField(
                controller: reason,
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.archiveReason),
                validator: (v) => (v ?? '').trim().isEmpty ? l10n.fieldRequired : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: () {
            if (form.currentState!.validate()) Navigator.pop(context, true);
          },
          child: Text(l10n.archiveConfirm),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  try {
    final left = await repository.archive(employeeId, reason.text.trim());
    ref.invalidate(departmentsProvider);
    ref.invalidate(departmentDetailProvider);
    showDone(l10n.archiveDone(left));
    return true;
  } on Object catch (e) {
    reportFailure(e);
    return false;
  }
}
