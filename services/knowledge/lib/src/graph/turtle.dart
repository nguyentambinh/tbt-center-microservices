/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:knowledge_service/src/graph/ontology.dart';
import 'package:knowledge_service/src/graph/rdf.dart';

/// Xuất Turtle (RDF 1.1, OWL 2) để Protégé, rdflib đọc được
String toTurtle(GraphSnapshot g, {bool includeInferred = false}) {
  final b = StringBuffer()
    ..writeln('# Đồ thị tri thức TBT Center, sinh từ service knowledge')
    ..writeln('@prefix kg: <$kgNs> .')
    ..writeln('@prefix kgo: <$kgoNs> .')
    ..writeln('@prefix rdf: <$rdfNs> .')
    ..writeln('@prefix rdfs: <$rdfsNs> .')
    ..writeln('@prefix owl: <$owlNs> .')
    ..writeln()
    ..writeln('<${kgoNs.substring(0, kgoNs.length - 1)}> a owl:Ontology ;')
    ..writeln(
      '  rdfs:label "Bản thể học TBT Center"@vi, "TBT Center ontology"@en .',
    )
    ..writeln()
    ..writeln('kgo:domainIncludes a owl:AnnotationProperty ;')
    ..writeln(
      '  rdfs:comment "Một trong các lớp được làm chủ thể của quan hệ"@vi .',
    )
    ..writeln('kgo:rangeIncludes a owl:AnnotationProperty ;')
    ..writeln(
      '  rdfs:comment "Một trong các lớp được làm đối tượng của quan hệ"@vi .',
    )
    ..writeln();

  final o = g.ontology;
  for (final c in o.classes.values) {
    b.write('kgo:${c.id} a owl:Class');
    if (c.parent != null) b.write(' ;\n  rdfs:subClassOf kgo:${c.parent}');
    b
      ..write(_labels('rdfs:label', c.labels))
      ..writeln(' .');
  }
  b.writeln();

  // Luật chuỗi: (a first b) và (b second c) thì (a result c)
  final chains = <String, List<List<String>>>{};
  for (final r in o.rules.where((r) => r.kind == RuleKind.chain)) {
    final second = r.second!;
    (chains[r.result] ??= []).add([
      'kgo:${r.first}',
      if (second.startsWith('^'))
        '[ owl:inverseOf kgo:${second.substring(1)} ]'
      else
        'kgo:$second',
    ]);
  }
  for (final r in o.relations.values) {
    final types = [
      'owl:ObjectProperty',
      if (r.transitive) 'owl:TransitiveProperty',
      if (r.symmetric) 'owl:SymmetricProperty',
    ];
    b
      ..write('kgo:${r.id} a ${types.join(', ')}')
      ..write(
        ' ;\n  rdfs:domain ${_union(r.domain)} ;\n  rdfs:range '
        '${_union(r.range)}',
      );
    for (final d in r.domain) {
      b.write(' ;\n  kgo:domainIncludes kgo:$d');
    }
    for (final d in r.range) {
      b.write(' ;\n  kgo:rangeIncludes kgo:$d');
    }
    if (r.inverseOf != null) b.write(' ;\n  owl:inverseOf kgo:${r.inverseOf}');
    if (r.subPropertyOf != null) {
      b.write(' ;\n  rdfs:subPropertyOf kgo:${r.subPropertyOf}');
    }
    for (final chain in chains[r.id] ?? const <List<String>>[]) {
      b.write(' ;\n  owl:propertyChainAxiom ( ${chain.join(' ')} )');
    }
    b
      ..write(_labels('rdfs:label', r.labels))
      ..write(_labels('rdfs:comment', r.summaries))
      ..writeln(' .');
  }
  b.writeln();

  final byNode = <String, List<KgEdge>>{};
  for (final e in g.edges) {
    if (e.inferred && !includeInferred) continue;
    (byNode[e.triple.source] ??= []).add(e);
  }
  for (final n in g.nodes.values) {
    b
      ..write('kg:${n.id} a kgo:${n.classId}')
      ..write(_labels('rdfs:label', n.labels))
      ..write(_labels('rdfs:comment', n.summaries));
    final edges = byNode[n.id] ?? const <KgEdge>[];
    final byRelation = <String, List<String>>{};
    for (final e in edges) {
      (byRelation[e.triple.relation] ??= []).add('kg:${e.triple.target}');
    }
    for (final r in byRelation.entries) {
      b.write(' ;\n  kgo:${r.key} ${r.value.join(', ')}');
    }
    b.writeln(' .');
  }

  // Giá trị trên cạnh và câu trích: chú thích OWL (owl:Axiom) cho cạnh
  for (final e in g.edges) {
    final note = e.note ?? e.evidence;
    if (note == null || (e.inferred && !includeInferred)) continue;
    b
      ..writeln('[] a owl:Axiom ;')
      ..writeln('  owl:annotatedSource kg:${e.triple.source} ;')
      ..writeln('  owl:annotatedProperty kgo:${e.triple.relation} ;')
      ..writeln('  owl:annotatedTarget kg:${e.triple.target} ;')
      ..writeln('  rdfs:comment ${_string(note)} .');
  }
  return b.toString();
}

String _union(List<String> classes) => classes.length == 1
    ? 'kgo:${classes.first}'
    : '[ a owl:Class ; owl:unionOf '
          '( ${classes.map((c) => 'kgo:$c').join(' ')} ) ]';

String _labels(String predicate, Map<String, String> labels) {
  final values = [
    for (final l in labels.entries)
      if (l.value.isNotEmpty) '${_string(l.value)}@${l.key}',
  ];
  return values.isEmpty ? '' : ' ;\n  $predicate ${values.join(', ')}';
}

String _string(String s) {
  final escaped = s
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll('\n', r'\n');
  return '"$escaped"';
}
