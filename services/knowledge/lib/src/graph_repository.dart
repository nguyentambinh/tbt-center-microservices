/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'package:tbt_common/tbt_common.dart';

/// Một cạnh đã dịch nhãn: "Đơn nghỉ phép —do ai duyệt→ HR"
class GraphFact {
  const GraphFact({
    required this.source,
    required this.relation,
    required this.target,
    required this.sourceLabel,
    required this.relationLabel,
    required this.targetLabel,
    this.note,
    this.inferred = false,
  });

  final String source;
  final String relation;
  final String target;
  final String sourceLabel;
  final String relationLabel;
  final String targetLabel;
  final String? note;

  /// Cạnh do máy suy luận sinh ra, không phải người soạn
  final bool inferred;

  String get sentence {
    final rel = note == null ? relationLabel : '$relationLabel $note';
    return '$sourceLabel —$rel→ $targetLabel${inferred ? ' (inferred)' : ''}';
  }

  Map<String, dynamic> toJson() => {
    'source': source,
    'relation': relation,
    'target': target,
    'sourceLabel': sourceLabel,
    'relationLabel': relationLabel,
    'targetLabel': targetLabel,
    if (note != null) 'note': note,
    if (inferred) 'inferred': true,
  };
}

abstract interface class GraphRepository {
  /// Mọi nút (đồ thị nhỏ, dưới vài trăm nút) hoặc nút khớp [query]
  Future<List<Map<String, dynamic>>> nodes({
    required String lang,
    String? query,
  });

  /// Nút trung tâm, các nút cách nó tối đa [depth] bước và các cạnh giữa chúng
  Future<Map<String, dynamic>?> neighborhood(
    String id, {
    required String lang,
    int depth = 1,
  });

  /// Khái niệm nhắc tới trong câu hỏi, khớp theo tên gọi khác đã bỏ dấu
  Future<List<String>> linkEntities(String question);

  /// Các cạnh quanh [ids] (đi 2 bước) để đưa vào ngữ cảnh cho AI
  Future<List<GraphFact>> factsAround(
    List<String> ids, {
    required String lang,
    int limit = 24,
  });

  /// Bài viết giải thích các nút [ids], gần nhất xếp trước
  Future<List<String>> articlesFor(List<String> ids);

  /// Đường ngắn nhất từ [from] tới [to], đi cả hai chiều cạnh
  Future<Map<String, dynamic>?> path(
    String from,
    String to, {
    required String lang,
    int maxDepth = 6,
  });
}

class PostgresGraphRepository implements GraphRepository {
  PostgresGraphRepository(this._db);

  final Database _db;

  // Nhãn theo ngôn ngữ, thiếu thì lấy tiếng Anh
  static String _label(String column, String lang) =>
      "coalesce($column->>'$lang', $column->>'en')";

  static String _lang(String lang) =>
      const {'vi', 'en', 'de', 'pt'}.contains(lang) ? lang : 'en';

  // Cạnh người soạn, AI trích xuất, hoặc suy ra bằng luật được phép hiện
  static String _visible(String e) =>
      "($e.origin <> 'inferred' or exists (select 1 from kg_rules ru "
      'where ru.id = $e.rule_id and ru.visible))';

  // Số cạnh của nút, nút đông cạnh vẽ to hơn
  static final _degree =
      '(select count(*) from kg_edges e '
      'where (e.source = n.id or e.target = n.id) and ${_visible('e')})::int '
      'as degree';

  @override
  Future<List<Map<String, dynamic>>> nodes({
    required String lang,
    String? query,
  }) async {
    final l = _lang(lang);
    final q = query?.trim() ?? '';
    final rows = await _db.query(
      '''
      select n.id, n.type, n.class_id, ${_label('n.labels', l)} as label,
        n.article_id, n.origin, $_degree
      from kg_nodes n
      where @q = ''
        or kb_unaccent(lower(${_label('n.labels', l)}))
          like '%' || kb_unaccent(lower(@q)) || '%'
        or exists (select 1 from unnest(n.aliases) a
          where a like '%' || kb_unaccent(lower(@q)) || '%')
      order by degree desc, label limit 200''',
      params: {'q': q},
    );
    return [for (final r in rows) _node(r)];
  }

  @override
  Future<Map<String, dynamic>?> neighborhood(
    String id, {
    required String lang,
    int depth = 1,
  }) async {
    final l = _lang(lang);
    final center = await _db.query(
      '''
      select n.id, n.type, n.class_id, ${_label('n.labels', l)} as label,
        ${_label('n.summaries', l)} as summary, n.article_id, n.origin,
        ${_label('c.labels', l)} as class_label
      from kg_nodes n left join kg_classes c on c.id = n.class_id
      where n.id = @id''',
      params: {'id': id},
    );
    if (center.isEmpty) return null;
    final ids = await _reachable([id], depth.clamp(1, 3));
    final nodes = await _db.query(
      '''
      select n.id, n.type, n.class_id, ${_label('n.labels', l)} as label,
        n.article_id, n.origin, $_degree
      from kg_nodes n where n.id = any(@ids)''',
      params: {'ids': ids},
    );
    final edges = await _edges(
      'e.source = any(@ids) and e.target = any(@ids)',
      {'ids': ids},
      l,
    );
    final c = center.first;
    return {
      'center': {
        ..._node(c),
        'summary': (c['summary'] as String?)?.isEmpty ?? true
            ? null
            : c['summary'],
        'classLabel': c['class_label'],
      },
      'nodes': [for (final r in nodes) _node(r)],
      'edges': edges,
    };
  }

