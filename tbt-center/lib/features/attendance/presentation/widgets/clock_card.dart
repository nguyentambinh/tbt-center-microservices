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
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/work_time.dart';
import '../providers/attendance_providers.dart';

/// Thẻ chấm công hôm nay (R31–R33): một nút duy nhất, server tự biết là vào ca
/// hay ra ca; không có ca thì báo rõ và không cho bấm.
class ClockCard extends ConsumerStatefulWidget {
  const ClockCard({super.key});

  @override
  ConsumerState<ClockCard> createState() => _ClockCardState();
}

class _ClockCardState extends ConsumerState<ClockCard> {
  bool _sending = false;

  Future<void> _clock() async {
    final l10n = AppLocalizations.of(context);
    final hours = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    setState(() => _sending = true);
    try {
      final punch = await ref.read(workTimeRepositoryProvider).clock();
      ref
        ..invalidate(clockTodayProvider)
        ..invalidate(timesheetProvider);
      if (!mounted) return;
      final message = punch.checkedIn
          ? l10n.clockedIn(punch.time)
          : l10n.clockedOut(punch.time, hours.format(punch.totalHours ?? 0));
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
    } on Object catch (e) {
      reportFailure(e);
      // Server báo không có ca hay đã ra ca: tải lại để thẻ hiện đúng tình trạng.
      if (e is AppFailure && !e.isConnectionProblem) ref.invalidate(clockTodayProvider);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final text = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final today = ref.watch(clockTodayProvider);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (today) {
          AsyncValue(:final value?) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.clockToday, style: text.titleLarge),
                Text(
                  DateFormat.yMMMMEEEEd(locale).format(value.workDate),
                  style: TextStyle(color: context.tbt.textSecondary),
                ),
                const SizedBox(height: 8),
                if (!value.hasShift)
                  Text(l10n.noShiftToday)
                else ...[
                  Text([
                    if (value.shiftStart != null && value.shiftEnd != null) l10n.shiftHours(value.shiftStart!, value.shiftEnd!),
                    value.shiftNote,
                    _dayKind(l10n, value),
                  ].nonNulls.join(' · ')),
                  const SizedBox(height: 8),
                  Text(l10n.checkInOut(value.checkIn ?? '--:--', value.checkOut ?? '--:--'), style: text.titleMedium),
                  if (value.done)
                    Text(
                      l10n.totalHoursToday(NumberFormat.decimalPattern(locale).format(value.totalHours ?? 0)),
                      style: TextStyle(color: accent),
                    )
                  else if (_overtimeNote(l10n, locale, value) case final note?) ...[
                    const SizedBox(height: 4),
                    Text(note, style: TextStyle(color: context.tbt.textSecondary)),
                  ],
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: Icon(value.checkIn == null ? Icons.login : Icons.logout),
                    label: _sending
                        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(switch (value) {
                            ClockToday(done: true) => l10n.shiftDone,
                            ClockToday(checkIn: null) => l10n.clockIn,
                            _ => l10n.clockOut,
                          }),
                    onPressed: _sending || !value.hasShift || value.done ? null : _clock,
                  ),
                ),
              ],
            ),
          AsyncValue(:final error?) => Row(
              children: [
                Expanded(child: Text(error is AppFailure ? error.message(l10n) : l10n.errorUnknown)),
                TextButton(onPressed: () => ref.invalidate(clockTodayProvider), child: Text(l10n.retry)),
              ],
            ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  /// Tăng ca chỉ tính theo đơn đã duyệt: báo trước để nhân viên biết làm thêm có được tính không
  String? _overtimeNote(AppLocalizations l10n, String locale, ClockToday day) {
    final hours = NumberFormat.decimalPattern(locale);
    if (day.approvedOvertime > 0) {
      final end = day.shiftEnd?.split(':');
      final until = end == null
          ? null
          : DateTime(2000, 1, 1, int.parse(end[0]), int.parse(end[1])).add(Duration(minutes: (day.approvedOvertime * 60).round()));
      return l10n.overtimeApprovedToday(hours.format(day.approvedOvertime), until == null ? '--:--' : DateFormat.Hm().format(until));
    }
    if (day.pendingOvertime > 0) return l10n.overtimePendingToday(hours.format(day.pendingOvertime));
    return day.checkIn == null ? null : l10n.overtimeNoneToday;
  }

  /// Ngày lễ, chủ nhật kèm hệ số lương để nhân viên biết công được tính thế nào (R34).
  String? _dayKind(AppLocalizations l10n, ClockToday day) {
    final coefficient = day.coefficient;
    if (!day.isHoliday && !day.isSunday && (coefficient == null || coefficient == 1)) return null;
    final kind = day.isHoliday ? l10n.holidayShift : (day.isSunday ? l10n.sundayShift : null);
    return [kind, if (coefficient != null) '×${NumberFormat.decimalPattern().format(coefficient)}'].nonNulls.join(' ');
  }
}
