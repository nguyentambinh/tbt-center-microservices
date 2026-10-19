/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/candidate.dart';
import '../providers/candidate_providers.dart';
import '../widgets/stage_widgets.dart';
import 'candidate_import_page.dart';

/// Màn của HR: lọc theo bước, mở hồ sơ, chuyển bước.
class CandidatesPage extends ConsumerStatefulWidget {
  const CandidatesPage({super.key});

  @override
  ConsumerState<CandidatesPage> createState() => _CandidatesPageState();
}

class _CandidatesPageState extends ConsumerState<CandidatesPage> {
  String? _stage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(candidateListProvider(_stage));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.candidates),
        actions: [
          IconButton(
            tooltip: l10n.importCandidates,
            icon: const Icon(Icons.upload_file),
            onPressed: () => pickAndImportCandidates(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final stage in [null, ...candidateStages])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(stage == null ? l10n.allStatuses : stageName(l10n, stage)),
                      selected: stage == _stage,
                      onSelected: (_) => setState(() => _stage = stage),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: switch (list) {
              AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.noCandidates),
              AsyncValue(:final value?) => RefreshIndicator(
                  onRefresh: () => ref.refresh(candidateListProvider(_stage).future),
                  child: ListView(
                    children: [
                      for (final c in value)
                        ListTile(
                          title: Text(c.fullName),
                          subtitle: Text(c.appliedPosition ?? ''),
                          trailing: StageChip(c.status),
                          onTap: () => _openCandidate(context, c.id),
                        ),
                    ],
                  ),
                ),
              AsyncValue(:final error?) =>
                ErrorView(error: error, onRetry: () => ref.invalidate(candidateListProvider(_stage))),
              _ => const SkeletonList(),
            },
          ),
        ],
      ),
    );
  }

  void _openCandidate(BuildContext context, String id) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _CandidateSheet(id: id),
      );
}

class _CandidateSheet extends ConsumerWidget {
  const _CandidateSheet({required this.id});

  final String id;

  Future<void> _move(BuildContext context, WidgetRef ref, String stage) async {
    try {
      await ref.read(candidateRepositoryProvider).changeStage(id, status: stage);
      ref
        ..invalidate(candidateDetailProvider(id))
        ..invalidate(candidateListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).statusChanged), behavior: SnackBarBehavior.floating),
        );
      }
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  Future<void> _openCv(WidgetRef ref) async {
    try {
      final url = await ref.read(candidateRepositoryProvider).cvDownloadUrl(id);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(candidateDetailProvider(id));
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: switch (detail) {
        AsyncValue(:final value?) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text(value.fullName, style: Theme.of(context).textTheme.headlineSmall),
              Text(
                [value.appliedPosition, value.email, value.phone].whereType<String>().join(' · '),
                style: TextStyle(color: context.tbt.textSecondary),
              ),
              if (value.hasCv) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => _openCv(ref),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(l10n.openCv),
                  ),
                ),
              ],
              if (value.aiSummary case final summary?) _AiSummaryCard(summary: summary),
              const SizedBox(height: 12),
              if (value.status == 'offered') ...[
                _HireButton(candidate: value),
                const SizedBox(height: 12),
              ],
              // Đã hired thì khóa chuyển bước
              if (value.status != 'hired') ...[
                Text(l10n.moveTo, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final stage in candidateStages.where((s) => s != value.status && !hireOnlyStages.contains(s)))
                      OutlinedButton(onPressed: () => _move(context, ref, stage), child: Text(stageName(l10n, stage))),
                  ],
                ),
              ],
              const Divider(height: 32),
              Text(l10n.progress, style: Theme.of(context).textTheme.titleLarge),
              StageTimeline(history: value.history),
            ],
          ),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(candidateDetailProvider(id))),
        _ => const SkeletonList(),
      },
    );
  }
}


/// Nút nhận vào làm, khóa và hiện vòng xoay khi đang chờ server
class _HireButton extends ConsumerStatefulWidget {
  const _HireButton({required this.candidate});

  final Candidate candidate;

  @override
  ConsumerState<_HireButton> createState() => _HireButtonState();
}

class _HireButtonState extends ConsumerState<_HireButton> {
  bool _busy = false;

  Future<void> _hire() async {
    final candidate = widget.candidate;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.hireCandidate),
        content: Text(l10n.hireConfirm(candidate.fullName, candidate.email ?? '')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.hireCandidate)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    // Nút biến mất khi đã hired, nên hiện kết quả bằng context của Navigator
    final navigator = Navigator.of(context);
    final HireResult result;
    setState(() => _busy = true);
    try {
      result = await ref.read(candidateRepositoryProvider).hire(candidate.id);
    } on Object catch (e) {
      reportFailure(e);
      return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    ref
      ..invalidate(candidateDetailProvider(candidate.id))
      ..invalidate(candidateListProvider);
    if (!navigator.mounted) return;
    await showDialog<void>(
      context: navigator.context,
      builder: (context) => AlertDialog(
        title: Text(l10n.hiredTitle(result.employeeId)),
        content: SelectableText(
          [
            l10n.hiredLogin(result.login),
            if (result.temporaryPassword case final password?)
              l10n.hiredTempPassword(password)
            else
              l10n.hiredKeepPassword,
            l10n.hiredRelogin,
          ].join('\n\n'),
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _busy ? null : _hire,
      icon: _busy
          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.how_to_reg),
      label: Text(AppLocalizations.of(context).hireCandidate),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    );
  }
}

/// Bản tóm tắt CV do AI tạo, chỉ để HR tham khảo.
class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard({required this.summary});

  final Map<String, dynamic> summary;

  List<String> _list(String key) => [for (final v in summary[key] as List? ?? const []) v.toString()];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final years = summary['yearsOfExperience'];
    final headline = summary['headline'] as String? ?? '';

    Widget section(String title, List<String> items) => items.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall?.copyWith(color: context.tbt.brandGold)),
                for (final item in items) Text('• $item'),
              ],
            ),
          );

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: context.tbt.brandGold, size: 20),
                const SizedBox(width: 8),
                Text(l10n.aiSummary, style: text.titleLarge),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.aiDisclaimer, style: text.bodySmall?.copyWith(color: context.tbt.textSecondary)),
            if (headline.isNotEmpty) ...[const SizedBox(height: 8), Text(headline)],
            if (years is num && years > 0) Text(l10n.yearsExperience(years.toString())),
            if (_list('skills').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [for (final s in _list('skills')) Chip(label: Text(s), visualDensity: VisualDensity.compact)],
                ),
              ),
            section(l10n.suitablePositions, _list('suitablePositions')),
            section(l10n.strengths, _list('strengths')),
            section(l10n.interviewQuestions, _list('questionsForInterview')),
          ],
        ),
      ),
    );
  }
}
