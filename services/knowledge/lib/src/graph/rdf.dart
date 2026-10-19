/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:knowledge_service/src/graph/ontology.dart';
import 'package:meta/meta.dart';

const kgNs = 'http://tbt-center.local/kg/';
const kgoNs = 'http://tbt-center.local/ontology#';
const rdfNs = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
const rdfsNs = 'http://www.w3.org/2000/01/rdf-schema#';
const owlNs = 'http://www.w3.org/2002/07/owl#';
const xsdNs = 'http://www.w3.org/2001/XMLSchema#';

const prefixes = {
  'kg': kgNs,
  'kgo': kgoNs,
  'rdf': rdfNs,
  'rdfs': rdfsNs,
  'owl': owlNs,
  'xsd': xsdNs,
};

const rdfType = '${rdfNs}type';
const rdfsLabel = '${rdfsNs}label';

/// Một giá trị RDF: IRI hoặc chuỗi (có thể kèm ngôn ngữ)
sealed class Term {
  const Term();
}

@immutable
class Iri extends Term {
  const Iri(this.value);

  final String value;

  /// Dạng rút gọn kg:..., kgo:... cho dễ đọc
  String get compact {
    for (final p in prefixes.entries) {
      if (value.startsWith(p.value) && value.length > p.value.length) {
        return '${p.key}:${value.substring(p.value.length)}';
      }
    }
    return '<$value>';
  }

  @override
  bool operator ==(Object other) => other is Iri && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => compact;
}

@immutable
class Lit extends Term {
  const Lit(this.value, [this.lang]);

  final String value;
  final String? lang;

  @override
  bool operator ==(Object other) =>
      other is Lit && other.value == value && other.lang == lang;

  @override
  int get hashCode => Object.hash(value, lang);

  @override
  String toString() => lang == null ? '"$value"' : '"$value"@$lang';
}

/// Nút của đồ thị như lưu trong CSDL
class KgNode {
  const KgNode({
    required this.id,
    required this.classId,
    required this.type,
    required this.labels,
    this.summaries = const {},
    this.aliases = const [],
    this.origin = 'curated',
    this.articleId,
  });

  final String id;
  final String classId;
  final String type;
  final Map<String, String> labels;
  final Map<String, String> summaries;
  final List<String> aliases;
  final String origin;
  final String? articleId;

  String label(String lang) => labels[lang] ?? labels['en'] ?? id;
}

class KgEdge {
  const KgEdge(
    this.triple, {
    this.origin = 'curated',
    this.note,
    this.ruleId,
    this.premises = const [],
    this.evidence,
    this.articleId,
  });

  final Triple triple;
  final String origin;
  final String? note;
  final String? ruleId;
  final List<Triple> premises;
  final String? evidence;
  final String? articleId;

  bool get inferred => origin == 'inferred';
}

/// Ảnh chụp toàn đồ thị: dùng cho suy luận, SPARQL, xuất Turtle
class GraphSnapshot {
  GraphSnapshot({
    required this.ontology,
    required List<KgNode> nodes,
    required this.edges,
  }) : nodes = {for (final n in nodes) n.id: n};

  final Ontology ontology;
  final Map<String, KgNode> nodes;
  final List<KgEdge> edges;

  String? classOf(String id) => nodes[id]?.classId;

  Iterable<Triple> get asserted =>
      edges.where((e) => !e.inferred).map((e) => e.triple);

  /// Nhãn của một IRI trong đồ thị (nút, lớp, quan hệ)
  String? labelOf(Iri iri, String lang) {
    if (iri.value.startsWith(kgNs)) {
      return nodes[iri.value.substring(kgNs.length)]?.label(lang);
    }
    if (iri.value.startsWith(kgoNs)) {
      final id = iri.value.substring(kgoNs.length);
      final labels =
          ontology.classes[id]?.labels ?? ontology.relations[id]?.labels;
      return labels?[lang] ?? labels?['en'];
    }
    return null;
  }

  /// Bộ ba RDF: nút thuộc mọi lớp cha (suy luận RDFS), kèm cạnh suy ra
  List<(Term, Iri, Term)> rdfTriples({bool includeInferred = true}) {
    final out = <(Term, Iri, Term)>[];
    Iri kgo(String id) => Iri('$kgoNs$id');
    for (final c in ontology.classes.values) {
      out.add((kgo(c.id), const Iri(rdfType), const Iri('${owlNs}Class')));
      for (final a in ontology.ancestors(c.id).skip(1)) {
        out.add((kgo(c.id), const Iri('${rdfsNs}subClassOf'), kgo(a)));
      }
      for (final l in c.labels.entries) {
        out.add((kgo(c.id), const Iri(rdfsLabel), Lit(l.value, l.key)));
      }
    }
    for (final r in ontology.relations.values) {
      final s = kgo(r.id);
      out.add((s, const Iri(rdfType), const Iri('${owlNs}ObjectProperty')));
      if (r.transitive) {
        out.add((
          s,
          const Iri(rdfType),
          const Iri('${owlNs}TransitiveProperty'),
        ));
      }
      if (r.symmetric) {
        out.add((
          s,
          const Iri(rdfType),
          const Iri('${owlNs}SymmetricProperty'),
        ));
      }
      if (r.inverseOf case final inv?) {
        out.add((kgo(inv), const Iri('${owlNs}inverseOf'), s));
      }
      if (r.subPropertyOf case final sup?) {
        out.add((s, const Iri('${rdfsNs}subPropertyOf'), kgo(sup)));
      }
      for (final d in r.domain) {
        out.add((s, const Iri('${kgoNs}domainIncludes'), kgo(d)));
      }
      for (final d in r.range) {
        out.add((s, const Iri('${kgoNs}rangeIncludes'), kgo(d)));
      }
      for (final l in r.labels.entries) {
        out.add((s, const Iri(rdfsLabel), Lit(l.value, l.key)));
      }
    }
    for (final n in nodes.values) {
      final s = Iri('$kgNs${n.id}');
      for (final c in ontology.ancestors(n.classId)) {
        out.add((s, const Iri(rdfType), kgo(c)));
      }
      for (final l in n.labels.entries) {
        out.add((s, const Iri(rdfsLabel), Lit(l.value, l.key)));
      }
      for (final l in n.summaries.entries) {
        if (l.value.isNotEmpty) {
          out.add((s, const Iri('${rdfsNs}comment'), Lit(l.value, l.key)));
        }
      }
    }
    for (final e in edges) {
      if (e.inferred && !includeInferred) continue;
      out.add((
        Iri('$kgNs${e.triple.source}'),
        kgo(e.triple.relation),
        Iri('$kgNs${e.triple.target}'),
      ));
    }
    return out;
  }
}
