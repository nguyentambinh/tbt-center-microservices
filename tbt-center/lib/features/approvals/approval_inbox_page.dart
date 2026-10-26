/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/config/env.dart';
import '../../core/error/error_reporter.dart';
import '../../core/export/table_export.dart';
import '../../core/locale/l10n_names.dart';
import '../../core/network/api_client.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_states.dart';
import '../../core/widgets/isometric_bars.dart';
import '../../core/widgets/motion.dart';
import '../../l10n/app_localizations.dart';
import '../attendance/data/repositories/attendance_repository_impl.dart';
import '../attendance/data/repositories/work_time_repository_impl.dart';
import '../organization/presentation/providers/organization_providers.dart';
import '../payroll/presentation/providers/payroll_providers.dart';
import '../profile/data/profile_repository.dart';
import '../project_contract/presentation/providers/project_providers.dart';
import '../resignations/data/resignation_repository.dart';

/// Loại đơn trong hộp duyệt: văn phòng quản lý duyệt được mọi loại
enum ApprovalKind { project, promotion, raise, leave, overtime, profile, resignation }

/// Một đề xuất đang chờ Ban lãnh đạo
class ApprovalItem {
  const ApprovalItem({required this.kind, required this.region, required this.id, required this.title, required this.detail, required this.updatedAt});

  final ApprovalKind kind;
  final String region;

  /// Mã đơn: số với dự án, đề cử, tăng lương, sửa hồ sơ, thôi việc; UUID với đơn nghỉ, tăng ca
  final String id;
  final String title;
  final String detail;
  final DateTime? updatedAt;
}

typedef ApprovalInbox = ({List<ApprovalItem> items, List<String> unreachable});

/// Gom đề xuất chờ duyệt của mọi khu vực; khu vực không phản hồi thì ghi lại, không chặn cả hộp
final approvalInboxProvider = FutureProvider.autoDispose<ApprovalInbox>((ref) async {
  final unreachable = <String>{};
  Future<List<ApprovalItem>> safe(String region, Future<List<ApprovalItem>> Function() load) async {
    try {
      return await load();
    } on Object {
      unreachable.add(region);
      return const [];
    }
  }

  final money = NumberFormat.decimalPattern();
  final day = DateFormat('dd/MM/yyyy');
  final dio = ref.read(apiClientProvider);
  // Văn phòng một nước chỉ duyệt nước mình; văn phòng tập đoàn duyệt mọi nước
  final session = ref.read(authControllerProvider).value;
  final regions = session == null || session.isGroup ? Env.regions : [session.region];
  final loads = [
    for (final region in regions) ...[
      safe(region, () async => [
            for (final p in await ref.read(regionProjectRepositoryProvider(region)).proposals(status: 'awaiting_executive'))
              ApprovalItem(
                kind: ApprovalKind.project,
                region: region,
                id: '${p.id}',
                title: p.data.name ?? '#${p.id}',
                detail: [p.data.customerName, if (p.data.value != null) '${money.format(p.data.value)} ${p.data.currency ?? ''}'.trim()].nonNulls.join(' · '),
                updatedAt: p.updatedAt,
              ),
          ]),
      safe(region, () async => [
            for (final n in await ref.read(regionOrganizationProvider(region)).nominations(status: 'pending'))
              if (!n.toGroup || (session?.isGroup ?? false))
              ApprovalItem(kind: ApprovalKind.promotion, region: region, id: '${n.id}', title: n.employeeName, detail: '${n.proposedPosition}|${money.format(n.raisePercent)}', updatedAt: n.createdAt),
          ]),
      safe(region, () async => [
            for (final status in ['awaiting_approver', 'awaiting_hr'])
            for (final r in await ref.read(regionPayrollRepositoryProvider(region)).raiseRequests(status: status))
              ApprovalItem(
                kind: ApprovalKind.raise,
                region: region,
                id: '${r.id}',
                title: r.employeeId,
                detail: '${money.format(r.currentSalary)} → ${money.format(r.proposed)} ${r.currency}',
                updatedAt: r.updatedAt,
              ),
          ]),
      safe(region, () async => [
            for (final l in await AttendanceRepositoryImpl(dio, baseUrl: Env.kongUrl(region)).leaveRequests(pendingOnly: true))
              ApprovalItem(
                kind: ApprovalKind.leave,
                region: region,
                id: l.id,
                title: l.employeeId,
                detail: '${l.leaveType} · ${day.format(l.fromDate)} – ${day.format(l.toDate)} (${l.days})${l.reason == null ? '' : ' · ${l.reason}'}',
                updatedAt: l.fromDate,
              ),
          ]),
      safe(region, () async => [
            for (final o in await WorkTimeRepositoryImpl(dio, baseUrl: Env.kongUrl(region)).overtimeRequests(pendingOnly: true))
              ApprovalItem(
                kind: ApprovalKind.overtime,
                region: region,
                id: o.id,
                title: o.employeeId,
                detail: '${day.format(o.workDate)} · ${money.format(o.hours)} h${o.reason == null ? '' : ' · ${o.reason}'}',
                updatedAt: o.workDate,
              ),
          ]),
      safe(region, () async => [
            for (final c in await ProfileRepositoryImpl(dio, baseUrl: Env.kongUrl(region)).requests(status: 'pending'))
              ApprovalItem(kind: ApprovalKind.profile, region: region, id: '${c.id}', title: c.employeeName, detail: c.changes.keys.join(', '), updatedAt: null),
          ]),
      safe(region, () async => [
            for (final x in await ResignationRepository(dio, baseUrl: Env.kongUrl(region)).list(status: 'pending'))
              ApprovalItem(
                kind: ApprovalKind.resignation,
                region: region,
                id: '${x.id}',
                title: x.name,
                detail: '${day.format(x.lastDay)} · ${x.reason}',
                updatedAt: x.createdAt,
              ),
          ]),
    ],
  ];
  final items = [for (final list in await Future.wait(loads)) ...list]
    ..sort((a, b) => (b.updatedAt ?? DateTime(2000)).compareTo(a.updatedAt ?? DateTime(2000)));
  return (items: items, unreachable: [for (final r in Env.regions) if (unreachable.contains(r)) r]);
});

