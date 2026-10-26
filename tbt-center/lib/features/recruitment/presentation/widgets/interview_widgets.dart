/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/candidate.dart';
import '../../../../core/widgets/input_rules.dart';

String interviewStateName(AppLocalizations l10n, String state) => switch (state) {
      'awaiting_hr' => l10n.interviewAwaitingHr,
      'confirmed' => l10n.interviewConfirmed,
      'cancelled' => l10n.interviewCancelled,
      _ => l10n.interviewAwaitingCandidate,
    };

String formatInterviewTime(BuildContext context, DateTime at) =>
    DateFormat.yMMMMEEEEd(Localizations.localeOf(context).toString()).add_Hm().format(at);

/// Thẻ lịch phỏng vấn: giờ, địa điểm, trạng thái chờ bên nào
class InterviewCard extends StatelessWidget {
  const InterviewCard({super.key, required this.interview, this.actions = const []});

  final Interview interview;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = switch (interview.state) {
      'confirmed' => context.tbt.success,
      'cancelled' => context.tbt.danger,
      _ => context.tbt.brandGold,
    };
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: color),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.interviewSchedule, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                Text(interviewStateName(l10n, interview.state), style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(formatInterviewTime(context, interview.scheduledAt), style: const TextStyle(fontWeight: FontWeight.bold)),
            if (interview.location case final place? when place.isNotEmpty) Text(place),
            if (interview.note case final note? when note.isNotEmpty) Text(note, style: TextStyle(color: context.tbt.textSecondary)),
            if (interview.minutesName case final name?) ...[
              const SizedBox(height: 4),
              Text(l10n.minutesAttached(name), style: TextStyle(color: context.tbt.textSecondary)),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

/// Giờ hẹn người dùng chọn trong hộp đề xuất
typedef InterviewProposal = ({DateTime at, String? location, String? note});

/// Hộp chọn ngày giờ phỏng vấn; giờ đã qua thì không cho lưu
Future<InterviewProposal?> showInterviewDialog(
  BuildContext context, {
  required String title,
  DateTime? initial,
  bool askLocation = false,
  String? location,
}) {
  return showDialog<InterviewProposal>(
    context: context,
    builder: (_) => _InterviewDialog(title: title, initial: initial, askLocation: askLocation, location: location),
  );
}

class _InterviewDialog extends StatefulWidget {
  const _InterviewDialog({required this.title, required this.askLocation, this.initial, this.location});

  final String title;
  final bool askLocation;
  final DateTime? initial;
  final String? location;

  @override
  State<_InterviewDialog> createState() => _InterviewDialogState();
}

class _InterviewDialogState extends State<_InterviewDialog> {
  late DateTime? _at = widget.initial != null && widget.initial!.isAfter(DateTime.now()) ? widget.initial : null;
  late final _location = TextEditingController(text: widget.location);
  final _note = TextEditingController();

  @override
  void dispose() {
    _location.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final start = _at ?? now.add(const Duration(days: 1));
    final day = await showDatePicker(context: context, initialDate: start, firstDate: DateTime(now.year, now.month, now.day), lastDate: now.add(const Duration(days: 180)));
    if (day == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(start));
    if (time == null) return;
    setState(() => _at = DateTime(day.year, day.month, day.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final at = _at;
    final past = at != null && !at.isAfter(DateTime.now());
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: _pick,
              icon: const Icon(Icons.schedule),
              label: Text(at == null ? l10n.chooseInterviewTime : formatInterviewTime(context, at)),
            ),
            if (past) Padding(padding: const EdgeInsets.only(top: 6), child: Text(l10n.errTimeInPast, style: TextStyle(color: Theme.of(context).colorScheme.error))),
            if (widget.askLocation) ...[
              const SizedBox(height: 12),
              TextField(inputFormatters: InputRules.shortText, controller: _location, decoration: InputDecoration(labelText: l10n.interviewLocation)),
            ],
            const SizedBox(height: 12),
            TextField(inputFormatters: InputRules.note, controller: _note, maxLines: 2, decoration: InputDecoration(labelText: l10n.note)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: at == null || past
              ? null
              : () => Navigator.pop(context, (
                    at: at,
                    location: widget.askLocation && _location.text.trim().isNotEmpty ? _location.text.trim() : null,
                    note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                  )),
          child: Text(l10n.send),
        ),
      ],
    );
  }
}
