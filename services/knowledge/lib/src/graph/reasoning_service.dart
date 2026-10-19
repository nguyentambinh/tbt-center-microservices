/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'dart:async';
import 'dart:io';

import 'package:knowledge_service/src/graph/graph_store.dart';
import 'package:knowledge_service/src/graph/rdf.dart';
import 'package:knowledge_service/src/graph/reasoner.dart';
import 'package:knowledge_service/src/graph/sparql.dart';

/// Suy luận trên toàn đồ thị, ghi cạnh suy ra; giữ ảnh chụp cho SPARQL
class GraphReasoningService {
  GraphReasoningService(
    this.store, {
    this.cacheFor = const Duration(seconds: 30),
  });

  final GraphStore store;
  final Duration cacheFor;

  Future<Map<String, dynamic>>? _current;
  Map<String, dynamic>? last;
  ({GraphSnapshot graph, DateTime at})? _cached;

  /// Lượt đang chạy thì chờ lượt đó, không chạy chồng
  Future<Map<String, dynamic>> run() =>
      _current ??= _run().whenComplete(() => _current = null);

  Future<Map<String, dynamic>> _run() async {
    final watch = Stopwatch()..start();
    final g = await store.load();
    final result = Reasoner(g.ontology).run(g.asserted, g.classOf);
    await store.replaceInferred(result.inferred);
    _cached = null;
    final byRule = <String, int>{};
    for (final d in result.inferred.values) {
      byRule[d.rule] = (byRule[d.rule] ?? 0) + 1;
    }
    final stats = {
      'nodes': g.nodes.length,
      'asserted': g.asserted.length,
      'inferred': result.inferred.length,
      'byRule': byRule,
      'rejected': [
        for (final r in result.rejected.entries)
          {'triple': r.key.toJson(), 'reason': r.value},
      ],
      'rounds': result.rounds,
      'ms': watch.elapsedMilliseconds,
      'at': DateTime.now().toUtc().toIso8601String(),
    };
    last = stats;
    stdout.writeln(
      'Suy luận: ${result.inferred.length} cạnh mới từ ${stats['asserted']} '
      'cạnh, '
      '${result.rounds} vòng, ${result.rejected.length} cạnh bị loại, '
      '${stats['ms']} ms',
    );
    return stats;
  }

  /// Chạy lần đầu khi service bật; CSDL chưa sẵn sàng thì thử lại sau
  void startAtBoot() {
    Future<void> attempt(int n) async {
      try {
        await run();
      } on Object catch (error) {
        stderr.writeln('Suy luận lúc khởi động lỗi (lần $n): $error');
        if (n < 10) {
          Timer(const Duration(seconds: 15), () => unawaited(attempt(n + 1)));
        }
      }
    }

    unawaited(attempt(1));
  }

  Future<GraphSnapshot> snapshot() async {
    final c = _cached;
    if (c != null && DateTime.now().difference(c.at) < cacheFor) return c.graph;
    final g = await store.load();
    _cached = (graph: g, at: DateTime.now());
    return g;
  }

  void invalidate() => _cached = null;

  Future<SparqlResult> sparql(
    String query, {
    bool includeInferred = true,
  }) async {
    final g = await snapshot();
    return SparqlEngine(
      TripleStore(g.rdfTriples(includeInferred: includeInferred)),
    ).query(query);
  }
}
