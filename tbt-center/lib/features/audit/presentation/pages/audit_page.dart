/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/config/env.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/locale/l10n_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/audit_providers.dart';

/// Sổ kiểm toán (R54, R88–R90): xem sự kiện mọi khu vực, tự kiểm chuỗi băm,
/// xuất kèm mã SHA-256; lãnh đạo, quản trị xem thêm ai đã truy cập sổ.
class AuditPage extends ConsumerStatefulWidget {
  const AuditPage({super.key});

  @override
  ConsumerState<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends ConsumerState<AuditPage> {
  String? _region;
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

  Future<void> _export() => _run(() async {
        final export = await ref.read(auditRepositoryProvider).export(region: _region);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roles = ref.watch(authControllerProvider).value?.roles ?? const <String>[];
    final seesAccessLog = roles.any(accessLogRoles.contains);

    final eventsTab = Column(
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
                    selected: _region == region,
                    onSelected: (_) => setState(() => _region = region),
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _EventsList(region: _region)),
      ],
    );

    return DefaultTabController(
      length: seesAccessLog ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.auditLog),
          actions: [
            IconButton(tooltip: l10n.verifyChain, icon: const Icon(Icons.verified_outlined), onPressed: _busy ? null : _verify),
            IconButton(tooltip: l10n.exportAudit, icon: const Icon(Icons.download_outlined), onPressed: _busy ? null : _export),
          ],
          bottom: seesAccessLog
              ? TabBar(tabs: [Tab(text: l10n.auditEvents), Tab(text: l10n.accessLog)])
              : null,
        ),
        body: seesAccessLog ? TabBarView(children: [eventsTab, const _AccessLogList()]) : eventsTab,
      ),
    );
  }
}

class _EventsList extends ConsumerWidget {
  const _EventsList({required this.region});

  final String? region;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final events = ref.watch(auditEventsProvider(region));
    return switch (events) {
      AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noReportData),
      AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: () => ref.refresh(auditEventsProvider(region).future),
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
                isThreeLine: true,
              );
            },
          ),
        ),
      AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(auditEventsProvider(region))),
      _ => const SkeletonList(),
    };
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
        _ => l10n.auditSearch,
      };
}
