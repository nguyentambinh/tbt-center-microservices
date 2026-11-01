/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-11-01
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/input_rules.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../organization/presentation/widgets/org_actions.dart' show showDone;
import '../../../project_contract/domain/entities/project.dart';
import '../../../project_contract/presentation/providers/project_providers.dart';
import '../../data/schedule_manage_repository.dart';
import '../providers/attendance_providers.dart';

/// Dự án chưa nghiệm thu, HR chọn để lấy danh sách thành viên
final _openProjectsProvider = FutureProvider.autoDispose<List<ProjectSummary>>((ref) async {
  final projects = await ref.watch(projectRepositoryProvider).projects();
  return [for (final p in projects) if (!p.accepted) p];
});

String _hm(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// HR đặt lịch: chọn khoảng ngày, dự án, thành viên rồi giờ vào, giờ ra, ca
class ScheduleManagePage extends ConsumerStatefulWidget {
  const ScheduleManagePage({super.key});

  @override
  ConsumerState<ScheduleManagePage> createState() => _ScheduleManagePageState();
}

class _ScheduleManagePageState extends ConsumerState<ScheduleManagePage> {
  final _note = TextEditingController();
  final _weekdays = {1, 2, 3, 4, 5, 6};
  final _selected = <String>{};
  DateTimeRange? _range;
  String? _projectId;
  TimeOfDay _start = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 17, minute: 0);
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _ready => _range != null && _selected.isNotEmpty && !_saving;

  Future<void> _pickRange() async {
    final today = ref.read(regionTodayProvider);
    final range = await showDateRangePicker(context: context, firstDate: today, lastDate: today.add(const Duration(days: 92)), initialDateRange: _range);
    if (range != null) setState(() => _range = range);
  }

  Future<void> _pickTime(bool start) async {
    final time = await showTimePicker(context: context, initialTime: start ? _start : _end);
    if (time != null) setState(() => start ? _start = time : _end = time);
  }

  Future<void> _run(Future<int> Function(ScheduleManageRepository repository) action) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      showDone(l10n.scheduleSaved(await action(ref.read(scheduleManageRepositoryProvider))));
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() => _run((r) => r.save(
        employeeIds: _selected.toList(),
        from: _range!.start,
        to: _range!.end,
        weekdays: _weekdays,
        start: _hm(_start),
        end: _hm(_end),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      ));

  Future<void> _clear() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.scheduleClearConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.scheduleClear)),
        ],
      ),
    );
    if (ok == true) await _run((r) => r.clear(employeeIds: _selected.toList(), from: _range!.start, to: _range!.end));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.yMd(locale);
    final projects = ref.watch(_openProjectsProvider);
    final range = _range;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scheduleManage)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.date_range_outlined),
                title: Text(l10n.scheduleRange),
                subtitle: Text(range == null ? l10n.schedulePickRange : '${date.format(range.start)} – ${date.format(range.end)}'),
                onTap: _pickRange,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Wrap(spacing: 6, runSpacing: 6, children: [
                  for (var d = 1; d <= 7; d++)
                    FilterChip(
                      label: Text(DateFormat.E(locale).format(DateTime(2024, 1, d))),
                      selected: _weekdays.contains(d),
                      onSelected: (on) => setState(() => on ? _weekdays.add(d) : _weekdays.remove(d)),
                    ),
                ]),
              ),
            ]),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => _pickTime(true), icon: const Icon(Icons.login), label: Text(_hm(_start)))),
                  const SizedBox(width: 12),
                  Expanded(child: OutlinedButton.icon(onPressed: () => _pickTime(false), icon: const Icon(Icons.logout), label: Text(_hm(_end)))),
                ]),
                const SizedBox(height: 12),
                TextField(controller: _note, inputFormatters: InputRules.shortText, decoration: InputDecoration(labelText: l10n.scheduleShiftName, isDense: true)),
              ]),
            ),
          ),
          const SizedBox(height: 4),
          switch (projects) {
            AsyncValue(:final value?) => DropdownButtonFormField<String>(
                initialValue: _projectId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.scheduleProject),
                items: [for (final p in value) DropdownMenuItem(value: p.id, child: Text(p.name ?? p.id, overflow: TextOverflow.ellipsis))],
                onChanged: (id) => setState(() {
                  _projectId = id;
                  _selected.clear();
                }),
              ),
            AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(_openProjectsProvider)),
            _ => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
          },
          if (_projectId case final id?) _Members(projectId: id, selected: _selected, range: range, onChanged: () => setState(() {})),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _ready && _weekdays.isNotEmpty ? _save : null,
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.scheduleSave),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _ready ? _clear : null,
            icon: Icon(Icons.event_busy_outlined, color: _ready ? context.tbt.danger : null),
            label: Text(l10n.scheduleClear, style: TextStyle(color: _ready ? context.tbt.danger : null)),
          ),
        ],
      ),
    );
  }
}

