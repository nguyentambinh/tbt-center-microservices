/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/knowledge_graph.dart';
import '../providers/knowledge_providers.dart';
import 'article_sheet.dart';
import 'graph_canvas.dart';
import 'graph_sheets.dart';

String nodeTypeLabel(AppLocalizations l10n, NodeType type) => switch (type) {
      NodeType.concept => l10n.graphTypeConcept,
      NodeType.process => l10n.graphTypeProcess,
      NodeType.step => l10n.graphTypeStep,
      NodeType.rule => l10n.graphTypeRule,
      NodeType.role => l10n.graphTypeRole,
      NodeType.service => l10n.graphTypeService,
      NodeType.technology => l10n.graphTypeTechnology,
      NodeType.pattern => l10n.graphTypePattern,
      NodeType.region => l10n.graphTypeRegion,
      NodeType.document => l10n.graphTypeDocument,
    };

/// Đồ thị tri thức: một nút ở giữa, chạm nút khác để đi tiếp
class GraphTab extends ConsumerStatefulWidget {
  const GraphTab({super.key, required this.onAsk});

  /// Chuyển sang tab Hỏi AI với câu hỏi về nút đang xem
  final ValueChanged<String> onAsk;

  @override
  ConsumerState<GraphTab> createState() => _GraphTabState();
}

class _GraphTabState extends ConsumerState<GraphTab> {
  final _search = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _focus(String id) {
    _debounce?.cancel();
    _search.clear();
    // Bỏ focus ô nhập để bàn phím không bật lại khi đóng bảng bài viết
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _query = '');
    ref.read(graphCenterProvider.notifier).focus(id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final center = ref.watch(graphCenterProvider);
    final view = ref.watch(graphViewProvider(center));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _search,
            onChanged: (v) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () => setState(() => _query = v.trim()));
            },
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.graphSearchHint),
          ),
        ),
        Expanded(
          child: _query.isNotEmpty
              ? _SearchResults(query: _query, onPick: _focus)
              : switch (view) {
                  AsyncValue(:final value?) => _GraphBody(
                      view: value,
                      onFocus: _focus,
                      onAsk: () => widget.onAsk(l10n.graphAskTemplate(value.center.label)),
                    ),
                  AsyncValue(:final error?) =>
                    ErrorView(error: error, onRetry: () => ref.invalidate(graphViewProvider(center))),
                  _ => const SkeletonList(rows: 3),
                },
        ),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query, required this.onPick});

  final String query;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    return switch (ref.watch(graphNodeSearchProvider(query))) {
      AsyncValue(:final value?) when value.isEmpty => EmptyView(message: l10n.knowledgeEmpty),
      AsyncValue(:final value?) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          children: [
            for (final n in value)
              ListTile(
                leading: CircleAvatar(radius: 7, backgroundColor: nodeColor(n.type, accent)),
                title: Text(n.label),
                subtitle: Text(nodeTypeLabel(l10n, n.type),
                    style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
                onTap: () => onPick(n.id),
              ),
          ],
        ),
      AsyncValue(:final error?) =>
        ErrorView(error: error, onRetry: () => ref.invalidate(graphNodeSearchProvider(query))),
      _ => const SkeletonList(rows: 4),
    };
  }
}

class _GraphBody extends StatelessWidget {
  const _GraphBody({required this.view, required this.onFocus, required this.onAsk});

  final GraphView view;
  final ValueChanged<String> onFocus;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final c = view.center;
    final byId = {for (final n in view.nodes) n.id: n};
    final links = [
      for (final e in view.edges)
        if (e.source == c.id && byId[e.target] != null)
          (id: e.target, edge: e, text: '${e.label}${e.note == null ? '' : ' ${e.note}'} → ${byId[e.target]!.label}')
        else if (e.target == c.id && byId[e.source] != null)
          (id: e.source, edge: e, text: '${byId[e.source]!.label} → ${e.label}'),
    ];
    final articleId = view.articleId;
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Card(
            margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            clipBehavior: Clip.antiAlias,
            child: GraphCanvas(view: view, onTapNode: (n) => onFocus(n.id)),
          ),
        ),
        Expanded(
          flex: 4,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 6, backgroundColor: nodeColor(c.type, accent)),
                  const SizedBox(width: 8),
                  Text(nodeTypeLabel(l10n, c.type),
                      style: TextStyle(color: context.tbt.textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              Text(c.label, style: Theme.of(context).textTheme.titleLarge),
              if (c.summary case final summary?) ...[
                const SizedBox(height: 6),
                Text(summary, style: const TextStyle(height: 1.4)),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (articleId != null)
                    OutlinedButton.icon(
                      onPressed: () => showArticleSheet(context, articleId),
                      icon: const Icon(Icons.article_outlined, size: 18),
                      label: Text(l10n.graphReadArticle),
                    ),
                  FilledButton.tonalIcon(
                    onPressed: onAsk,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: Text(l10n.graphAskAbout),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => showPathPicker(context, c, onFocus),
                    icon: const Icon(Icons.route_outlined, size: 18),
                    label: Text(l10n.graphPathTo),
                  ),
                ],
              ),
              if (links.isNotEmpty) ...[
                const SizedBox(height: 14),
                SectionLabel(l10n.graphRelated),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final link in links)
                      ActionChip(
                        avatar: link.edge.inferred || link.edge.evidence != null
                            ? Icon(link.edge.inferred ? Icons.auto_awesome : Icons.format_quote,
                                size: 16, color: nodeColor(byId[link.id]!.type, accent))
                            : CircleAvatar(backgroundColor: nodeColor(byId[link.id]!.type, accent)),
                        label: Text(link.text, style: const TextStyle(fontSize: 12)),
                        // Cạnh suy ra hoặc AI trích: xem vì sao trước khi đi tới nút
                        onPressed: () => link.edge.inferred || link.edge.evidence != null
                            ? showEdgeExplanation(context, link.edge, byId[link.id]!, () => onFocus(link.id))
                            : onFocus(link.id),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
