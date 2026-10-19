/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/locale/locale_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/knowledge_graph.dart';
import '../../domain/entities/ontology.dart';
import '../providers/knowledge_providers.dart';

const _statuses = ['pending', 'invalid', 'approved', 'rejected'];

/// HR, quản trị, ban điều hành duyệt nút và cạnh AI trích từ bài viết
class ProposalsPage extends ConsumerStatefulWidget {
  const ProposalsPage({super.key});

  @override
  ConsumerState<ProposalsPage> createState() => _ProposalsPageState();
}

class _ProposalsPageState extends ConsumerState<ProposalsPage> {
  String _status = 'pending';
  final _busy = <String>{};

  String _statusLabel(AppLocalizations l10n, String s) => switch (s) {
        'pending' => l10n.proposalsPending,
        'invalid' => l10n.proposalsInvalid,
        'approved' => l10n.proposalsApproved,
        _ => l10n.proposalsRejected,
      };

  Future<void> _extract() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final n = await ref.read(knowledgeRepositoryProvider).extract();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.proposalsQueued(n))));
      ref.invalidate(proposalsProvider);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  Future<void> _review(GraphProposal p, {required bool approve}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy.add(p.id));
    try {
      await ref.read(knowledgeRepositoryProvider).reviewProposal(p.id, approve: approve);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(approve ? l10n.proposalApproved : l10n.proposalRejected)));
      ref
        ..invalidate(proposalsProvider)
        ..invalidate(ontologyProvider)
        ..invalidate(graphViewProvider);
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _busy.remove(p.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(proposalsProvider(_status));
    // Nhãn nút và quan hệ để hiện cạnh dễ đọc thay vì mã
    final nodes = {for (final n in ref.watch(graphNodeSearchProvider('')).value ?? const <GraphNode>[]) n.id: n.label};
    final relations = {for (final r in ref.watch(ontologyProvider).value?.relations ?? const <OntologyRelation>[]) r.id: r.label};
    final running = list.value?.running ?? false;
    final lang = ref.watch(appLocaleProvider).languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.proposalsTitle),
        actions: [
          IconButton(
            tooltip: l10n.proposalsRun,
            onPressed: running ? null : _extract,
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                for (final s in _statuses)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_statusLabel(l10n, s)),
                      selected: _status == s,
                      onSelected: (_) => setState(() => _status = s),
                    ),
                  ),
              ],
            ),
          ),
          if (running)
            ListTile(
              leading: const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              title: Text(l10n.proposalsRunning),
              trailing: IconButton(
                tooltip: l10n.retry,
                onPressed: () => ref.invalidate(proposalsProvider(_status)),
                icon: const Icon(Icons.refresh),
              ),
            ),
          if (list.value case ProposalList(configured: false))
            ListTile(leading: const Icon(Icons.info_outline), title: Text(l10n.proposalsNoAi)),
          Expanded(
            child: switch (list) {
              AsyncValue(:final value?) when value.items.isEmpty => EmptyView(message: l10n.proposalsEmpty),
              AsyncValue(:final value?) => RefreshIndicator(
                  onRefresh: () async => ref.invalidate(proposalsProvider(_status)),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      for (final p in value.items)
                        _ProposalCard(
                          proposal: p,
                          nodes: {
                            ...nodes,
                            for (final x in value.items)
                              if (x.isNode) x.payload['id'] as String: '${(x.payload['labels'] as Map)[lang] ?? x.payload['id']}',
                          },
                          relations: relations,
                          busy: _busy.contains(p.id),
                          lang: lang,
                          onReview: p.status == 'pending' || p.status == 'invalid'
                              ? (approve) => _review(p, approve: approve)
                              : null,
                        ),
                    ],
                  ),
                ),
              AsyncValue(:final error?) =>
                ErrorView(error: error, onRetry: () => ref.invalidate(proposalsProvider(_status))),
              _ => const SkeletonList(rows: 4),
            },
          ),
        ],
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({
    required this.proposal,
    required this.nodes,
    required this.relations,
    required this.busy,
    required this.onReview,
    required this.lang,
  });

  final GraphProposal proposal;
  final Map<String, String> nodes;
  final Map<String, String> relations;
  final bool busy;
  final ValueChanged<bool>? onReview;
  final String lang;

  String _reason(AppLocalizations l10n, String code) => switch (code) {
        'evidence_not_in_article' => l10n.proposalReasonEvidence,
        'low_confidence' => l10n.proposalReasonConfidence,
        'unused_node' => l10n.proposalReasonUnused,
        _ when code.startsWith('domain:') || code.startsWith('range:') => l10n.proposalReasonOntology(code),
        _ => l10n.proposalReasonOther(code),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final p = proposal.payload;
    final title = proposal.isNode
        ? '${l10n.proposalNewNode}: ${(p['labels'] as Map)[lang] ?? p['id']}'
        : '${nodes[p['source']] ?? p['source']}  —${relations[p['relation']] ?? p['relation']}→  '
            '${nodes[p['target']] ?? p['target']}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.3)),
            const SizedBox(height: 4),
            Text(
              proposal.isNode ? '${p['id']} · ${p['class']}' : '${p['source']} ${p['relation']} ${p['target']}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            if (proposal.evidence case final quote?) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(border: Border(left: BorderSide(color: accent, width: 3))),
                child: Text('“$quote”', style: const TextStyle(fontStyle: FontStyle.italic, height: 1.35)),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              [
                l10n.proposalFrom(proposal.articleId),
                if (proposal.confidence case final c?) l10n.proposalConfidence((c * 100).round()),
                ?proposal.model,
              ].join(' · '),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            if (proposal.reason case final r?) ...[
              const SizedBox(height: 4),
              Text(_reason(l10n, r), style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
            ],
            if (onReview != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: busy ? null : () => onReview!(false), child: Text(l10n.proposalReject)),
                  if (proposal.status == 'pending')
                    FilledButton(onPressed: busy ? null : () => onReview!(true), child: Text(l10n.proposalApprove)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
