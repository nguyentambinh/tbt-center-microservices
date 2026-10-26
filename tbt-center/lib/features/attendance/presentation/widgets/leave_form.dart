/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/attendance_providers.dart';
import '../../../../core/widgets/input_rules.dart';

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

  /// Minh chứng chọn lúc gửi đơn (Word, PDF, ảnh), tải lên ngay sau khi tạo đơn
  final _files = <({String name, List<int> bytes})>[];
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDates() async {
    // Chỉ xin nghỉ cho ngày tương lai: sớm nhất là ngày mai theo giờ của nước
    final tomorrow = ref.read(regionTodayProvider).add(const Duration(days: 1));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: tomorrow,
      lastDate: tomorrow.add(const Duration(days: 365)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _attach() async {
    final l10n = AppLocalizations.of(context);
    final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['docx', 'pdf', 'jpg', 'jpeg', 'png']);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (bytes.length > 10 * 1024 * 1024) {
      setState(() => _error = l10n.errFileTooLarge);
      return;
    }
    setState(() {
      _files.add((name: picked.name, bytes: bytes));
      _error = null;
    });
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
      final repository = ref.read(attendanceRepositoryProvider);
      final language = Localizations.localeOf(context).languageCode;
      final leave = await repository.requestLeave(
            fromDate: range.start,
            toDate: range.end,
            leaveType: type,
            reason: _reason.text.trim(),
          );
      for (final f in _files) {
        await repository.uploadLeaveFile(leave.id, fileName: f.name, bytes: f.bytes, language: language);
      }
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
            inputFormatters: InputRules.note,
            controller: _reason,
            maxLines: 2,
            decoration: InputDecoration(labelText: l10n.reason, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.attach_file),
            onPressed: _sending || _files.length >= 5 ? null : _attach,
            label: Text(l10n.leaveAttach),
          ),
          for (final (i, f) in _files.indexed)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: Text(f.name, overflow: TextOverflow.ellipsis),
              trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _files.removeAt(i))),
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