class _Members extends ConsumerWidget {
  const _Members({required this.projectId, required this.selected, required this.range, required this.onChanged});

  final String projectId;
  final Set<String> selected;
  final DateTimeRange? range;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(projectDetailProvider(projectId));
    return switch (detail) {
      AsyncValue(:final value?) => _list(context, l10n, [for (final m in value.members) if (m.employeeId != null) m]),
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(projectDetailProvider(projectId))),
      _ => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
    };
  }

  Widget _list(BuildContext context, AppLocalizations l10n, List<ProjectMember> members) {
    final ids = {for (final m in members) m.employeeId!};
    final all = ids.isNotEmpty && selected.containsAll(ids);
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Column(children: [
        CheckboxListTile(
          title: Text(l10n.scheduleAllMembers(members.length), style: const TextStyle(fontWeight: FontWeight.bold)),
          value: all,
          onChanged: (on) {
            on == true ? selected.addAll(ids) : selected.removeAll(ids);
            onChanged();
          },
        ),
        for (final m in members)
          CheckboxListTile(
            title: Text(m.name ?? m.employeeId!, overflow: TextOverflow.ellipsis),
            subtitle: Text(m.employeeId!),
            value: selected.contains(m.employeeId),
            secondary: IconButton(
              tooltip: l10n.scheduleViewDays,
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: range == null ? null : () => showModalBottomSheet<void>(context: context, showDragHandle: true, isScrollControlled: true, builder: (_) => _MemberDays(member: m, range: range!)),
            ),
            onChanged: (on) {
              on == true ? selected.add(m.employeeId!) : selected.remove(m.employeeId);
              onChanged();
            },
          ),
      ]),
    );
  }
}

/// Lịch từng ngày của một người trong khoảng đã chọn, chạm một ngày để đổi giờ
class _MemberDays extends ConsumerStatefulWidget {
  const _MemberDays({required this.member, required this.range});

  final ProjectMember member;
  final DateTimeRange range;

  @override
  ConsumerState<_MemberDays> createState() => _MemberDaysState();
}

class _MemberDaysState extends ConsumerState<_MemberDays> {
  late Future<List<ScheduledDay>> _days = _load();

  Future<List<ScheduledDay>> _load() => ref.read(scheduleManageRepositoryProvider).days(widget.member.employeeId!, widget.range.start, widget.range.end);

  Future<void> _edit(ScheduledDay day) async {
    final l10n = AppLocalizations.of(context);
    TimeOfDay parse(String? v, int hour) => v == null ? TimeOfDay(hour: hour, minute: 0) : TimeOfDay(hour: int.parse(v.substring(0, 2)), minute: int.parse(v.substring(3, 5)));
    final start = await showTimePicker(context: context, initialTime: parse(day.start, 8), helpText: l10n.adminShiftStart);
    if (start == null || !mounted) return;
    final end = await showTimePicker(context: context, initialTime: parse(day.end, 17), helpText: l10n.adminShiftEnd);
    if (end == null) return;
    try {
      await ref.read(scheduleManageRepositoryProvider).save(employeeIds: [widget.member.employeeId!], from: day.date, to: day.date, weekdays: {day.date.weekday}, start: _hm(start), end: _hm(end));
      if (mounted) setState(() => _days = _load());
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = DateFormat.MMMEd(Localizations.localeOf(context).toString());
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scroll) => FutureBuilder<List<ScheduledDay>>(
        future: _days,
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorView(error: snapshot.error!, onRetry: () => setState(() => _days = _load()));
          final days = snapshot.data;
          if (days == null) return const Center(child: CircularProgressIndicator());
          return ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text(widget.member.name ?? widget.member.employeeId!, style: Theme.of(context).textTheme.titleLarge),
              for (final day in days)
                ListTile(
                  title: Text(format.format(day.date)),
                  subtitle: Text(day.start == null ? l10n.scheduleNoShift : [ '${day.start} – ${day.end}', ?day.note].join(' · ')),
                  trailing: day.clockedIn ? const Icon(Icons.check_circle_outline) : const Icon(Icons.edit_outlined),
                  onTap: day.clockedIn ? null : () => _edit(day),
                ),
            ],
          );
        },
      ),
    );
  }
}
