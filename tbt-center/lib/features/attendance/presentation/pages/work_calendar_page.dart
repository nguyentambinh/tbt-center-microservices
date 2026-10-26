/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../payroll/presentation/providers/payroll_providers.dart';
import '../../../project_contract/presentation/providers/project_providers.dart';
import '../../domain/entities/work_calendar.dart';
import '../providers/attendance_providers.dart';

/// Màu từng loại ngày trên lịch
Color dayColor(BuildContext context, CalendarDay day, DateTime today) {
  if (day.worked) return context.tbt.success;
  if (day.onLeave) return context.tbt.info;
  if (day.holiday != null) return context.tbt.brandGold;
  if (day.absent(today)) return context.tbt.danger;
  return context.tbt.textSecondary;
}

/// Lịch làm việc theo tháng: bấm một ngày xem chi tiết từng giờ, dự án, tiền ước tính
class WorkCalendarPage extends ConsumerStatefulWidget {
  const WorkCalendarPage({super.key});

  @override
  ConsumerState<WorkCalendarPage> createState() => _WorkCalendarPageState();
}

class _WorkCalendarPageState extends ConsumerState<WorkCalendarPage> {
  late DateTime _month = DateTime(ref.read(regionTodayProvider).year, ref.read(regionTodayProvider).month);

  void _shift(int months) => setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final days = ref.watch(calendarProvider(_month));
    final salary = ref.watch(myPayrollProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.workCalendar)),
      body: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _shift(-1)),
              Expanded(
                child: Text(
                  toBeginningOfSentenceCase(DateFormat.yMMMM(locale).format(_month), locale),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _shift(1)),
            ],
          ),
          Expanded(
            child: switch (days) {
              AsyncValue(:final value?) => ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  children: [
                    _MonthGrid(month: _month, today: ref.watch(regionTodayProvider), days: value, onTap: (d) => _openDay(context, d)),
                    const SizedBox(height: 12),
                    const _Legend(),
                    const SizedBox(height: 12),
                    _MonthSummary(days: value, baseSalary: salary?.baseSalary, currency: salary?.currency),
                  ],
                ),
              AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(calendarProvider(_month))),
              _ => const SkeletonList(),
            },
          ),
        ],
      ),
    );
  }

  void _openDay(BuildContext context, CalendarDay day) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _DaySheet(day: day),
      );
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.today, required this.days, required this.onTap});

  final DateTime today;

  final DateTime month;
  final List<CalendarDay> days;
  final ValueChanged<CalendarDay> onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    // Tuần bắt đầu từ thứ Hai
    final lead = DateTime(month.year, month.month).weekday - 1;
    final weekdays = [for (var i = 0; i < 7; i++) DateFormat.E(locale).format(DateTime(2024, 1, 1 + i))];
    return Column(
      children: [
        Row(children: [for (final w in weekdays) Expanded(child: Center(child: Text(w, style: TextStyle(color: context.tbt.textSecondary, fontSize: 12))))]),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: [
            for (var i = 0; i < lead; i++) const SizedBox.shrink(),
            for (final d in days)
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onTap(d),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: d.worked ? context.tbt.success.withValues(alpha: 0.15) : null,
                    border: Border.all(
                      color: DateUtils.isSameDay(d.date, today) ? Theme.of(context).colorScheme.primary : context.tbt.glassBorder,
                      width: DateUtils.isSameDay(d.date, today) ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${d.date.day}', style: TextStyle(fontWeight: FontWeight.bold, color: d.isSunday || d.holiday != null ? context.tbt.danger : null)),
                      const SizedBox(height: 2),
                      if (d.hasShift || d.onLeave || d.holiday != null)
                        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: dayColor(context, d, today))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget item(Color color, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: context.tbt.textSecondary)),
          ],
        );
    return Wrap(spacing: 12, runSpacing: 6, children: [
      item(context.tbt.success, l10n.calWorked),
      item(context.tbt.info, l10n.calLeave),
      item(context.tbt.brandGold, l10n.calHoliday),
      item(context.tbt.danger, l10n.calAbsent),
      item(context.tbt.textSecondary, l10n.calScheduled),
    ]);
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({required this.days, this.baseSalary, this.currency});

  final List<CalendarDay> days;
  final double? baseSalary;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final worked = days.where((d) => d.worked).toList();
    final hours = worked.fold<double>(0, (s, d) => s + d.totalHours);
    final pay = baseSalary == null ? null : worked.fold<double>(0, (s, d) => s + estimatedDayPay(d, baseSalary!));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.totalHours(NumberFormat.decimalPattern(locale).format(hours), worked.length), style: const TextStyle(fontWeight: FontWeight.bold)),
            if (pay != null) ...[
              const SizedBox(height: 4),
              Text(l10n.estimatedMonthPay(NumberFormat.simpleCurrency(locale: locale, name: currency).format(pay))),
              Text(l10n.payEstimateHint, style: TextStyle(color: context.tbt.textSecondary, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}

class _DaySheet extends ConsumerWidget {
  const _DaySheet({required this.day});

  final CalendarDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final number = NumberFormat.decimalPattern(locale);
    final salary = ref.watch(myPayrollProvider).value;
    final projects = ref.watch(myProjectsProvider).value ?? const [];
    final active = [
      for (final p in projects)
        if ((p.startDate == null || !p.startDate!.isAfter(day.date)) && (p.endDate == null || !p.endDate!.isBefore(day.date))) p,
    ];
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(toBeginningOfSentenceCase(DateFormat.yMMMMEEEEd(locale).format(day.date), locale), style: text.titleLarge),
          if (day.holiday != null) Text(day.holiday!, style: TextStyle(color: context.tbt.brandGold)),
          if (day.onLeave) Text(l10n.calLeaveOfType(day.leaveType!), style: TextStyle(color: context.tbt.info)),
          const SizedBox(height: 12),
          if (day.hasShift) ...[
            Text([l10n.shiftHours(day.shiftStart!, day.shiftEnd!), if (day.coefficient != 1) '×${number.format(day.coefficient)}', day.note].nonNulls.join(' · ')),
            const SizedBox(height: 8),
            DayTimeline(day: day),
            const SizedBox(height: 8),
          ] else
            Text(l10n.noShiftThisDay, style: TextStyle(color: context.tbt.textSecondary)),
          if (day.worked) ...[
            Text(l10n.checkInOut(day.checkIn ?? '--:--', day.checkOut ?? '--:--'), style: text.titleMedium),
            Text([
              '${number.format(day.workHours)} h',
              if (day.overtimeHours > 0) l10n.overtimeHours(number.format(day.overtimeHours)),
            ].join(' · ')),
            if (salary?.baseSalary case final base?)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.estimatedDayPay(NumberFormat.simpleCurrency(locale: locale, name: salary!.currency).format(estimatedDayPay(day, base))),
                  style: TextStyle(color: context.tbt.success, fontWeight: FontWeight.bold),
                ),
              ),
          ],
          if (active.isNotEmpty) ...[
            const Divider(height: 24),
            Text(l10n.projectsThisDay, style: text.titleSmall),
            for (final p in active) ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.apartment_outlined), title: Text(p.name ?? p.projectId)),
          ],
        ],
      ),
    );
  }
}

