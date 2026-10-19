/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/locale/locale_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ontology.dart';
import '../providers/knowledge_providers.dart';

/// Câu mẫu: tên hiển thị và câu SPARQL
List<(String, String)> sparqlSamples(AppLocalizations l10n) => [
      (l10n.sparqlSampleInvolves, 'SELECT ?service WHERE {\n  kg:payroll-closing kgo:involves ?service\n} ORDER BY ?service'),
      (l10n.sparqlSampleViewers, 'SELECT ?role WHERE {\n  ?role kgo:can_view kg:net-pay\n} ORDER BY ?role'),
      (l10n.sparqlSampleBefore, 'SELECT ?step WHERE {\n  ?step kgo:next_step+ kg:step-pay\n} ORDER BY ?step'),
      (l10n.sparqlSampleRabbit, 'SELECT ?service WHERE {\n  ?service kgo:uses kg:tech-rabbitmq ;\n    a kgo:service\n}'),
      (
        l10n.sparqlSampleCount,
        'SELECT ?place (COUNT(?s) AS ?n) WHERE {\n  ?s a kgo:service ; kgo:runs_in ?place\n} GROUP BY ?place ORDER BY DESC(?n)'
      ),
    ];

/// Truy vấn đồ thị bằng SPARQL: gõ câu hoặc chọn câu mẫu, xem bảng kết quả
class SparqlPage extends ConsumerStatefulWidget {
  const SparqlPage({super.key});

  @override
  ConsumerState<SparqlPage> createState() => _SparqlPageState();
}

class _SparqlPageState extends ConsumerState<SparqlPage> {
  final _query = TextEditingController();
  bool _inferred = true;
  bool _busy = false;
  SparqlAnswer? _answer;
  String? _error;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final text = _query.text.trim();
    if (text.isEmpty || _busy) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final answer = await ref
          .read(knowledgeRepositoryProvider)
          .sparql(text, lang: ref.read(appLocaleProvider).languageCode, inferred: _inferred);
      if (mounted) setState(() => _answer = answer);
    } on AppFailure catch (e) {
      // Câu sai cú pháp thì báo ngay dưới ô nhập; lỗi mạng để thanh kết nối lo
      if (e.serverCode == 'bad_query') {
        if (mounted) setState(() => _error = AppLocalizations.of(context).errSparqlSyntax);
      } else {
        reportFailure(e);
      }
    } on Object catch (e) {
      reportFailure(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final answer = _answer;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sparqlTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final (name, q) in sparqlSamples(l10n))
                ActionChip(
                  label: Text(name, style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    _query.text = q;
                    _run();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _query,
            minLines: 4,
            maxLines: 10,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(hintText: l10n.sparqlHint),
          ),
          if (_error case final message?) ...[
            const SizedBox(height: 6),
            Text(l10n.sparqlError(message), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _inferred,
                  onChanged: (v) => setState(() => _inferred = v),
                  title: Text(l10n.sparqlIncludeInferred, style: const TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _busy ? null : _run,
                icon: _busy
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.play_arrow),
                label: Text(l10n.sparqlRun),
              ),
            ],
          ),
          if (answer != null) ...[
            const SizedBox(height: 8),
            Text(l10n.sparqlRows(answer.rows.length, answer.ms), style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            if (answer.rows.isEmpty)
              Padding(padding: const EdgeInsets.all(24), child: EmptyView(message: l10n.sparqlNoRows))
            else
              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    columns: [for (final v in answer.vars) DataColumn(label: Text('?$v'))],
                    rows: [
                      for (final row in answer.rows)
                        DataRow(
                          cells: [
                            for (final v in answer.vars)
                              DataCell(
                                switch (row[v]) {
                                  null => const Text(''),
                                  final c => Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.label ?? c.value),
                                        if (c.label != null)
                                          Text(c.value,
                                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                      ],
                                    ),
                                },
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
