/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/config/env.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/export/table_export.dart';
import '../../../../core/locale/l10n_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/isometric_bars.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/audit.dart';
import '../providers/audit_providers.dart';

/// Dịch vụ có ghi sổ kiểm toán
const auditServices = ['hr', 'attendance', 'recruitment', 'payroll', 'finance', 'project_contract', 'notification', 'integration'];

/// Sổ kiểm toán (R54, R88–R90): lọc theo khu vực, dịch vụ, loại, bất thường, ngày giờ;
/// biểu đồ 2D/3D; xuất Excel, PDF, CSV, JSON và bản CSV có mã SHA-256
class AuditPage extends ConsumerStatefulWidget {
  const AuditPage({super.key});

  @override
  ConsumerState<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends ConsumerState<AuditPage> {
  AuditQuery _query = emptyAuditQuery;
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() => _run(() async {
        final check = await ref.read(auditRepositoryProvider).verify();
        ref.invalidate(auditAccessLogProvider);
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            icon: Icon(
              check.intact ? Icons.verified_outlined : Icons.gpp_bad_outlined,
              color: check.intact ? context.tbt.success : context.tbt.danger,
              size: 40,
            ),
            title: Text(check.intact ? l10n.chainIntact : l10n.chainBroken('${check.brokenAt}')),
            content: Text(l10n.chainChecked(check.checked)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close))],
          ),
        );
      });

  Future<void> _signedExport() => _run(() async {
        final export = await ref.read(auditRepositoryProvider).export(_query);
        ref.invalidate(auditAccessLogProvider);
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.exportDone(export.rowCount)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.exportChecksumHint),
                const SizedBox(height: 12),
                SelectableText(export.checksum, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Clipboard.setData(ClipboardData(text: export.checksum)),
                child: Text(l10n.copyChecksum),
              ),
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
            ],
          ),
        );
      });

  ExportTable? _table() {
    final events = ref.read(auditEventsProvider(_query)).value;
    if (events == null) return null;
    final l10n = AppLocalizations.of(context);
    return ExportTable(
      title: l10n.auditLog,
      subtitle: _describe(l10n, _query),
      headers: ['ID', l10n.filterRegion, l10n.auditService, l10n.auditEventType, 'Aggregate', l10n.auditTime, l10n.anomalyAny, 'SHA-256'],
      rows: [
        for (final e in events)
          [e.id, l10n.regionName(e.region), e.sourceService, e.eventType, e.aggregateId, DateFormat('yyyy-MM-dd HH:mm:ss').format(e.occurredAt), e.anomalies.map((a) => _anomalyName(l10n, a)).join(', '), e.hash],
      ],
    );
  }

  Future<void> _openFilter() async {
    final picked = await showModalBottomSheet<AuditQuery>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(initial: _query),
    );
    if (picked != null) setState(() => _query = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roles = ref.watch(authControllerProvider).value?.roles ?? const <String>[];
    final seesAccessLog = roles.any(accessLogRoles.contains);
    final filtered = _query != emptyAuditQuery;

    final filters = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final region in [null, ...Env.regions])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(region == null ? l10n.allRegions : l10n.regionName(region)),
                    selected: _query.region == region,
                    onSelected: (_) => setState(() => _query = _with(_query, region: region)),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final anomaly in [null, 'any', 'after_hours', 'failure'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: anomaly == null ? null : Icon(Icons.warning_amber_rounded, size: 16, color: context.tbt.caution),
                    label: Text(anomaly == null ? l10n.filterAll : _anomalyName(l10n, anomaly)),
                    selected: _query.anomaly == anomaly,
                    onSelected: (_) => setState(() => _query = _with(_query, anomaly: anomaly)),
                  ),
                ),
              ActionChip(avatar: const Icon(Icons.tune, size: 16), label: Text(l10n.auditFilter), onPressed: _openFilter),
            ],
          ),
        ),
        if (filtered)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
            child: Row(children: [
              Expanded(child: Text(_describe(l10n, _query), style: TextStyle(color: context.tbt.textSecondary, fontSize: 12))),
              TextButton(onPressed: () => setState(() => _query = emptyAuditQuery), child: Text(l10n.clearFilters)),
            ]),
          ),
      ],
    );

    return DefaultTabController(
      length: seesAccessLog ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.auditLog),
          actions: [
            IconButton(tooltip: l10n.verifyChain, icon: const Icon(Icons.verified_outlined), onPressed: _busy ? null : _verify),
            IconButton(tooltip: l10n.auditSignedExport, icon: const Icon(Icons.download_outlined), onPressed: _busy ? null : _signedExport),
            ExportMenuButton(table: _table, formats: const {ExportFormat.excel, ExportFormat.pdf, ExportFormat.csv, ExportFormat.json}),
          ],
          bottom: TabBar(tabs: [
            Tab(text: l10n.auditEvents),
            Tab(text: l10n.auditCharts),
            if (seesAccessLog) Tab(text: l10n.accessLog),
          ]),
        ),
        body: TabBarView(children: [
          Column(children: [filters, Expanded(child: _EventsList(query: _query))]),
          Column(children: [filters, Expanded(child: _AuditCharts(query: _query))]),
          if (seesAccessLog) const _AccessLogList(),
        ]),
      ),
    );
  }
}

