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

import '../../../../core/error/app_failure.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/work_time.dart';
import '../pages/attendance_page.dart' show MineTag, showRequestDetail;
import '../providers/attendance_providers.dart';
import '../../../../core/widgets/input_rules.dart';

/// Tab đơn tăng ca của chính mình (R36).
class MyOvertimeTab extends ConsumerWidget {
  const MyOvertimeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final requests = ref.watch(myOvertimeProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.more_time),
        label: Text(l10n.newOvertime),
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => const _OvertimeForm(),
        ),
      ),
      body: switch (requests) {
        AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noOvertime, icon: Icons.more_time),
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(myOvertimeProvider.future),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final r in value)
                  OvertimeTile(
                    request: r,
                    mine: true,
                    onTap: () => showRequestDetail(context, employeeId: r.employeeId, child: OvertimeTile(request: r, mine: true)),
                  ),
              ],
            ),
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(myOvertimeProvider)),
        _ => const SkeletonList(),
      },
    );
  }
}

class OvertimeTile extends StatelessWidget {
  const OvertimeTile({super.key, required this.request, this.showEmployee = false, this.actions = const [], this.mine = false, this.onTap});

  final OvertimeRequest request;
  final bool showEmployee;
  final List<Widget> actions;
  final bool mine;

  /// Bấm vào thẻ để xem chi tiết đơn
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final (label, color) = switch (request.status) {
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
                Expanded(
                  child: Text(
                    '${DateFormat.yMMMEd(locale).format(request.workDate)} · '
                    '${l10n.overtimeHours(NumberFormat.decimalPattern(locale).format(request.hours))}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (mine && showEmployee) ...[const MineTag(), const SizedBox(width: 6)],
                Text(label, style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
            if (showEmployee) Text(request.employeeId, style: TextStyle(color: context.tbt.textSecondary)),
            if (request.reason case final reason? when reason.isNotEmpty) Text(reason),
            if (actions.isNotEmpty)
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [...actions.expand((a) => [a, const SizedBox(width: 8)])]),
          ],
        ),
      ),
      ),
    );
  }
}

class _OvertimeForm extends ConsumerStatefulWidget {
  const _OvertimeForm();

  @override
  ConsumerState<_OvertimeForm> createState() => _OvertimeFormState();
}

class _OvertimeFormState extends ConsumerState<_OvertimeForm> {
  final _reason = TextEditingController();
  late DateTime _date = ref.read(regionTodayProvider);
  double _hours = 2;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = ref.read(regionTodayProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(workTimeRepositoryProvider).requestOvertime(workDate: _date, hours: _hours, reason: _reason.text.trim());
      ref.invalidate(myOvertimeProvider);
      if (mounted) Navigator.pop(context);
    } on AppFailure catch (e) {
      // Lỗi nghiệp vụ (trùng ngày…) hiện ngay trong form để người dùng sửa.
      if (mounted) setState(() => _error = e.message(AppLocalizations.of(context)));
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final hours = NumberFormat.decimalPattern(locale);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.viewInsetsOf(context).bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.newOvertime, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.event),
            label: Text(DateFormat.yMMMEd(locale).format(_date)),
            onPressed: _pickDate,
          ),
          const SizedBox(height: 8),
          Text(l10n.overtimeHours(hours.format(_hours))),
          Slider(
            value: _hours,
            min: 0.5,
            max: 12,
            divisions: 23,
            label: hours.format(_hours),
            onChanged: (v) => setState(() => _hours = v),
          ),
          TextField(inputFormatters: InputRules.note, controller: _reason, decoration: InputDecoration(labelText: l10n.reason)),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: context.tbt.danger)),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _sending ? null : _submit,
            child: _sending
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.submitOvertime),
          ),
        ],
      ),
    );
  }
}
