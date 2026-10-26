/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../organization/presentation/providers/organization_providers.dart';
import '../../../organization/presentation/widgets/org_actions.dart';
import '../../data/direct_actions_repository.dart';

/// Menu làm thẳng của văn phòng quản lý trên hồ sơ nhân viên
class ExecutiveActionsMenu extends ConsumerWidget {
  const ExecutiveActionsMenu({super.key, required this.employeeId, required this.name, required this.onDone});

  final String employeeId;
  final String name;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      tooltip: l10n.execActions,
      icon: const Icon(Icons.bolt),
      onSelected: (v) async {
        final done = await showDialog<bool>(
          context: context,
          builder: (_) => switch (v) {
            'position' => _PositionDialog(employeeId: employeeId, name: name),
            'salary' => _SalaryDialog(employeeId: employeeId, name: name),
            _ => _BonusDialog(employeeId: employeeId, name: name),
          },
        );
        if (done == true) {
          onDone();
          showDone(l10n.execApplied);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'position', child: ListTile(leading: const Icon(Icons.trending_up), title: Text(l10n.execChangePosition))),
        PopupMenuItem(value: 'salary', child: ListTile(leading: const Icon(Icons.payments_outlined), title: Text(l10n.execSalary))),
        PopupMenuItem(value: 'bonus', child: ListTile(leading: const Icon(Icons.card_giftcard_outlined), title: Text(l10n.execBonus))),
      ],
    );
  }
}

/// Khung chung: tiêu đề, ghi chú "có hiệu lực ngay, ghi sổ kiểm toán", nút áp dụng
class _ActionDialog extends StatelessWidget {
  const _ActionDialog({required this.title, required this.children, required this.busy, required this.onApply});

  final String title;
  final List<Widget> children;
  final bool busy;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ...children,
          const SizedBox(height: 12),
          Text(l10n.execAuditNote, style: TextStyle(fontSize: 12, color: context.tbt.textSecondary)),
        ]),
      ),
      actions: [
        TextButton(onPressed: busy ? null : () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: busy ? null : onApply,
          child: busy ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.execApply),
        ),
      ],
    );
  }
}

class _PositionDialog extends ConsumerStatefulWidget {
  const _PositionDialog({required this.employeeId, required this.name});

  final String employeeId;
  final String name;

  @override
  ConsumerState<_PositionDialog> createState() => _PositionDialogState();
}

class _PositionDialogState extends ConsumerState<_PositionDialog> {
  final _reason = TextEditingController();
  bool _promote = true;
  String? _positionId;
  bool _busy = false;
  late Future<List<PositionOption>> _options = _load();

  Future<List<PositionOption>> _load() async => _promote
      ? [for (final p in await ref.read(organizationRepositoryProvider).positionsAbove(widget.employeeId)) (id: p.id, name: p.name)]
      : ref.read(directActionsProvider).positions();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    setState(() => _busy = true);
    try {
      await ref.read(directActionsProvider).changePosition(widget.employeeId, positionId: _positionId!, promote: _promote, reason: _reason.text.trim());
      if (mounted) Navigator.pop(context, true);
    } on Object catch (e) {
      reportFailure(e);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _ActionDialog(
      title: '${l10n.execChangePosition} · ${widget.name}',
      busy: _busy,
      onApply: _positionId == null ? null : _apply,
      children: [
        SegmentedButton<bool>(
          segments: [ButtonSegment(value: true, label: Text(l10n.execPromote)), ButtonSegment(value: false, label: Text(l10n.execChangeOnly))],
          selected: {_promote},
          onSelectionChanged: (v) => setState(() {
            _promote = v.first;
            _positionId = null;
            _options = _load();
          }),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<PositionOption>>(
          future: _options,
          builder: (context, snap) => switch (snap) {
            AsyncSnapshot(:final data?) when data.isEmpty => Text(l10n.execNoHigherPosition),
            AsyncSnapshot(:final data?) => DropdownButtonFormField<String>(
                key: ValueKey(_promote),
                isExpanded: true,
                initialValue: _positionId,
                decoration: InputDecoration(labelText: l10n.execNewPosition),
                items: [for (final p in data) DropdownMenuItem(value: p.id, child: Text(p.name, overflow: TextOverflow.ellipsis))],
                onChanged: (v) => setState(() => _positionId = v),
              ),
            AsyncSnapshot(:final error?) => Text(error is AppFailure ? error.message(l10n) : l10n.errorUnknown),
            _ => const LinearProgressIndicator(),
          },
        ),
        const SizedBox(height: 12),
        TextField(controller: _reason, maxLines: 2, decoration: InputDecoration(labelText: l10n.execReason)),
      ],
    );
  }
}

class _SalaryDialog extends ConsumerStatefulWidget {
  const _SalaryDialog({required this.employeeId, required this.name});

