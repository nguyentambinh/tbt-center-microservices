/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/job_position.dart';
import '../providers/candidate_providers.dart';
import '../widgets/position_widgets.dart';
import '../widgets/stage_widgets.dart';
import '../../../../core/widgets/input_rules.dart';

/// Ai mở, sửa vị trí tuyển dụng (Ban lãnh đạo chỉ xem)
const positionManagerRoles = {'hr', 'admin'};

/// HR mở vị trí và số người cần tuyển; xem ứng viên từng vị trí theo điểm AI so khớp
class JobPositionsPage extends ConsumerWidget {
  const JobPositionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final positions = ref.watch(allPositionsProvider);
    final manager = ref.watch(authControllerProvider).value?.roles.any(positionManagerRoles.contains) ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.jobPositions)),
      floatingActionButton: manager
          ? FloatingActionButton.extended(
              onPressed: () => editJobPosition(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.newJobPosition),
            )
          : null,
      body: switch (positions) {
        AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noJobPositions, icon: Icons.work_outline),
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(allPositionsProvider.future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                for (final p in value)
                  FadeSlideIn(
                    child: _PositionCard(
                      position: p,
                      onTap: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (_) => _PositionSheet(id: p.id, manager: manager),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(allPositionsProvider)),
        _ => const SkeletonList(),
      },
    );
  }
}

class _PositionCard extends StatelessWidget {
  const _PositionCard({required this.position, required this.onTap});

  final JobPosition position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = position;
    final status = !p.open
        ? (l10n.positionClosed, context.tbt.textSecondary)
        : p.remaining <= 0
            ? (l10n.positionFilled, context.tbt.success)
            : (l10n.positionOpen, context.tbt.info);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Text(status.$1, style: TextStyle(color: status.$2, fontSize: 12)),
              ]),
              if (p.department case final d?) Text(d, style: TextStyle(color: context.tbt.textSecondary)),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: p.headcount == 0 ? 0 : p.hired / p.headcount, minHeight: 6, borderRadius: BorderRadius.circular(3)),
              const SizedBox(height: 6),
              Text(l10n.positionProgress(p.hired, p.headcount, p.applicants), style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PositionSheet extends ConsumerWidget {
  const _PositionSheet({required this.id, required this.manager});

  final int id;
  final bool manager;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(positionDetailProvider(id));
    final text = Theme.of(context).textTheme;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: switch (detail) {
        AsyncValue(:final value?) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text(value.title, style: text.headlineSmall),
              if (value.department case final d?) Text(d, style: TextStyle(color: context.tbt.textSecondary)),
              const SizedBox(height: 8),
              Text(l10n.positionProgress(value.hired, value.headcount, value.applicants)),
              if (value.description.isNotEmpty) ...[const SizedBox(height: 12), Text(l10n.positionDescription, style: text.titleSmall), Text(value.description)],
              if (value.requirements.isNotEmpty) ...[const SizedBox(height: 12), Text(l10n.positionRequirements, style: text.titleSmall), Text(value.requirements)],
              if (manager) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  OutlinedButton.icon(onPressed: () => editJobPosition(context, ref, current: value), icon: const Icon(Icons.edit_outlined), label: Text(l10n.editJobPosition)),
                  TextButton(
                    onPressed: () => _toggle(context, ref, value),
                    child: Text(value.open ? l10n.closePosition : l10n.reopenPosition),
                  ),
                ]),
              ],
              const Divider(height: 32),
              Text(l10n.positionApplicants, style: text.titleLarge),
              if (value.candidates.isEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(l10n.noCandidates, style: TextStyle(color: context.tbt.textSecondary))),
              for (final c in value.candidates)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: c.matchScore == null ? null : matchColor(context, c.matchScore!).withValues(alpha: 0.18),
                    child: Text(c.matchScore == null ? '–' : '${c.matchScore}', style: TextStyle(color: c.matchScore == null ? null : matchColor(context, c.matchScore!), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  title: Text(c.fullName),
                  subtitle: c.matchVerdict == null || c.matchVerdict!.isEmpty ? null : Text(c.matchVerdict!, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: StageChip(c.status),
                ),
            ],
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(positionDetailProvider(id))),
        _ => const SkeletonList(),
      },
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, JobPosition p) async {
    try {
      await ref.read(jobPositionRepositoryProvider).update(p.id, JobPositionInput(
            title: p.title,
            headcount: p.headcount,
            department: p.department,
            description: p.description,
            requirements: p.requirements,
            status: p.open ? 'closed' : 'open',
          ));
      ref
        ..invalidate(allPositionsProvider)
        ..invalidate(positionDetailProvider(p.id));
    } on Object catch (e) {
      reportFailure(e);
    }
  }
}

