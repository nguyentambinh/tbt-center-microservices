/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/knowledge_providers.dart';
import 'ontology_page.dart';
import 'proposals_page.dart';
import 'sparql_page.dart';
import '../widgets/ask_tab.dart';
import '../widgets/graph_tab.dart';
import '../widgets/search_tab.dart';

/// Kho tri thức: hỏi AI, tìm bài, xem đồ thị tri thức
class KnowledgePage extends ConsumerStatefulWidget {
  const KnowledgePage({super.key});

  @override
  ConsumerState<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends ConsumerState<KnowledgePage> with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // Từ đồ thị bấm "Hỏi AI về mục này": sang tab hỏi và gửi luôn
  void _askAbout(String question) {
    _tabs.animateTo(0);
    ref.read(knowledgeChatProvider.notifier).send(question);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roles = ref.watch(authControllerProvider.select((s) => s.value?.roles ?? const <String>[]));
    void open(Widget page) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.knowledge),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.knowledgeMore,
            onSelected: (v) => switch (v) {
              'ontology' => open(const OntologyPage()),
              'sparql' => open(const SparqlPage()),
              _ => open(const ProposalsPage()),
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'ontology', child: Text(l10n.ontologyTitle)),
              PopupMenuItem(value: 'sparql', child: Text(l10n.sparqlTitle)),
              if (roles.any(proposalReviewerRoles.contains))
                PopupMenuItem(value: 'proposals', child: Text(l10n.proposalsTitle)),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l10n.knowledgeTabAsk),
            Tab(text: l10n.knowledgeTabSearch),
            Tab(text: l10n.knowledgeTabGraph),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        // Vuốt ngang để xoay, kéo đồ thị; đổi tab bằng thanh tab
        physics: const NeverScrollableScrollPhysics(),
        children: [const AskTab(), const SearchTab(), GraphTab(onAsk: _askAbout)],
      ),
    );
  }
}