AuditQuery _with(AuditQuery q, {Object? region = _keep, Object? anomaly = _keep}) => (
      region: region == _keep ? q.region : region as String?,
      type: q.type,
      service: q.service,
      anomaly: anomaly == _keep ? q.anomaly : anomaly as String?,
      from: q.from,
      to: q.to,
    );

const _keep = Object();

String _anomalyName(AppLocalizations l10n, String anomaly) => switch (anomaly) {
      'after_hours' => l10n.anomalyAfterHours,
      'failure' => l10n.anomalyFailure,
      _ => l10n.anomalyAny,
    };

String _formatTime(DateTime t) => DateFormat(t.hour == 0 && t.minute == 0 ? 'yyyy-MM-dd' : 'yyyy-MM-dd HH:mm').format(t);

String _describe(AppLocalizations l10n, AuditQuery q) => [
      if (q.region != null) l10n.regionName(q.region!),
      if (q.service != null) '${l10n.auditService}: ${q.service}',
      if (q.type != null) '${l10n.auditEventType}: ${q.type}',
      if (q.anomaly != null) _anomalyName(l10n, q.anomaly!),
      if (q.from != null) '${l10n.auditFromTime} ${_formatTime(q.from!)}',
      if (q.to != null) '${l10n.auditToTime} ${_formatTime(q.to!)}',
    ].join(' · ');

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});

  final AuditQuery initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _service = widget.initial.service;
  late final _type = TextEditingController(text: widget.initial.type ?? '');
  late DateTime? _from = widget.initial.from;
  late DateTime? _to = widget.initial.to;

  @override
  void dispose() {
    _type.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime? current) async {
    final now = DateTime.now();
    final day = await showDatePicker(context: context, initialDate: current ?? now, firstDate: DateTime(2020), lastDate: now.add(const Duration(days: 1)));
    if (day == null || !mounted) return null;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(current ?? DateTime(day.year, day.month, day.day)));
    return DateTime(day.year, day.month, day.day, time?.hour ?? 0, time?.minute ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.auditFilter, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _service,
            decoration: InputDecoration(labelText: l10n.auditService),
            items: [
              DropdownMenuItem(child: Text(l10n.filterAll)),
              for (final s in auditServices) DropdownMenuItem(value: s, child: Text(s)),
            ],
            onChanged: (v) => setState(() => _service = v),
          ),
          const SizedBox(height: 8),
          TextField(controller: _type, decoration: InputDecoration(labelText: l10n.auditEventType, hintText: 'PayrollRunCompleted')),
          const SizedBox(height: 8),
          for (final (label, value, set) in [
            (l10n.auditFromTime, _from, (DateTime? v) => _from = v),
            (l10n.auditToTime, _to, (DateTime? v) => _to = v),
          ])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(label),
              subtitle: Text(value == null ? l10n.anyTime : _formatTime(value)),
              trailing: value == null ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => set(null))),
              onTap: () async {
                final picked = await _pick(value);
                if (picked != null) setState(() => set(picked));
              },
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => Navigator.pop(context, (
              region: widget.initial.region,
              type: _type.text.trim().isEmpty ? null : _type.text.trim(),
              service: _service,
              anomaly: widget.initial.anomaly,
              from: _from,
              to: _to,
            )),
            child: Text(l10n.apply),
          ),
        ],
      ),
    );
  }
}