  /// Cạnh kèm nhãn; cạnh suy ra có tên luật và các cạnh tiền đề
  Future<List<Map<String, dynamic>>> _edges(
    String where,
    Map<String, Object?> params,
    String l,
  ) async {
    final rows = await _db.query(
      '''
      select e.source, e.relation, e.target, e.note, e.origin, e.premises,
        e.evidence, ${_label('r.labels', l)} as label,
        ${_label('ru.labels', l)} as rule_label
      from kg_edges e join kg_relations r on r.id = e.relation
        left join kg_rules ru on ru.id = e.rule_id
      where $where and ${_visible('e')}''',
      params: params,
    );
    final premiseNodes = <String>{};
    final premiseRelations = <String>{};
    for (final r in rows) {
      for (final p in (r['premises'] as List?) ?? const []) {
        final t = (p as List).cast<String>();
        premiseNodes.addAll([t[0], t[2]]);
        premiseRelations.add(t[1]);
      }
    }
    final names = <String, String>{};
    if (premiseNodes.isNotEmpty) {
      for (final r in await _db.query(
        'select id, ${_label('labels', l)} as label from kg_nodes '
        'where id = any(@ids) union all '
        'select id, ${_label('labels', l)} from kg_relations where id = '
        'any(@rels)',
        params: {
          'ids': premiseNodes.toList(),
          'rels': premiseRelations.toList(),
        },
      )) {
        names[r['id'] as String] = r['label'] as String;
      }
    }
    return [
      for (final e in rows)
        {
          'source': e['source'],
          'relation': e['relation'],
          'label': e['label'],
          'target': e['target'],
          if (e['note'] != null) 'note': e['note'],
          'origin': e['origin'],
          if (e['evidence'] != null) 'evidence': e['evidence'],
          if (e['origin'] == 'inferred') ...{
            'rule': e['rule_label'],
            'because': [
              for (final p in (e['premises'] as List?) ?? const [])
                switch ((p as List).cast<String>()) {
                  [final s, final rel, final t] =>
                    '${names[s] ?? s} —${names[rel] ?? rel}→ ${names[t] ?? t}',
                  _ => '$p',
                },
            ],
          },
        },
    ];
  }

  @override
  Future<Map<String, dynamic>?> path(
    String from,
    String to, {
    required String lang,
    int maxDepth = 6,
  }) async {
    if (from == to) return null;
    // Tìm theo chiều rộng (BFS) từ [from], nhớ cạnh đã dẫn tới mỗi nút
    final cameFrom = <String, (String, Map<String, dynamic>)>{};
    var frontier = {from};
    final seen = {from};
    for (var depth = 0; depth < maxDepth && frontier.isNotEmpty; depth++) {
      final rows = await _db.query(
        'select e.source, e.relation, e.target from kg_edges e '
        'where (e.source = any(@ids) or e.target = any(@ids)) and e.relation '
        "<> 'explained_in' "
        'and ${_visible('e')}',
        params: {'ids': frontier.toList()},
      );
      final next = <String>{};
      for (final r in rows) {
        final s = r['source'] as String;
        final t = r['target'] as String;
        for (final (a, b) in [(s, t), (t, s)]) {
          if (frontier.contains(a) && seen.add(b)) {
            cameFrom[b] = (a, r);
            next.add(b);
          }
        }
      }
      if (seen.contains(to)) break;
      frontier = next;
    }
    if (!seen.contains(to)) return null;
    final hops = <Map<String, dynamic>>[];
    for (var at = to; at != from; at = cameFrom[at]!.$1) {
      hops.insert(0, cameFrom[at]!.$2);
    }
    final ids = {
      from,
      for (final h in hops) ...[h['source'] as String, h['target'] as String],
    };
    final nodes = await _db.query(
      'select n.id, n.type, n.class_id, ${_label('n.labels', _lang(lang))} as '
      'label, '
      'n.article_id, n.origin from kg_nodes n where n.id = any(@ids)',
      params: {'ids': ids.toList()},
    );
    final byId = {for (final n in nodes) n['id'] as String: _node(n)};
    final edges = await _edges(
      '(e.source, e.relation, e.target) in (select * from unnest(@s::text[], '
      '@r::text[], @t::text[]))',
      {
        's': [for (final h in hops) h['source']],
        'r': [for (final h in hops) h['relation']],
        't': [for (final h in hops) h['target']],
      },
      _lang(lang),
    );
    String key(Map<String, dynamic> e) =>
        '${e['source']}|${e['relation']}|${e['target']}';
    final edgeByKey = {for (final e in edges) key(e): e};
    final steps = <Map<String, dynamic>>[];
    var at = from;
    for (final h in hops) {
      final forward = h['source'] == at;
      final next = (forward ? h['target'] : h['source']) as String;
      steps.add({
        'node': byId[next],
        'edge': edgeByKey[key(h)],
        'forward': forward,
      });
      at = next;
    }
    return {'from': byId[from], 'to': byId[to], 'steps': steps};
  }

