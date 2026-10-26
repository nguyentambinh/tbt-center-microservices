/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/knowledge_graph.dart';
import '../providers/knowledge_providers.dart';
import 'graph_canvas.dart';
import 'graph_tab.dart';
import '../../../../core/widgets/input_rules.dart';

/// Vì sao có cạnh này: luật và các cạnh tiền đề (suy luận) hoặc câu trích trong bài (AI)
void showEdgeExplanation(BuildContext context, GraphEdge edge, GraphNode other, VoidCallback onGo) {
  final l10n = AppLocalizations.of(context);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${edge.label} · ${other.label}', style: Theme.of(sheet).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (edge.inferred) ...[
              Text(l10n.graphInferredBy(edge.rule ?? '')),
              const SizedBox(height: 8),
              Text(l10n.graphBecause, style: const TextStyle(fontWeight: FontWeight.w700)),
              for (final b in edge.because) Padding(padding: const EdgeInsets.only(top: 4), child: Text('• $b')),
            ] else if (edge.evidence case final quote?) ...[
              Text(l10n.graphEvidence),
              const SizedBox(height: 6),
              Text('“$quote”', style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                Navigator.of(sheet).pop();
                onGo();
              },
              child: Text(l10n.graphGoTo),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Chọn nút đích rồi hiện đường ngắn nhất từ nút đang xem
Future<void> showPathPicker(BuildContext context, GraphNode from, ValueChanged<String> onFocus) async {
  final target = await showModalBottomSheet<GraphNode>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _NodePicker(),
  );
  if (target == null || !context.mounted || target.id == from.id) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PathSheet(from: from, to: target, onFocus: onFocus),
  );
}

class _NodePicker extends ConsumerStatefulWidget {
  const _NodePicker();

  @override
  ConsumerState<_NodePicker> createState() => _NodePickerState();
}

class _NodePickerState extends ConsumerState<_NodePicker> {
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final search = ref.watch(graphNodeSearchProvider(_query));
    final nodes = search.value ?? const <GraphNode>[];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                inputFormatters: InputRules.search,
                onChanged: (v) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () => setState(() => _query = v.trim()));
                },
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.graphPathPick),
              ),
            ),
            if (search.isLoading) const LinearProgressIndicator(),
            Expanded(
              child: ListView(
                children: [
                  for (final n in nodes)
                    ListTile(
                      leading: CircleAvatar(radius: 7, backgroundColor: nodeColor(n.type, accent)),
                      title: Text(n.label),
                      subtitle: Text(nodeTypeLabel(l10n, n.type),
                          style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
                      onTap: () => Navigator.of(context).pop(n),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PathSheet extends ConsumerWidget {
  const _PathSheet({required this.from, required this.to, required this.onFocus});

  final GraphNode from;
  final GraphNode to;
  final ValueChanged<String> onFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final key = (from.id, to.id);
    Widget node(GraphNode n) => ListTile(
          dense: true,
          leading: CircleAvatar(radius: 8, backgroundColor: nodeColor(n.type, accent)),
          title: Text(n.label, style: const TextStyle(fontWeight: FontWeight.w700)),
          onTap: () {
            Navigator.of(context).pop();
            onFocus(n.id);
          },
        );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(l10n.graphPathTitle(from.label, to.label), style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            switch (ref.watch(graphPathProvider(key))) {
              AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(graphPathProvider(key))),
              AsyncValue(:final value?) => Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      node(value.from),
                      for (final s in value.steps) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Row(
                            children: [
                              Icon(s.forward ? Icons.arrow_downward : Icons.arrow_upward,
                                  size: 16, color: context.tbt.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${s.edge.label}${s.edge.inferred ? ' (${l10n.graphInferred})' : ''}',
                                  style: TextStyle(color: context.tbt.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        node(s.node),
                      ],
                    ],
                  ),
                ),
              AsyncValue(hasValue: true) =>
                Padding(padding: const EdgeInsets.all(16), child: Text(l10n.graphPathNone)),
              _ => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
            },
          ],
        ),
      ),
    );
  }
}