  final String employeeId;
  final String name;

  @override
  ConsumerState<_SalaryDialog> createState() => _SalaryDialogState();
}

class _SalaryDialogState extends ConsumerState<_SalaryDialog> {
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  bool _busy = false;
  late final _current = ref.read(directActionsProvider).salary(widget.employeeId);

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  double? get _value => double.tryParse(_amount.text.replaceAll(RegExp(r'[^0-9]'), ''));

  Future<void> _apply() async {
    setState(() => _busy = true);
    try {
      await ref.read(directActionsProvider).setBaseSalary(widget.employeeId, amount: _value!, reason: _reason.text.trim());
      if (mounted) Navigator.pop(context, true);
    } on Object catch (e) {
      reportFailure(e);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final money = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    return _ActionDialog(
      title: '${l10n.execSalary} · ${widget.name}',
      busy: _busy,
      onApply: (_value ?? 0) > 0 ? _apply : null,
      children: [
        FutureBuilder(
          future: _current,
          builder: (context, snap) => Text(switch (snap.data) {
            (baseSalary: final s?, currency: final c) => l10n.execCurrentSalary('${money.format(s)} ${c ?? ''}'.trim()),
            _ when snap.connectionState == ConnectionState.waiting => '…',
            _ => l10n.execCurrentSalary('-'),
          }),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: l10n.execNewSalary),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(controller: _reason, maxLines: 2, decoration: InputDecoration(labelText: l10n.execReason)),
      ],
    );
  }
}

class _BonusDialog extends ConsumerStatefulWidget {
  const _BonusDialog({required this.employeeId, required this.name});

  final String employeeId;
  final String name;

  @override
  ConsumerState<_BonusDialog> createState() => _BonusDialogState();
}

class _BonusDialogState extends ConsumerState<_BonusDialog> {
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  bool _bonus = true;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  double? get _value => double.tryParse(_amount.text);

  Future<void> _apply() async {
    setState(() => _busy = true);
    try {
      await ref.read(directActionsProvider).addBonusPenalty(widget.employeeId, bonus: _bonus, amount: _value!, reason: _reason.text.trim());
      if (mounted) Navigator.pop(context, true);
    } on Object catch (e) {
      reportFailure(e);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _ActionDialog(
      title: '${l10n.execBonus} · ${widget.name}',
      busy: _busy,
      onApply: (_value ?? 0) > 0 && _reason.text.trim().isNotEmpty ? _apply : null,
      children: [
        SegmentedButton<bool>(
          segments: [ButtonSegment(value: true, label: Text(l10n.execBonusKind)), ButtonSegment(value: false, label: Text(l10n.execPenaltyKind))],
          selected: {_bonus},
          onSelectionChanged: (v) => setState(() => _bonus = v.first),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: l10n.execAmount),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(controller: _reason, maxLines: 2, decoration: InputDecoration(labelText: l10n.execReasonRequired), onChanged: (_) => setState(() {})),
      ],
    );
  }
}
