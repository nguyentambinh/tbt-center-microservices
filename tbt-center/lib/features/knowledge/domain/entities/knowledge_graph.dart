/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

/// Loại nút trong đồ thị tri thức, quyết định màu vẽ
enum NodeType { concept, process, step, rule, role, service, technology, pattern, region, document }

class GraphNode {
  const GraphNode({
    required this.id,
    required this.type,
    required this.label,
    this.articleId,
    this.degree = 0,
    this.summary,
    this.className,
    this.classLabel,
    this.extracted = false,
  });

  factory GraphNode.fromJson(Map<String, dynamic> j) => GraphNode(
        id: j['id'] as String,
        type: NodeType.values.asNameMap()[j['type']] ?? NodeType.concept,
        label: j['label'] as String,
        articleId: j['articleId'] as String?,
        degree: j['degree'] as int? ?? 0,
        summary: j['summary'] as String?,
        className: j['class'] as String?,
        classLabel: j['classLabel'] as String?,
        extracted: j['extracted'] as bool? ?? false,
      );

  final String id;
  final NodeType type;
  final String label;
  final String? articleId;
  final int degree;
  final String? summary;

  /// Lớp trong bản thể học, ví dụ request là lớp con của concept
  final String? className;
  final String? classLabel;

  /// Nút do AI trích từ bài viết, HR đã duyệt
  final bool extracted;
}

class GraphEdge {
  const GraphEdge({
    required this.source,
    required this.target,
    required this.label,
    this.note,
    this.origin = 'curated',
    this.rule,
    this.because = const [],
    this.evidence,
  });

  factory GraphEdge.fromJson(Map<String, dynamic> j) => GraphEdge(
        source: j['source'] as String,
        target: j['target'] as String,
        label: j['label'] as String,
        note: j['note'] as String?,
        origin: j['origin'] as String? ?? 'curated',
        rule: j['rule'] as String?,
        because: [for (final b in j['because'] as List? ?? const []) b as String],
        evidence: j['evidence'] as String?,
      );

  final String source;
  final String target;
  final String label;
  final String? note;

  /// curated (người soạn), extracted (AI trích, HR duyệt), inferred (máy suy luận)
  final String origin;

  /// Tên luật đã sinh ra cạnh suy luận
  final String? rule;

  /// Các cạnh làm tiền đề cho cạnh suy luận
  final List<String> because;

  /// Câu trích trong bài làm bằng chứng cho cạnh AI trích xuất
  final String? evidence;

  bool get inferred => origin == 'inferred';
}

/// Một nút ở giữa và các nút quanh nó
class GraphView {
  const GraphView({required this.center, required this.nodes, required this.edges});

  final GraphNode center;
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  /// Bài viết giải thích nút giữa (chính nó là bài, hoặc nối tới bài)
  String? get articleId =>
      center.articleId ??
      [
        for (final e in edges)
          if (e.source == center.id)
            for (final n in nodes)
              if (n.id == e.target && n.type == NodeType.document) n.articleId,
      ].nonNulls.firstOrNull;
}

/// Đường ngắn nhất nối hai nút: mỗi bước là một cạnh (đi xuôi hoặc ngược) và nút tới
class GraphPath {
  const GraphPath({required this.from, required this.to, required this.steps});

  factory GraphPath.fromJson(Map<String, dynamic> j) => GraphPath(
        from: GraphNode.fromJson(j['from'] as Map<String, dynamic>),
        to: GraphNode.fromJson(j['to'] as Map<String, dynamic>),
        steps: [
          for (final s in (j['steps'] as List).cast<Map<String, dynamic>>())
            (
              node: GraphNode.fromJson(s['node'] as Map<String, dynamic>),
              edge: GraphEdge.fromJson(s['edge'] as Map<String, dynamic>),
              forward: s['forward'] as bool,
            ),
        ],
      );

  final GraphNode from;
  final GraphNode to;
  final List<({GraphNode node, GraphEdge edge, bool forward})> steps;
}