  @override
  Future<List<String>> linkEntities(String question) async {
    // Khớp nguyên cụm từ, tránh "ca" khớp nhầm "cach"
    final rows = await _db.query(
      '''
      select n.id, max(length(a)) as len
      from kg_nodes n, unnest(n.aliases) a
      where n.type <> 'document' and length(a) >= 3
        and ' ' || regexp_replace(kb_unaccent(lower(@q)),
          '[^a-z0-9,%]+', ' ', 'g') || ' ' like '% ' || a || ' %'
      group by n.id order by len desc limit 6''',
      params: {'q': question},
    );
    return [for (final r in rows) r['id'] as String];
  }

  @override
  Future<List<GraphFact>> factsAround(
    List<String> ids, {
    required String lang,
    int limit = 24,
  }) async {
    if (ids.isEmpty) return const [];
    final l = _lang(lang);
    // Cạnh chạm nút gốc xếp trước, cạnh cách 2 bước xếp sau
    final rows = await _db.query(
      '''
      with hop1 as (
        select distinct case when source = any(@ids) then target
          else source end as id
        from kg_edges where source = any(@ids) or target = any(@ids))
      select e.source, e.relation, e.target, e.note, e.origin,
        ${_label('s.labels', l)} as s_label,
        ${_label('r.labels', l)} as r_label,
        ${_label('t.labels', l)} as t_label,
        case when e.source = any(@ids) or e.target = any(@ids)
          then 0 else 1 end as hop
      from kg_edges e
        join kg_nodes s on s.id = e.source
        join kg_nodes t on t.id = e.target
        join kg_relations r on r.id = e.relation
      where e.relation <> 'explained_in' and ${_visible('e')}
        and (e.source = any(@ids) or e.target = any(@ids)
          or (e.source in (select id from hop1)
            and t.type in ('rule', 'role', 'step')))
      order by hop, e.source, e.relation limit @limit''',
      params: {'ids': ids, 'limit': limit},
    );
    return [
      for (final r in rows)
        GraphFact(
          source: r['source'] as String,
          relation: r['relation'] as String,
          target: r['target'] as String,
          sourceLabel: r['s_label'] as String,
          relationLabel: r['r_label'] as String,
          targetLabel: r['t_label'] as String,
          note: r['note'] as String?,
          inferred: r['origin'] == 'inferred',
        ),
    ];
  }

  @override
  Future<List<String>> articlesFor(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await _db.query(
      '''
      select d.article_id,
        min(case when e.source = any(@ids) then 0 else 1 end) as hop
      from kg_edges e
        join kg_nodes d on d.id = e.target and d.type = 'document'
      where e.relation = 'explained_in'
        and (e.source = any(@ids) or e.source in (
          select target from kg_edges where source = any(@ids)
          union select source from kg_edges where target = any(@ids)))
      group by d.article_id order by hop, d.article_id limit 6''',
      params: {'ids': ids},
    );
    return [for (final r in rows) r['article_id'] as String];
  }

  Future<List<String>> _reachable(List<String> start, int depth) async {
    var frontier = start.toSet();
    final seen = {...start};
    for (var i = 0; i < depth && frontier.isNotEmpty; i++) {
      final rows = await _db.query(
        'select target as id from kg_edges e where source = any(@ids) and '
        '${_visible('e')} '
        'union select source from kg_edges e where target = any(@ids) and '
        '${_visible('e')}',
        params: {'ids': frontier.toList()},
      );
      frontier = {for (final r in rows) r['id'] as String}.difference(seen);
      // Nút đông cạnh (vai trò, service) không lan tiếp để hình không rối
      if (seen.length + frontier.length > 40) {
        seen.addAll(frontier.take(40 - seen.length));
        break;
      }
      seen.addAll(frontier);
    }
    return seen.toList();
  }

  static Map<String, dynamic> _node(Map<String, dynamic> r) => {
    'id': r['id'],
    'type': r['type'],
    if (r['class_id'] != null) 'class': r['class_id'],
    if (r['origin'] == 'extracted') 'extracted': true,
    'label': r['label'],
    if (r['article_id'] != null) 'articleId': r['article_id'],
    if (r['degree'] != null) 'degree': r['degree'],
  };
}
