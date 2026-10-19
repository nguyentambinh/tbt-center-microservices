/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

/// Bản thể học: cây lớp, quan hệ kèm miền, phạm vi, tính chất; luật suy luận
class OntologyInfo {
  const OntologyInfo({
    required this.classes,
    required this.relations,
    required this.rules,
    required this.totals,
    this.reasoning,
  });

  factory OntologyInfo.fromJson(Map<String, dynamic> j) => OntologyInfo(
        classes: [
          for (final c in (j['classes'] as List).cast<Map<String, dynamic>>())
            (
              id: c['id'] as String,
              parent: c['parent'] as String?,
              label: c['label'] as String,
              nodes: c['nodes'] as int? ?? 0,
            ),
        ],
        relations: [
          for (final r in (j['relations'] as List).cast<Map<String, dynamic>>())
            OntologyRelation(
              id: r['id'] as String,
              label: r['label'] as String,
              summary: r['summary'] as String? ?? '',
              domain: (r['domain'] as List).cast<String>(),
              range: (r['range'] as List).cast<String>(),
              transitive: r['transitive'] as bool? ?? false,
              symmetric: r['symmetric'] as bool? ?? false,
              inverseOf: r['inverseOf'] as String?,
              subPropertyOf: r['subPropertyOf'] as String?,
              derived: r['derived'] as bool? ?? false,
              edges: r['edges'] as int? ?? 0,
            ),
        ],
        rules: [
          for (final r in (j['rules'] as List).cast<Map<String, dynamic>>())
            (id: r['id'] as String, kind: r['kind'] as String, label: r['label'] as String),
        ],
        totals: {for (final e in (j['totals'] as Map<String, dynamic>).entries) e.key: e.value as int},
        reasoning: j['reasoning'] as Map<String, dynamic>?,
      );

  final List<({String id, String? parent, String label, int nodes})> classes;
  final List<OntologyRelation> relations;
  final List<({String id, String kind, String label})> rules;

  /// nodes, edges, asserted, inferred, extracted
  final Map<String, int> totals;
  final Map<String, dynamic>? reasoning;

  String classLabel(String id) => classes.where((c) => c.id == id).firstOrNull?.label ?? id;
}

class OntologyRelation {
  const OntologyRelation({
    required this.id,
    required this.label,
    required this.summary,
    required this.domain,
    required this.range,
    this.transitive = false,
    this.symmetric = false,
    this.inverseOf,
    this.subPropertyOf,
    this.derived = false,
    this.edges = 0,
  });

  final String id;
  final String label;
  final String summary;
  final List<String> domain;
  final List<String> range;
  final bool transitive;
  final bool symmetric;
  final String? inverseOf;
  final String? subPropertyOf;
  final bool derived;
  final int edges;
}

/// Một ô kết quả SPARQL: IRI (có nhãn nếu là nút, lớp, quan hệ) hoặc chuỗi
typedef SparqlCell = ({String value, String? label, bool iri});

class SparqlAnswer {
  const SparqlAnswer({required this.vars, required this.rows, required this.ms, this.truncated = false});

  factory SparqlAnswer.fromJson(Map<String, dynamic> j) => SparqlAnswer(
        vars: (j['vars'] as List).cast<String>(),
        rows: [
          for (final r in (j['rows'] as List).cast<Map<String, dynamic>>())
            {
              for (final e in r.entries)
                e.key: (
                  value: (e.value as Map)['value'] as String,
                  label: (e.value as Map)['label'] as String?,
                  iri: (e.value as Map)['type'] == 'iri',
                ),
            },
        ],
        ms: j['ms'] as int? ?? 0,
        truncated: j['truncated'] as bool? ?? false,
      );

  final List<String> vars;
  final List<Map<String, SparqlCell>> rows;
  final int ms;
  final bool truncated;
}

/// Đề xuất AI trích từ bài viết: một nút mới hoặc một cạnh mới, kèm câu trích làm bằng chứng
class GraphProposal {
  const GraphProposal({
    required this.id,
    required this.articleId,
    required this.kind,
    required this.payload,
    required this.status,
    this.evidence,
    this.confidence,
    this.reason,
    this.provider,
    this.model,
  });

  factory GraphProposal.fromJson(Map<String, dynamic> j) => GraphProposal(
        id: j['id'] as String,
        articleId: j['articleId'] as String,
        kind: j['kind'] as String,
        payload: j['payload'] as Map<String, dynamic>,
        status: j['status'] as String,
        evidence: j['evidence'] as String?,
        confidence: (j['confidence'] as num?)?.toDouble(),
        reason: j['reason'] as String?,
        provider: j['provider'] as String?,
        model: j['model'] as String?,
      );

  final String id;
  final String articleId;

  /// node hoặc edge
  final String kind;
  final Map<String, dynamic> payload;

  /// pending, approved, rejected, invalid
  final String status;
  final String? evidence;
  final double? confidence;
  final String? reason;
  final String? provider;
  final String? model;

  bool get isNode => kind == 'node';
}

class ProposalList {
  const ProposalList({required this.items, required this.running, required this.configured});

  final List<GraphProposal> items;

  /// AI đang đọc bài ở nền
  final bool running;
  final bool configured;
}