class _EventsList extends ConsumerWidget {
  const _EventsList({required this.query});

  final AuditQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final events = ref.watch(auditEventsProvider(query));
    return switch (events) {
      AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noReportData),
      AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: () => ref.refresh(auditEventsProvider(query).future),
          child: ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, i) {
              final e = value[i];
              return ListTile(
                leading: Text('#${e.id}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                title: Text(e.eventType),
                subtitle: Text(
                  '${l10n.regionName(e.region)} · ${e.sourceService} · ${DateFormat.yMMMd(locale).add_Hm().format(e.occurredAt)}\n'
                  'hash ${e.hash.substring(0, 16)}…',
                  style: TextStyle(color: context.tbt.textSecondary),
                ),
                trailing: e.anomalies.isEmpty
                    ? null
                    : Tooltip(
                        message: e.anomalies.map((a) => _anomalyName(l10n, a)).join(', '),
                        child: Icon(e.anomalies.contains('failure') ? Icons.error_outline : Icons.nightlight_outlined, color: e.anomalies.contains('failure') ? context.tbt.danger : context.tbt.caution),
                      ),
                isThreeLine: true,
              );
            },
          ),
        ),
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(auditEventsProvider(query))),
      _ => const SkeletonList(),
    };
  }
}

class _AuditCharts extends ConsumerStatefulWidget {
  const _AuditCharts({required this.query});

  final AuditQuery query;

  @override
  ConsumerState<_AuditCharts> createState() => _AuditChartsState();
}

class _AuditChartsState extends ConsumerState<_AuditCharts> {
  bool _threeD = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(auditStatsProvider(widget.query));
    return switch (stats) {
      AsyncValue(:final value?) when value.total == 0 => EmptyView(message: l10n.noReportData),
      AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: () => ref.refresh(auditStatsProvider(widget.query).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              FadeSlideIn(
                child: Row(children: [
                  _Tile(label: l10n.auditTotal, value: value.total, color: Theme.of(context).colorScheme.primary),
                  _Tile(label: l10n.anomalyAfterHours, value: value.afterHours, color: context.tbt.caution),
                  _Tile(label: l10n.anomalyFailure, value: value.failures, color: context.tbt.danger),
                ]),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SegmentedButton<bool>(
                  segments: [ButtonSegment(value: false, label: Text(l10n.chart2d)), ButtonSegment(value: true, label: Text(l10n.chart3d))],
                  selected: {_threeD},
                  onSelectionChanged: (v) => setState(() => _threeD = v.first),
                ),
              ),
              _ChartCard(
                title: l10n.auditByRegion,
                child: _CountBars(counts: [for (final c in value.byRegion) (key: c.key.toUpperCase(), count: c.count)], threeD: _threeD, color: Theme.of(context).colorScheme.primary),
              ),
              _ChartCard(title: l10n.auditByService, child: _CountBars(counts: value.byService, threeD: _threeD, color: context.tbt.info)),
              _ChartCard(title: l10n.auditByHour, child: _HourBars(hours: value.byLocalHour)),
              if (value.byDay.length > 1) _ChartCard(title: l10n.auditByDay, child: _DayLine(days: value.byDay)),
              _ChartCard(title: l10n.auditByType, height: null, child: _TypeList(types: value.byType)),
            ],
          ),
        ),
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(auditStatsProvider(widget.query))),
      _ => const SkeletonList(),
    };
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(NumberFormat.decimalPattern().format(value), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
                Text(label, maxLines: 2, style: TextStyle(fontSize: 11, color: context.tbt.textSecondary)),
              ],
            ),
          ),
        ),
      );
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child, this.height = 200});

  final String title;
  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(top: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (height == null) child else SizedBox(height: height, child: child),
            ],
          ),
        ),
      );
}

FlTitlesData _titles(BuildContext context, String Function(int i) label) {
  final style = TextStyle(fontSize: 10, color: context.tbt.textSecondary);
  return FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, _) => Text(NumberFormat.compact().format(v), style: style))),
    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, interval: 1, getTitlesWidget: (v, _) => Text(label(v.toInt()), style: style))),
  );
}