/// Dải 24 giờ: khung ca (nền mờ), đoạn đã làm (màu đậm)
class DayTimeline extends StatelessWidget {
  const DayTimeline({super.key, required this.day});

  final CalendarDay day;

  static double _hour(String? hhmm) {
    if (hhmm == null) return 0;
    final parts = hhmm.split(':');
    return int.parse(parts[0]) + int.parse(parts[1]) / 60;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        double x(String? t) => _hour(t) / 24 * w;
        return Column(
          children: [
            SizedBox(
              height: 22,
              child: Stack(
                children: [
                  Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: context.tbt.glassStrong, borderRadius: BorderRadius.circular(6)))),
                  if (day.hasShift)
                    Positioned(
                      left: x(day.shiftStart),
                      width: (x(day.shiftEnd) - x(day.shiftStart)).clamp(2, w),
                      top: 0,
                      bottom: 0,
                      child: DecoratedBox(decoration: BoxDecoration(color: context.tbt.info.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6))),
                    ),
                  if (day.checkIn != null)
                    Positioned(
                      left: x(day.checkIn),
                      width: ((day.checkOut == null ? x(day.checkIn) + 3 : x(day.checkOut)) - x(day.checkIn)).clamp(3, w),
                      top: 5,
                      bottom: 5,
                      child: DecoratedBox(decoration: BoxDecoration(color: context.tbt.success, borderRadius: BorderRadius.circular(4))),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [for (final h in [0, 6, 12, 18, 24]) Text('$h:00', style: TextStyle(fontSize: 10, color: context.tbt.textSecondary))],
            ),
          ],
        );
      },
    );
  }
}