String approvalKindName(AppLocalizations l10n, ApprovalKind kind) => switch (kind) {
      ApprovalKind.project => l10n.approvalKindProject,
      ApprovalKind.promotion => l10n.approvalKindPromotion,
      ApprovalKind.raise => l10n.approvalKindRaise,
      ApprovalKind.leave => l10n.approvalKindLeave,
      ApprovalKind.overtime => l10n.approvalKindOvertime,
      ApprovalKind.profile => l10n.approvalKindProfile,
      ApprovalKind.resignation => l10n.approvalKindResignation,
    };

String _detail(AppLocalizations l10n, ApprovalItem item) {
  if (item.kind != ApprovalKind.promotion) return item.detail;
  final [position, percent] = item.detail.split('|');
  return l10n.approvalPromotionLine(position, percent);
}

/// Hộp duyệt chung của Ban lãnh đạo: lọc theo loại, khu vực; duyệt hoặc từ chối ngay; biểu đồ 2D/3D; xuất báo cáo
class ApprovalInboxPage extends ConsumerStatefulWidget {
  const ApprovalInboxPage({super.key});

  @override
  ConsumerState<ApprovalInboxPage> createState() => _ApprovalInboxPageState();
}

class _ApprovalInboxPageState extends ConsumerState<ApprovalInboxPage> {
  ApprovalKind? _kind;
  String? _region;
  bool _threeD = false;

  List<ApprovalItem> _visible(List<ApprovalItem> items) => [
        for (final i in items)
          if ((_kind == null || i.kind == _kind) && (_region == null || i.region == _region)) i,
      ];