class _CountBars extends StatelessWidget {
  const _CountBars({required this.counts, required this.threeD, required this.color});

  final List<AuditCount> counts;
  final bool threeD;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (threeD) {
      return CustomPaint(
        size: Size.infinite,
        painter: IsometricBarsPainter(
          labels: [for (final c in counts) c.key],
          values: [for (final c in counts) c.count.toDouble()],
          colors: [for (final _ in counts) color],
          grid: context.tbt.glassBorder,
          text: context.tbt.textSecondary,
        ),
      );
    }
    return BarChart(BarChartData(
      gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: context.tbt.glassBorder, strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      titlesData: _titles(context, (i) => i < counts.length ? counts[i].key : ''),
      barGroups: [
        for (final (i, c) in counts.indexed)
          BarChartGroupData(x: i, barRods: [BarChartRodData(toY: c.count.toDouble(), width: 18, color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))]),
      ],
    ));
  }
}

class _HourBars extends StatelessWidget {
  const _HourBars({required this.hours});

  final List<int> hours;

  @override
  Widget build(BuildContext context) => BarChart(BarChartData(
        gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: context.tbt.glassBorder, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        titlesData: _titles(context, (i) => i % 3 == 0 ? '${i}h' : ''),
        barGroups: [
          for (final (h, n) in hours.indexed)
            BarChartGroupData(x: h, barRods: [
              BarChartRodData(toY: n.toDouble(), width: 7, color: h < 6 || h >= 22 ? context.tbt.danger : context.tbt.info, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
            ]),
        ],
      ));
}

class _DayLine extends StatelessWidget {
  const _DayLine({required this.days});

  final List<AuditCount> days;

  @override
  Widget build(BuildContext context) {
    final step = (days.length / 5).ceil();
    return LineChart(LineChartData(
      gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: context.tbt.glassBorder, strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      titlesData: _titles(context, (i) => i < days.length && i % step == 0 ? days[i].key.substring(5) : ''),
      lineBarsData: [
        LineChartBarData(
          spots: [for (final (i, d) in days.indexed) FlSpot(i.toDouble(), d.count.toDouble())],
          color: Theme.of(context).colorScheme.primary,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)),
        ),
      ],
    ));
  }
}

class _TypeList extends StatelessWidget {
  const _TypeList({required this.types});

  final List<AuditCount> types;

  @override
  Widget build(BuildContext context) {
    final top = types.fold<int>(1, (m, t) => t.count > m ? t.count : m);
    return Column(
      children: [
        for (final t in types)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Expanded(child: Text(t.key, style: const TextStyle(fontSize: 12))), Text('${t.count}', style: const TextStyle(fontSize: 12))]),
                const SizedBox(height: 2),
                LinearProgressIndicator(value: t.count / top, minHeight: 6, borderRadius: BorderRadius.circular(3)),
              ],
            ),
          ),
      ],
    );
  }
}

class _AccessLogList extends ConsumerWidget {
  const _AccessLogList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final log = ref.watch(auditAccessLogProvider);
    return switch (log) {
      AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noReportData),
      AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: () => ref.refresh(auditAccessLogProvider.future),
          child: ListView(
            children: [
              for (final a in value)
                ListTile(
                  leading: Icon(switch (a.action) {
                    'export' => Icons.download_outlined,
                    'verify' => Icons.verified_outlined,
                    'stats' => Icons.bar_chart,
                    _ => Icons.search,
                  }),
                  title: Text('${a.username} · ${_actionName(l10n, a.action)}'),
                  subtitle: Text(
                    [
                      DateFormat.yMMMd(locale).add_Hm().format(a.accessedAt),
                      if (a.rowCount != null) l10n.rowsCount(a.rowCount!),
                      if (a.checksum case final c?) 'SHA-256 ${c.substring(0, 16)}…',
                    ].join(' · '),
                    style: TextStyle(color: context.tbt.textSecondary),
                  ),
                ),
            ],
          ),
        ),
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(auditAccessLogProvider)),
      _ => const SkeletonList(),
    };
  }

  static String _actionName(AppLocalizations l10n, String action) => switch (action) {
        'export' => l10n.exportAudit,
        'verify' => l10n.verifyChain,
        'stats' => l10n.auditCharts,
        _ => l10n.auditSearch,
      };
}
