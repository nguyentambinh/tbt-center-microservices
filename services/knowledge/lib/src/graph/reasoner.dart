/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:knowledge_service/src/graph/ontology.dart';

/// Cạnh suy ra được từ luật nào, các cạnh nào làm tiền đề
class Derivation {
  const Derivation(this.rule, this.premises);

  final String rule;
  final List<Triple> premises;
}

class ReasoningResult {
  const ReasoningResult({
    required this.inferred,
    required this.rejected,
    required this.rounds,
  });

  final Map<Triple, Derivation> inferred;

  /// Cạnh luật sinh ra nhưng sai miền, phạm vi: luật hoặc dữ liệu mâu thuẫn
  final Map<Triple, String> rejected;
  final int rounds;
}

/// Suy luận tiến (forward chaining): áp luật tới khi không còn cạnh mới
class Reasoner {
  const Reasoner(
    this.ontology, {
    this.maxRounds = 30,
    this.maxInferred = 20000,
  });

  final Ontology ontology;
  final int maxRounds;
  final int maxInferred;

  ReasoningResult run(
    Iterable<Triple> asserted,
    String? Function(String node) classOf,
  ) {
    final known = asserted.toSet();
    final inferred = <Triple, Derivation>{};
    final rejected = <Triple, String>{};
    var rounds = 0;
    var changed = true;
    while (changed && rounds < maxRounds) {
      rounds++;
      changed = false;
      final index = _Index(known);
      for (final rule in ontology.rules) {
        for (final (t, premises) in _apply(rule, index)) {
          if (known.contains(t) || rejected.containsKey(t)) continue;
          final bad = ontology.violation(t, classOf);
          if (bad != null) {
            rejected[t] = '${rule.id}: $bad';
            continue;
          }
          known.add(t);
          inferred[t] = Derivation(rule.id, premises);
          changed = true;
          if (inferred.length >= maxInferred) {
            return ReasoningResult(
              inferred: inferred,
              rejected: rejected,
              rounds: rounds,
            );
          }
        }
      }
    }
    return ReasoningResult(
      inferred: inferred,
      rejected: rejected,
      rounds: rounds,
    );
  }

  Iterable<(Triple, List<Triple>)> _apply(KgRule rule, _Index ix) sync* {
    switch (rule.kind) {
      case RuleKind.transitive:
        for (final ab in ix.byRelation(rule.first)) {
          for (final bc in ix.outgoing(ab.target, rule.first)) {
            if (ab.source == bc.target) continue;
            yield (Triple(ab.source, rule.result, bc.target), [ab, bc]);
          }
        }
      case RuleKind.symmetric:
        for (final ab in ix.byRelation(rule.first)) {
          yield (Triple(ab.target, rule.result, ab.source), [ab]);
        }
      case RuleKind.inverse:
        for (final ab in ix.byRelation(rule.first)) {
          yield (Triple(ab.target, rule.result, ab.source), [ab]);
        }
      case RuleKind.subproperty:
        for (final ab in ix.byRelation(rule.first)) {
          yield (Triple(ab.source, rule.result, ab.target), [ab]);
        }
      case RuleKind.chain:
        final second = rule.second!;
        final backwards = second.startsWith('^');
        final rel = backwards ? second.substring(1) : second;
        for (final ab in ix.byRelation(rule.first)) {
          // Đi ngược: cạnh (c rel b) được dùng như (b ^rel c)
          final next = backwards
              ? ix.incoming(ab.target, rel)
              : ix.outgoing(ab.target, rel);
          for (final e in next) {
            final c = backwards ? e.source : e.target;
            if (c == ab.source) continue;
            yield (Triple(ab.source, rule.result, c), [ab, e]);
          }
        }
    }
  }
}

class _Index {
  _Index(Set<Triple> facts) {
    for (final t in facts) {
      (_byRelation[t.relation] ??= []).add(t);
      (_out['${t.source}|${t.relation}'] ??= []).add(t);
      (_in['${t.target}|${t.relation}'] ??= []).add(t);
    }
  }

  final _byRelation = <String, List<Triple>>{};
  final _out = <String, List<Triple>>{};
  final _in = <String, List<Triple>>{};

  List<Triple> byRelation(String r) => _byRelation[r] ?? const [];
  List<Triple> outgoing(String node, String r) => _out['$node|$r'] ?? const [];
  List<Triple> incoming(String node, String r) => _in['$node|$r'] ?? const [];
}
