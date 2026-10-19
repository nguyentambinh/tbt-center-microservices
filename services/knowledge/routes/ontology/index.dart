/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/graph/reasoning_service.dart';
import 'package:knowledge_service/src/graph/turtle.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /ontology?lang=vi  lớp, quan hệ, luật suy luận;
/// format=turtle trả RDF/OWL dạng Turtle (thêm inferred=true để kèm cạnh suy ra)
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final query = context.request.uri.queryParameters;
  final service = context.read<GraphReasoningService>();
  final g = await service.snapshot();
  if (query['format'] == 'turtle') {
    return Response(
      body: toTurtle(g, includeInferred: query['inferred'] == 'true'),
      headers: {
        HttpHeaders.contentTypeHeader: 'text/turtle; charset=utf-8',
        'content-disposition': 'inline; filename="tbt-center.ttl"',
      },
    );
  }
  final lang = query['lang'] ?? 'en';
  String label(Map<String, String> labels) =>
      labels[lang] ?? labels['en'] ?? '';
  final o = g.ontology;
  final counts = <String, int>{};
  for (final n in g.nodes.values) {
    counts[n.classId] = (counts[n.classId] ?? 0) + 1;
  }
  final edgeCounts = <String, int>{};
  for (final e in g.edges) {
    edgeCounts[e.triple.relation] = (edgeCounts[e.triple.relation] ?? 0) + 1;
  }
  return Response.json(
    body: {
      'classes': [
        for (final c in o.classes.values)
          {
            'id': c.id,
            'parent': c.parent,
            'label': label(c.labels),
            'nodes': counts[c.id] ?? 0,
          },
      ],
      'relations': [
        for (final r in o.relations.values)
          {
            'id': r.id,
            'label': label(r.labels),
            'summary': label(r.summaries),
            'domain': r.domain,
            'range': r.range,
            'transitive': r.transitive,
            'symmetric': r.symmetric,
            'inverseOf': r.inverseOf,
            'subPropertyOf': r.subPropertyOf,
            'derived': r.derived,
            'edges': edgeCounts[r.id] ?? 0,
          },
      ],
      'rules': [
        for (final r in o.rules)
          {
            'id': r.id,
            'kind': r.kind.name,
            'first': r.first,
            'second': r.second,
            'result': r.result,
            'visible': r.visible,
            'label': label(r.labels),
          },
      ],
      'totals': {
        'nodes': g.nodes.length,
        'edges': g.edges.length,
        'asserted': g.edges.where((e) => !e.inferred).length,
        'inferred': g.edges.where((e) => e.inferred).length,
        'extracted': g.edges.where((e) => e.origin == 'extracted').length,
      },
      'reasoning': service.last,
    },
  );
}
