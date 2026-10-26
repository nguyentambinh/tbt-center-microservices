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
import '../../../../l10n/app_localizations.dart';
import '../providers/attendance_providers.dart';

Future<void> showLeaveForm(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _LeaveForm(),
    );

class _LeaveForm extends ConsumerStatefulWidget {
  const _LeaveForm();

  @override
  ConsumerState<_LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends ConsumerState<_LeaveForm> {
  final _reason = TextEditingController();
  DateTimeRange? _range;
  String? _type;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDates() async {
    final now = ref.read(regionTodayProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final range = _range;
    final type = _type;
    if (range == null || type == null) return;

    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(attendanceRepositoryProvider).requestLeave(
            fromDate: range.start,
            toDate: range.end,
            leaveType: type,
            reason: _reason.text.trim(),
          );
      ref.invalidate(myLeavesProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.leaveSubmitted), behavior: SnackBarBehavior.floating),
      );
    } on AppFailure catch (e) {
      // Lỗi hiện ngay trong form để người dùng sửa, dữ liệu đã nhập vẫn giữ nguyên.
      setState(() => _error = e.message(l10n));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final format = DateFormat.yMMMd(locale);
    final types = [l10n.leaveAnnual, l10n.leaveSick, l10n.leaveUnpaid, l10n.leavePersonal];
    final range = _range;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.newLeave, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: InputDecoration(labelText: l10n.leaveType, border: const OutlineInputBorder()),
            items: [for (final t in types) DropdownMenuItem(value: t, child: Text(t))],
            onChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDates,
            label: Text(range == null ? l10n.pickDates : '${format.format(range.start)} – ${format.format(range.end)}'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            maxLines: 2,
            decoration: InputDecoration(labelText: l10n.reason, border: const OutlineInputBorder()),
          ),
          if (_error case final error?) ...[
            const SizedBox(height: 12),
            Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _sending || range == null || _type == null ? null : _submit,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: _sending
                ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.submitLeave),
          ),
        ],
      ),
    );
  }
}
