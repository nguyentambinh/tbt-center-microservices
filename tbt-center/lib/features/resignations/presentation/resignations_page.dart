/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/config/env.dart';
import '../../../core/error/error_reporter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../../core/widgets/motion.dart';
import '../../../l10n/app_localizations.dart';
import '../data/resignation_repository.dart';
import '../domain/resignation.dart';
import '../../../core/widgets/input_rules.dart';

final resignationRepositoryProvider = Provider.family<ResignationRepository, String>(
  (ref, region) => ResignationRepository(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region)),
);

final resignationsProvider = FutureProvider.autoDispose.family<List<Resignation>, String>(
  (ref, region) => ref.watch(resignationRepositoryProvider(region)).list(),
);

/// Ai xử lý đơn thôi việc
const resignationHandlerRoles = {'hr', 'admin'};

String resignationStatusLabel(AppLocalizations l10n, String status) => switch (status) {
      'pending' => l10n.resignationPending,
      'approved' => l10n.resignationApproved,
      'completed' => l10n.resignationCompleted,
      'rejected' => l10n.statusRejected,
      _ => l10n.resignationWithdrawn,
    };

/// Xin thôi việc: nhân viên gửi đơn báo trước 30 ngày, HR duyệt rồi hoàn tất sau ngày làm cuối
class ResignationsPage extends ConsumerWidget {
  const ResignationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider).value;
    final region = session?.region ?? 'vn';
    final handler = session?.roles.any(resignationHandlerRoles.contains) ?? false;
    final items = ref.watch(resignationsProvider(region));
    final hasOpen = items.value?.any((r) => r.open && r.employeeId == session?.employeeId) ?? true;

    Future<void> run(Future<Object?> Function() action, String done) async {
      try {
        await action();
        ref.invalidate(resignationsProvider(region));
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done), behavior: SnackBarBehavior.floating));
      } on Object catch (e) {
        reportFailure(e);
      }
    }

    Future<void> submit() async {
      final input = await showDialog<({DateTime lastDay, String reason, ({String name, List<int> bytes}) letter})>(context: context, builder: (_) => const _ResignationDialog());
      if (input == null || !context.mounted) return;
      final language = Localizations.localeOf(context).languageCode;
      await run(
        () => ref.read(resignationRepositoryProvider(region)).submit(lastDay: input.lastDay, reason: input.reason, letter: input.letter, language: language),
        l10n.resignationSent,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resignations)),
      floatingActionButton: session?.employeeId != null && !hasOpen && !handler
          ? FloatingActionButton.extended(onPressed: submit, icon: const Icon(Icons.logout), label: Text(l10n.newResignation))
          : null,
      body: switch (items) {
        AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noResignations, icon: Icons.logout),
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(resignationsProvider(region).future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [for (final r in value) FadeSlideIn(child: ResignationCard(resignation: r, region: region, handler: handler, onRun: run))],
            ),
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(resignationsProvider(region))),
        _ => const SkeletonList(),
      },
    );
  }
}

class ResignationCard extends ConsumerWidget {
  const ResignationCard({super.key, required this.resignation, required this.region, required this.handler, required this.onRun});

  final Resignation resignation;
  final String region;
  final bool handler;
  final Future<void> Function(Future<Object?> Function() action, String done) onRun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final r = resignation;
    final repo = ref.read(resignationRepositoryProvider(region));
    final mine = ref.watch(authControllerProvider).value?.employeeId == r.employeeId;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(r.lastDay);
    final color = switch (r.status) {
      'approved' || 'completed' => context.tbt.success,
      'rejected' || 'withdrawn' => context.tbt.danger,
      _ => context.tbt.brandGold,
    };

    Future<void> complete() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.resignationComplete),
          content: Text(l10n.resignationCompleteConfirm(r.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.resignationComplete)),
          ],
        ),
      );
      if (ok == true) await onRun(() => repo.respond(r.id, action: 'complete'), l10n.resignationCompletedDone);
    }

    final buttons = <Widget>[
      if (mine && r.status == 'pending') TextButton(onPressed: () => onRun(() => repo.respond(r.id, action: 'withdraw'), l10n.statusChanged), child: Text(l10n.resignationWithdraw)),
      if (handler && !mine && r.status == 'pending') ...[
        FilledButton(onPressed: () => onRun(() => repo.respond(r.id, action: 'approve'), l10n.statusChanged), child: Text(l10n.approve)),
        TextButton(onPressed: () => onRun(() => repo.respond(r.id, action: 'reject'), l10n.statusChanged), child: Text(l10n.reject)),
      ],
      if (handler && !mine && r.canComplete(DateTime.now())) FilledButton(onPressed: complete, child: Text(l10n.resignationComplete)),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(handler ? '${r.name} (${r.employeeId})' : l10n.resignations, style: const TextStyle(fontWeight: FontWeight.bold))),
              Text(resignationStatusLabel(l10n, r.status), style: TextStyle(color: color, fontSize: 12)),
            ]),
            const SizedBox(height: 6),
            Text(l10n.resignationLastDayOn(date), style: Theme.of(context).textTheme.titleMedium),
            Text(r.reason),
            if (r.letterName case final name?)
              TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: Text(l10n.resignationOpenLetter(name), overflow: TextOverflow.ellipsis),
                onPressed: () async {
                  try {
                    await launchUrl(await repo.letterUrl(r.id), mode: LaunchMode.externalApplication);
                  } on Object catch (e) {
                    reportFailure(e);
                  }
                },
              ),
            if (handler && !mine && r.aiAnalysis != null) _AiAnalysis(analysis: r.aiAnalysis!),
            if (r.decidedBy != null) Text(r.decidedBy!, style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
            if (buttons.isNotEmpty) ...[const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: buttons)],
          ],
        ),
      ),
    );
  }
}