/// Hộp thêm hoặc sửa vị trí tuyển dụng
Future<void> editJobPosition(BuildContext context, WidgetRef ref, {JobPosition? current}) async {
  final input = await showDialog<JobPositionInput>(context: context, builder: (_) => _PositionDialog(current: current));
  if (input == null) return;
  try {
    final repository = ref.read(jobPositionRepositoryProvider);
    if (current == null) {
      await repository.create(input);
    } else {
      await repository.update(current.id, input);
      ref.invalidate(positionDetailProvider(current.id));
    }
    ref.invalidate(allPositionsProvider);
    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.positionSaved), behavior: SnackBarBehavior.floating));
    }
  } on Object catch (e) {
    reportFailure(e);
  }
}

class _PositionDialog extends StatefulWidget {
  const _PositionDialog({this.current});

  final JobPosition? current;

  @override
  State<_PositionDialog> createState() => _PositionDialogState();
}

class _PositionDialogState extends State<_PositionDialog> {
  late final _title = TextEditingController(text: widget.current?.title);
  late final _department = TextEditingController(text: widget.current?.department);
  late final _headcount = TextEditingController(text: '${widget.current?.headcount ?? 1}');
  late final _description = TextEditingController(text: widget.current?.description);
  late final _requirements = TextEditingController(text: widget.current?.requirements);

  @override
  void dispose() {
    for (final c in [_title, _department, _headcount, _description, _requirements]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final headcount = int.tryParse(_headcount.text) ?? 0;
    final hired = widget.current?.hired ?? 0;
    final headcountError = headcount < 1 || headcount > 500
        ? l10n.errInvalidHeadcount
        : headcount < hired
            ? l10n.errHeadcountBelowHired(hired)
            : null;
    final valid = _title.text.trim().isNotEmpty && headcountError == null;
    return AlertDialog(
      title: Text(widget.current == null ? l10n.newJobPosition : l10n.editJobPosition),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(inputFormatters: InputRules.shortText, controller: _title, decoration: InputDecoration(labelText: l10n.positionTitle), onChanged: (_) => setState(() {})),
            TextField(inputFormatters: InputRules.shortText, controller: _department, decoration: InputDecoration(labelText: l10n.positionDepartment)),
            TextField(
              controller: _headcount,
              keyboardType: TextInputType.number,
              inputFormatters: InputRules.digits,
              decoration: InputDecoration(labelText: l10n.positionHeadcount, errorText: headcountError),
              onChanged: (_) => setState(() {}),
            ),
            TextField(inputFormatters: InputRules.longText, controller: _description, maxLines: 3, decoration: InputDecoration(labelText: l10n.positionDescription)),
            TextField(inputFormatters: InputRules.longText, controller: _requirements, maxLines: 4, decoration: InputDecoration(labelText: l10n.positionRequirements, helperText: l10n.positionRequirementsHint, helperMaxLines: 2)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: !valid
              ? null
              : () => Navigator.pop(
                    context,
                    JobPositionInput(
                      title: _title.text.trim(),
                      headcount: headcount,
                      department: _department.text.trim().isEmpty ? null : _department.text.trim(),
                      description: _description.text.trim(),
                      requirements: _requirements.text.trim(),
                      status: widget.current?.status ?? 'open',
                    ),
                  ),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
