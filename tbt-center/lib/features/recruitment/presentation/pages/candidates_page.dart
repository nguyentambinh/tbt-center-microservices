/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/candidate.dart';
import '../providers/candidate_providers.dart';
import '../widgets/candidate_actions.dart';
import '../widgets/position_widgets.dart';
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
            tooltip: l10n.jobPositions,
            icon: const Icon(Icons.work_outline),
            onPressed: () => context.push(Routes.jobPositions),
          ),
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
                          subtitle: Text.rich(TextSpan(children: [
                            TextSpan(text: c.appliedPosition ?? ''),
                            if (c.bestScore case final s?) TextSpan(text: '  ·  ${l10n.bestMatch(s)}', style: TextStyle(color: matchColor(context, s), fontWeight: FontWeight.bold)),
                          ])),
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
        builder: (_) => CandidateSheet(id: id),
      );
}

class CandidateSheet extends ConsumerWidget {
  const CandidateSheet({super.key, required this.id});

  final String id;

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
              if (value.positions.isNotEmpty) PositionMatchCard(matches: value.positions, waitingForAi: value.hasCv && value.consentAi),
              if (value.aiSummary case final summary?) _AiSummaryCard(summary: summary),
              CandidateActions(candidate: value),
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