/// AI phân tích đơn thôi việc: tóm tắt, lý do chính, nhóm lý do, gợi ý giữ chân
class _AiAnalysis extends StatelessWidget {
  const _AiAnalysis({required this.analysis});

  final Map<String, dynamic> analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    List<String> list(String key) => [for (final v in analysis[key] as List? ?? const []) '$v'];
    final concerns = '${analysis['concerns'] ?? ''}'.trim();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: context.tbt.info.withValues(alpha: 0.10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.auto_awesome, size: 16, color: context.tbt.info),
          const SizedBox(width: 6),
          Expanded(child: Text(l10n.resignationAiTitle, style: TextStyle(fontWeight: FontWeight.bold, color: context.tbt.info))),
          if (analysis['category'] case final String c) Chip(visualDensity: VisualDensity.compact, label: Text(resignationCategory(l10n, c))),
        ]),
        Text('${analysis['summary'] ?? ''}'),
        for (final reason in list('mainReasons')) Text('• $reason'),
        if (list('retentionIdeas').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(l10n.resignationAiRetention, style: const TextStyle(fontWeight: FontWeight.bold)),
          for (final idea in list('retentionIdeas')) Text('• $idea'),
        ],
        if (concerns.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('${l10n.resignationAiConcerns}: $concerns', style: TextStyle(color: context.tbt.caution)),
        ],
        const SizedBox(height: 4),
        Text(l10n.resignationAiNote, style: TextStyle(fontSize: 11, color: context.tbt.textSecondary)),
      ]),
    );
  }
}

String resignationCategory(AppLocalizations l10n, String c) => switch (c) {
      'career' => l10n.rcCareer,
      'salary' => l10n.rcSalary,
      'workload' => l10n.rcWorkload,
      'management' => l10n.rcManagement,
      'environment' => l10n.rcEnvironment,
      'personal' => l10n.rcPersonal,
      'health' => l10n.rcHealth,
      'relocation' => l10n.rcRelocation,
      _ => l10n.rcOther,
    };

/// Chọn bản đơn thôi việc; test thay bằng tệp giả
final pickLetterProvider = Provider<Future<({String name, List<int> bytes})?> Function()>((ref) => () async {
      final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['docx', 'pdf', 'jpg', 'jpeg', 'png']);
      return picked == null ? null : (name: picked.name, bytes: await picked.readAsBytes());
    });

class _ResignationDialog extends ConsumerStatefulWidget {
  const _ResignationDialog();

  @override
  ConsumerState<_ResignationDialog> createState() => _ResignationDialogState();
}

class _ResignationDialogState extends ConsumerState<_ResignationDialog> {
  final _reason = TextEditingController();
  late final DateTime _earliest = () {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + resignationNoticeDays);
  }();
  late DateTime _lastDay = _earliest;

  /// Bản đơn bắt buộc (Word, PDF, ảnh, tối đa 10 MB)
  ({String name, List<int> bytes})? _letter;
  String? _error;

  Future<void> _pickLetter() async {
    final l10n = AppLocalizations.of(context);
    final picked = await ref.read(pickLetterProvider)();
    if (picked == null) return;
    setState(() {
      if (picked.bytes.length > 10 * 1024 * 1024) {
        _error = l10n.errFileTooLarge;
      } else {
        _letter = picked;
        _error = null;
      }
    });
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_lastDay);
    return AlertDialog(
      title: Text(l10n.resignations),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(l10n.resignationLastDay),
            subtitle: Text('$date\n${l10n.resignationNotice(resignationNoticeDays)}'),
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: _lastDay, firstDate: _earliest, lastDate: _earliest.add(const Duration(days: 365)));
              if (picked != null) setState(() => _lastDay = picked);
            },
          ),
          TextField(
            inputFormatters: InputRules.note,
            controller: _reason,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.resignationReason),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickLetter,
            icon: Icon(_letter == null ? Icons.attach_file : Icons.description),
            label: Text(_letter?.name ?? l10n.resignationAttachLetter, overflow: TextOverflow.ellipsis),
          ),
          Text(_error ?? l10n.resignationLetterHint, style: TextStyle(fontSize: 12, color: _error == null ? context.tbt.textSecondary : context.tbt.danger)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: _reason.text.trim().isEmpty || _letter == null ? null : () => Navigator.pop(context, (lastDay: _lastDay, reason: _reason.text.trim(), letter: _letter!)),
          child: Text(l10n.send),
        ),
      ],
    );
  }
}