  Future<void> _decide(ApprovalItem item, bool approve) async {
    final l10n = AppLocalizations.of(context);
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? l10n.approvalConfirm(item.title) : l10n.approvalRejectConfirm(item.title)),
        content: TextField(controller: note, maxLines: 2, decoration: InputDecoration(labelText: l10n.note)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(approve ? l10n.approve : l10n.reject)),
        ],
      ),
    );
    final text = note.text.trim().isEmpty ? null : note.text.trim();
    if (ok != true) return;
    final dio = ref.read(apiClientProvider);
    final base = Env.kongUrl(item.region);
    try {
      switch (item.kind) {
        case ApprovalKind.project:
          await ref.read(regionProjectRepositoryProvider(item.region)).respond(int.parse(item.id), action: approve ? 'approve' : 'reject', note: text);
          ref.invalidate(pendingProposalsProvider);
        case ApprovalKind.promotion:
          await ref.read(regionOrganizationProvider(item.region)).decideNomination(int.parse(item.id), approve: approve, note: text);
          ref.invalidate(pendingNominationsProvider);
        case ApprovalKind.raise:
          await ref.read(regionPayrollRepositoryProvider(item.region)).respondRaise(int.parse(item.id), action: approve ? 'approve' : 'reject', note: text);
        case ApprovalKind.leave:
          await AttendanceRepositoryImpl(dio, baseUrl: base).decide(item.id, approve: approve);
        case ApprovalKind.overtime:
          await WorkTimeRepositoryImpl(dio, baseUrl: base).decideOvertime(item.id, approve: approve);
        case ApprovalKind.profile:
          await ProfileRepositoryImpl(dio, baseUrl: base).decide(int.parse(item.id), approve: approve, note: text);
        case ApprovalKind.resignation:
          await ResignationRepository(dio, baseUrl: base).respond(int.parse(item.id), action: approve ? 'approve' : 'reject', note: text);
      }
      ref.invalidate(approvalInboxProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.approvalDone), behavior: SnackBarBehavior.floating));
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  ExportTable? _table() {
    final inbox = ref.read(approvalInboxProvider).value;
    if (inbox == null) return null;
    final l10n = AppLocalizations.of(context);
    final items = _visible(inbox.items);
    return ExportTable(
      title: l10n.approvalInbox,
      subtitle: l10n.approvalWaiting(items.length),
      headers: [l10n.approvalColKind, l10n.filterRegion, 'ID', l10n.approvalColTitle, l10n.approvalColDetail, l10n.approvalColUpdated],
      rows: [
        for (final i in items)
          [approvalKindName(l10n, i.kind), l10n.regionName(i.region), i.id, i.title, _detail(l10n, i), if (i.updatedAt case final t?) DateFormat('yyyy-MM-dd HH:mm').format(t.toLocal()) else ''],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inbox = ref.watch(approvalInboxProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.approvalInbox),
        actions: [ExportMenuButton(table: _table, formats: const {ExportFormat.excel, ExportFormat.pdf, ExportFormat.csv, ExportFormat.json})],
      ),
      body: switch (inbox) {
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(approvalInboxProvider.future),
            child: _body(context, l10n, value),
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(approvalInboxProvider)),
        _ => const SkeletonList(),
      },
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n, ApprovalInbox inbox) {
    final items = _visible(inbox.items);
    final kindColors = {
      ApprovalKind.project: Theme.of(context).colorScheme.primary,
      ApprovalKind.promotion: context.tbt.success,
      ApprovalKind.raise: context.tbt.info,
      ApprovalKind.leave: context.tbt.caution,
      ApprovalKind.overtime: context.tbt.brandGold,
      ApprovalKind.profile: Theme.of(context).colorScheme.tertiary,
      ApprovalKind.resignation: context.tbt.danger,
    };
    final session = ref.watch(authControllerProvider).value;
    final regions = session == null || session.isGroup ? Env.regions : [session.region];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (inbox.unreachable.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l10n.approvalRegionsDown(inbox.unreachable.map(l10n.regionName).join(', ')), style: TextStyle(color: context.tbt.caution, fontSize: 12)),
          ),
        Wrap(spacing: 8, runSpacing: 4, children: [
          ChoiceChip(label: Text('${l10n.filterAll} (${inbox.items.length})'), selected: _kind == null, onSelected: (_) => setState(() => _kind = null)),
          for (final k in ApprovalKind.values)
            ChoiceChip(
              label: Text('${approvalKindName(l10n, k)} (${inbox.items.where((i) => i.kind == k).length})'),
              selected: _kind == k,
              onSelected: (_) => setState(() => _kind = k),
            ),
        ]),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final r in [null, ...regions])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(r == null ? l10n.allRegions : l10n.regionName(r)), selected: _region == r, onSelected: (_) => setState(() => _region = r)),
              ),
          ]),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(l10n.approvalByRegion, style: const TextStyle(fontWeight: FontWeight.bold))),
                  SegmentedButton<bool>(
                    segments: [ButtonSegment(value: false, label: Text(l10n.chart2d)), ButtonSegment(value: true, label: Text(l10n.chart3d))],
                    selected: {_threeD},
                    onSelectionChanged: (v) => setState(() => _threeD = v.first),
                  ),
                ]),
                const SizedBox(height: 12),
                SizedBox(height: 180, child: _threeD ? _regions3d(context, items) : _regions2d(context, items, kindColors)),
                const SizedBox(height: 8),
                Wrap(spacing: 12, children: [
                  for (final k in ApprovalKind.values)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: kindColors[k], borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 4),
                      Text(approvalKindName(l10n, k), style: TextStyle(fontSize: 11, color: context.tbt.textSecondary)),
                    ]),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.approvalWaiting(items.length), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (items.isEmpty) SizedBox(height: 200, child: EmptyView(message: l10n.noApprovals, icon: Icons.inbox_outlined)),
        for (final item in items) FadeSlideIn(child: _ApprovalCard(item: item, color: kindColors[item.kind]!, onDecide: _decide)),
      ],
    );
  }

  Widget _regions2d(BuildContext context, List<ApprovalItem> items, Map<ApprovalKind, Color> colors) {
    final style = TextStyle(fontSize: 10, color: context.tbt.textSecondary);
    return BarChart(BarChartData(
      gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: context.tbt.glassBorder, strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24, interval: 1, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: style))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (v, _) => Text(Env.regions[v.toInt()].toUpperCase(), style: style))),
      ),
      barGroups: [
        for (final (i, region) in Env.regions.indexed)
          BarChartGroupData(x: i, barsSpace: 2, barRods: [
            for (final k in ApprovalKind.values)
              BarChartRodData(
                toY: items.where((it) => it.region == region && it.kind == k).length.toDouble(),
                width: 7,
                color: colors[k],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
              ),
          ]),
      ],
    ));
  }

  Widget _regions3d(BuildContext context, List<ApprovalItem> items) => CustomPaint(
        size: Size.infinite,
        painter: IsometricBarsPainter(
          labels: [for (final r in Env.regions) r.toUpperCase()],
          values: [for (final r in Env.regions) items.where((i) => i.region == r).length.toDouble()],
          colors: [for (final _ in Env.regions) Theme.of(context).colorScheme.primary],
          grid: context.tbt.glassBorder,
          text: context.tbt.textSecondary,
        ),
      );
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({required this.item, required this.color, required this.onDecide});

  final ApprovalItem item;
  final Color color;
  final Future<void> Function(ApprovalItem item, bool approve) onDecide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = switch (item.kind) {
      ApprovalKind.project => Routes.projectProposals,
      ApprovalKind.promotion => Routes.nominations,
      ApprovalKind.raise => Routes.raiseRequests,
      ApprovalKind.profile => Routes.changeRequests,
      ApprovalKind.resignation => Routes.resignations,
      ApprovalKind.leave || ApprovalKind.overtime => null,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(approvalKindName(l10n, item.kind), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(l10n.regionName(item.region), style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
            ]),
            const SizedBox(height: 4),
            Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(_detail(l10n, item)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton(onPressed: () => onDecide(item, true), child: Text(l10n.approve)),
              TextButton(onPressed: () => onDecide(item, false), child: Text(l10n.reject)),
              if (route != null) TextButton(onPressed: () => context.push(route), child: Text(l10n.viewDetails)),
            ]),
          ],
        ),
      ),
    );
  }
}
