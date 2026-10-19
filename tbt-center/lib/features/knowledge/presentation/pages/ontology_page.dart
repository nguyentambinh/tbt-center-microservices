/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ontology.dart';
import '../providers/knowledge_providers.dart';

/// Bản thể học: cây lớp, quan hệ (miền → phạm vi, tính chất), luật suy luận
class OntologyPage extends ConsumerWidget {
  const OntologyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ontologyTitle)),
      body: switch (ref.watch(ontologyProvider)) {
        AsyncValue(:final value?) => _OntologyBody(info: value),
        AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(ontologyProvider)),
        _ => const SkeletonList(rows: 6),
      },
    );
  }
}

class _OntologyBody extends ConsumerStatefulWidget {
  const _OntologyBody({required this.info});

  final OntologyInfo info;

  @override
  ConsumerState<_OntologyBody> createState() => _OntologyBodyState();
}

class _OntologyBodyState extends ConsumerState<_OntologyBody> {
  bool _running = false;

  Future<void> _rerun() async {
    setState(() => _running = true);
    try {
      await ref.read(knowledgeRepositoryProvider).runReasoner();
      ref.invalidate(ontologyProvider);
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final info = widget.info;
    final t = info.totals;
    final reasoning = info.reasoning;
    final roles = ref.watch(authControllerProvider.select((s) => s.value?.roles ?? const <String>[]));
    final children = <String?, List<String>>{};
    for (final c in info.classes) {
      (children[c.parent] ??= []).add(c.id);
    }
    final byId = {for (final c in info.classes) c.id: c};

    Iterable<Widget> tree(String? parent, int depth) sync* {
      for (final id in children[parent] ?? const <String>[]) {
        final c = byId[id]!;
        yield Padding(
          padding: EdgeInsets.only(left: depth * 18.0, top: 4, bottom: 4),
          child: Row(
            children: [
              Icon(depth == 0 ? Icons.account_tree_outlined : Icons.subdirectory_arrow_right,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(child: Text(c.label, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text(c.id, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              if (c.nodes > 0) ...[
                const SizedBox(width: 8),
                Text('${c.nodes}', style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
              ],
            ],
          ),
        );
        yield* tree(id, depth + 1);
      }
    }

    String names(List<String> ids) => ids.map(info.classLabel).join(' | ');
    final labelOf = {for (final r in info.relations) r.id: r.label};

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ontologyTotals(t['nodes'] ?? 0, t['asserted'] ?? 0, t['extracted'] ?? 0, t['inferred'] ?? 0),
                  style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4),
                ),
                if (reasoning != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.ontologyReasoning(reasoning['inferred'] as int? ?? 0, reasoning['ms'] as int? ?? 0),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 6),
                Text(l10n.ontologyExport, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                if (roles.any(proposalReviewerRoles.contains)) ...[
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    onPressed: _running ? null : _rerun,
                    icon: const Icon(Icons.autorenew, size: 18),
                    label: Text(l10n.ontologyRerun),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SectionLabel(l10n.ontologyClasses),
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [...tree(null, 0)]))),
        const SizedBox(height: 14),
        SectionLabel(l10n.ontologyRelations),
        for (final r in info.relations)
          Card(
            child: ListTile(
              title: Text('${r.label}  ·  ${r.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('${names(r.domain)}  →  ${names(r.range)}', style: TextStyle(color: accent)),
                  if (r.summary.isNotEmpty) Text(r.summary),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final tag in [
                        if (r.transitive) l10n.ontologyTransitive,
                        if (r.symmetric) l10n.ontologySymmetric,
                        if (r.inverseOf case final inv?) l10n.ontologyInverse(labelOf[inv] ?? inv),
                        if (r.subPropertyOf case final sup?) l10n.ontologySubProperty(labelOf[sup] ?? sup),
                        if (r.derived) l10n.ontologyDerived,
                        l10n.ontologyEdgeCount(r.edges),
                      ])
                        Chip(label: Text(tag, style: const TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
        SectionLabel(l10n.ontologyRules),
        for (final r in info.rules)
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: Text(r.label),
              subtitle: Text('${r.kind} · ${r.id}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ),
          ),
      ],
    );
  }
}
