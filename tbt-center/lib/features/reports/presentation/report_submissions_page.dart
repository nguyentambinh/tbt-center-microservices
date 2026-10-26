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

import '../../../core/auth/auth_controller.dart';
import '../../../core/config/env.dart';
import '../../../core/error/error_reporter.dart';
import '../../../core/locale/l10n_names.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../../core/widgets/filter_bar.dart';
import '../../../core/widgets/motion.dart';
import '../../../l10n/app_localizations.dart';
import '../data/report_repository.dart';
import '../domain/report_submission.dart';
import '../../../core/widgets/input_rules.dart';

final reportRepositoryProvider = Provider.family<ReportRepository, String>(
  (ref, region) => ReportRepository(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region)),
);

final reportSubmissionsProvider = FutureProvider.autoDispose.family<List<ReportSubmission>, ({String region, String kind})>(
  (ref, q) => ref.watch(reportRepositoryProvider(q.region)).list(q.kind),
);

/// Ai lập báo cáo mảng nào
const reportAuthorRoles = {
  'hr': {'hr', 'admin'},
  'finance': {'finance', 'admin'},
};

/// Báo cáo khu vực gửi Ban lãnh đạo, tách mảng nhân sự và tài chính
class ReportSubmissionsPage extends ConsumerStatefulWidget {
  const ReportSubmissionsPage({super.key});

  @override
  ConsumerState<ReportSubmissionsPage> createState() => _ReportSubmissionsPageState();
}

class _ReportSubmissionsPageState extends ConsumerState<ReportSubmissionsPage> {
  String? _region;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider).value;
    final roles = session?.roles ?? const <String>[];
    final executive = roles.contains('executive');
    final region = _region ?? session?.region ?? 'vn';
    final kinds = [
      for (final k in ['hr', 'finance'])
        if (executive || roles.any(reportAuthorRoles[k]!.contains)) k,
    ];
    if (kinds.isEmpty) return Scaffold(appBar: AppBar(title: Text(l10n.reportSubmissions)), body: EmptyView(message: l10n.noData));
    return DefaultTabController(
      length: kinds.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.reportSubmissions),
          bottom: TabBar(tabs: [for (final k in kinds) Tab(text: k == 'hr' ? l10n.reportHr : l10n.reportFinance)]),
        ),
        body: Column(
          children: [
            if (executive)
              FilterBar(children: [
                FilterSpinner<String>(
                  label: l10n.filterRegion,
                  value: region,
                  options: [for (final r in Env.regions) (value: r, label: l10n.regionName(r))],
                  onChanged: (v) => setState(() => _region = v),
                ),
              ]),
            Expanded(child: TabBarView(children: [for (final k in kinds) _KindTab(kind: k, region: region, roles: roles.toSet())])),
          ],
        ),
      ),
    );
  }
}

class _KindTab extends ConsumerWidget {
  const _KindTab({required this.kind, required this.region, required this.roles});

  final String kind;
  final String region;
  final Set<String> roles;

  Future<String?> _note(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(inputFormatters: InputRules.note, controller: controller, maxLines: 3, decoration: InputDecoration(labelText: l10n.note)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(l10n.send)),
        ],
      ),
    );
  }

  Future<void> _run(BuildContext context, WidgetRef ref, Future<Object?> Function() action, String done) async {
    try {
      await action();
      ref.invalidate(reportSubmissionsProvider((region: region, kind: kind)));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done), behavior: SnackBarBehavior.floating));
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final query = (region: region, kind: kind);
    final items = ref.watch(reportSubmissionsProvider(query));
    final repo = ref.read(reportRepositoryProvider(region));
    final author = roles.any(reportAuthorRoles[kind]!.contains);
    final reviewer = roles.contains('executive');
    final now = DateTime.now();
    final period = DateTime(now.year, now.month - 1).toIso8601String().substring(0, 7);
    return switch (items) {
      AsyncValue(:final value?) => Scaffold(
          floatingActionButton: author
              ? FloatingActionButton.extended(
                  onPressed: value.isNotEmpty && value.first.waiting
                      ? null
                      : () async {
                          final note = await _note(context, l10n.submitReportTitle(period));
                          if (note == null || !context.mounted) return;
                          await _run(context, ref, () => repo.submit(kind, period: period, note: note.isEmpty ? null : note), l10n.reportSent);
                        },
                  icon: const Icon(Icons.outbox_outlined),
                  label: Text(value.isNotEmpty && value.first.waiting ? l10n.reportWaitingAck : l10n.submitReport),
                )
              : null,
          body: value.isEmpty
              ? EmptyView(message: l10n.noReports, icon: Icons.summarize_outlined)
              : RefreshIndicator(
                  onRefresh: () => ref.refresh(reportSubmissionsProvider(query).future),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      for (final r in value)
                        FadeSlideIn(
                          child: _ReportCard(
                            report: r,
                            actions: reviewer && r.waiting
                                ? [
                                    FilledButton(onPressed: () => _run(context, ref, () => repo.review(kind, r.id, action: 'acknowledge'), l10n.reportAcknowledged), child: Text(l10n.acknowledge)),
                                    OutlinedButton(
                                      onPressed: () async {
                                        final note = await _note(context, l10n.returnReport);
                                        if (note == null || !context.mounted) return;
                                        await _run(context, ref, () => repo.review(kind, r.id, action: 'return', note: note), l10n.statusChanged);
                                      },
                                      child: Text(l10n.returnReport),
                                    ),
                                  ]
                                : const [],
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(reportSubmissionsProvider(query))),
      _ => const SkeletonList(),
    };
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, this.actions = const []});

  final ReportSubmission report;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final r = report;
    final d = r.data;
    final (label, color) = switch (r.status) {
      'acknowledged' => (l10n.reportStatusAcknowledged, context.tbt.success),
      'returned' => (l10n.reportStatusReturned, context.tbt.danger),
      _ => (l10n.reportStatusSubmitted, context.tbt.brandGold),
    };
    final money = NumberFormat.compactSimpleCurrency(locale: locale, name: d['currency'] as String? ?? 'USD');
    String m(Object? v) => v is num ? money.format(v) : '—';
    final lines = r.kind == 'hr'
        ? [
            l10n.reportHeadcount(d['headcount'] as int? ?? 0, d['departments'] as int? ?? 0),
            l10n.reportUnassigned(d['unassigned'] as int? ?? 0),
            l10n.reportNominations((d['nominations'] as Map?)?['pending'] as int? ?? 0, (d['nominations'] as Map?)?['approved'] as int? ?? 0),
          ]
        : [
            '${l10n.revenue}: ${m(d['revenue'])}',
            '${l10n.materialCost}: ${m(d['material'])} · ${l10n.payrollCost}: ${m(d['payroll'])}',
            '${l10n.profit}: ${m(d['profit'])}',
          ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(l10n.reportPeriod(r.period), style: const TextStyle(fontWeight: FontWeight.bold))),
              Text(label, style: TextStyle(color: color, fontSize: 12)),
            ]),
            Text('${r.submittedBy} · ${DateFormat.yMMMd(locale).add_Hm().format(r.createdAt)}', style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            for (final line in lines) Text(line),
            if (r.note case final note? when note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('“$note”', style: const TextStyle(fontStyle: FontStyle.italic))),
            if (r.reviewNote case final note? when note.isNotEmpty) Text('${r.reviewedBy}: $note', style: TextStyle(color: color)),
            if (actions.isNotEmpty) ...[const SizedBox(height: 8), Wrap(spacing: 8, children: actions)],
          ],
        ),
      ),
    );
  }
}
