/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'dart:convert';

import 'package:knowledge_service/src/graph/ontology.dart';
import 'package:knowledge_service/src/graph/rdf.dart';
import 'package:knowledge_service/src/graph/reasoner.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Bài viết đưa cho AI trích xuất
typedef ArticleText = ({
  String id,
  String lang,
  String title,
  String body,
  String hash,
});

abstract interface class GraphStore {
  Future<GraphSnapshot> load();

  /// Thay toàn bộ cạnh suy ra bằng kết quả mới trong một giao dịch
  Future<void> replaceInferred(Map<Triple, Derivation> inferred);

  /// Bài chưa trích xuất hoặc đã sửa sau lần trích xuất trước
  Future<List<ArticleText>> articlesToExtract({String? articleId});

  Future<void> saveProposals({
    required ArticleText article,
    required String provider,
    required String? model,
    required List<Map<String, dynamic>> proposals,
  });

  Future<List<Map<String, dynamic>>> proposals({String? status, int limit});

  Future<Map<String, dynamic>?> proposal(String id);

  /// Duyệt: thêm nút, cạnh vào đồ thị (origin = extracted)
  Future<void> approve(
    List<Map<String, dynamic>> proposals, {
    required String reviewer,
  });

  Future<void> reject(
    List<String> ids, {
    required String reviewer,
    String? reason,
  });
}

class PostgresGraphStore implements GraphStore {
  PostgresGraphStore(this._db);

  final Database _db;

  static Map<String, String> _map(Object? j) => {
    for (final e in ((j as Map?) ?? const {}).entries) '${e.key}': '${e.value}',
  };

  @override
  Future<GraphSnapshot> load() async {
    final rows = await Future.wait([
      _db.query('select id, parent, labels from kg_classes', fromPrimary: true),
      _db.query(
        'select id, labels, summaries, domain, range, is_transitive, '
        'is_symmetric, '
        'inverse_of, sub_property_of, derived from kg_relations',
        fromPrimary: true,
      ),
      _db.query(
        'select id, kind, first, second, result, visible, labels from kg_rules '
        'order by ordinal',
        fromPrimary: true,
      ),
      _db.query(
        "select id, coalesce(class_id, 'concept') as class_id, type, labels, "
        'summaries, aliases, origin, article_id from kg_nodes',
        fromPrimary: true,
      ),
      _db.query(
        'select source, relation, target, origin, note, rule_id, premises, '
        'evidence, article_id from kg_edges',
        fromPrimary: true,
      ),
    ]);
    final ontology = Ontology(
      classes: [
        for (final r in rows[0])
          KgClass(r['id'] as String, r['parent'] as String?, _map(r['labels'])),
      ],
      relations: [
        for (final r in rows[1])
          KgRelation(
            id: r['id'] as String,
            labels: _map(r['labels']),
            summaries: _map(r['summaries']),
            domain: (r['domain'] as List).cast<String>(),
            range: (r['range'] as List).cast<String>(),
            transitive: r['is_transitive'] as bool,
            symmetric: r['is_symmetric'] as bool,
            inverseOf: r['inverse_of'] as String?,
            subPropertyOf: r['sub_property_of'] as String?,
            derived: r['derived'] as bool,
          ),
      ],
      rules: [
        for (final r in rows[2])
          KgRule(
            id: r['id'] as String,
            kind: RuleKind.values.byName(r['kind'] as String),
            first: r['first'] as String,
            second: r['second'] as String?,
            result: r['result'] as String,
            visible: r['visible'] as bool,
            labels: _map(r['labels']),
          ),
      ],
    );
    return GraphSnapshot(
      ontology: ontology,
      nodes: [
        for (final r in rows[3])
          KgNode(
            id: r['id'] as String,
            classId: r['class_id'] as String,
            type: r['type'] as String,
            labels: _map(r['labels']),
            summaries: _map(r['summaries']),
            aliases: (r['aliases'] as List).cast<String>(),
            origin: r['origin'] as String,
            articleId: r['article_id'] as String?,
          ),
      ],
      edges: [
        for (final r in rows[4])
          KgEdge(
            Triple(
              r['source'] as String,
              r['relation'] as String,
              r['target'] as String,
            ),
            origin: r['origin'] as String,
            note: r['note'] as String?,
            ruleId: r['rule_id'] as String?,
            premises: [
              for (final p in (r['premises'] as List?) ?? const [])
                Triple.fromJson(p as List),
            ],
            evidence: r['evidence'] as String?,
            articleId: r['article_id'] as String?,
          ),
      ],
    );
  }

  @override
  Future<void> replaceInferred(Map<Triple, Derivation> inferred) =>
      _db.transaction((tx) async {
        await tx.execute("delete from kg_edges where origin = 'inferred'");
        final list = inferred.entries.toList();
        // Ghi theo lô 500 cạnh mỗi câu lệnh
        for (var i = 0; i < list.length; i += 500) {
          final chunk = list.sublist(
            i,
            i + 500 > list.length ? list.length : i + 500,
          );
          await tx.execute(
            Sql.named(
              'insert into kg_edges (source, relation, target, origin, '
              'rule_id, premises) '
              "select s, r, t, 'inferred', rule, p::jsonb "
              'from unnest(@s::text[], @r::text[], @t::text[], @rule::text[], '
              '@p::text[]) '
              'as x(s, r, t, rule, p) on conflict do nothing',
            ),
            parameters: {
              's': [for (final e in chunk) e.key.source],
              'r': [for (final e in chunk) e.key.relation],
              't': [for (final e in chunk) e.key.target],
              'rule': [for (final e in chunk) e.value.rule],
              'p': [
                for (final e in chunk)
                  jsonEncode([for (final t in e.value.premises) t.toJson()]),
              ],
            },
          );
        }
      });

  @override
  Future<List<ArticleText>> articlesToExtract({String? articleId}) async {
    final rows = await _db.query(
      "select a.id, a.lang, a.title, a.body, md5(a.title || '. ' || a.body) as "
      'hash '
      'from articles a left join kg_extractions x on x.article_id = a.id and '
      'x.lang = a.lang '
      // Mỗi bài đọc một bản: tiếng Việt nếu có, không thì tiếng Anh
      'where a.lang = (select case when exists (select 1 from articles b '
      "where b.id = a.id and b.lang = 'vi') then 'vi' else 'en' end) "
      'and (@id::text is not null and a.id = @id '
      'or @id::text is null and (x.content_hash is null or x.content_hash <> '
      "md5(a.title || '. ' || a.body))) "
      'order by a.id',
      params: {'id': articleId},
      fromPrimary: true,
    );
    return [
      for (final r in rows)
        (
          id: r['id'] as String,
          lang: r['lang'] as String,
          title: r['title'] as String,
          body: r['body'] as String,
          hash: r['hash'] as String,
        ),
    ];
  }

  @override
  Future<void> saveProposals({
    required ArticleText article,
    required String provider,
    required String? model,
    required List<Map<String, dynamic>> proposals,
  }) => _db.transaction((tx) async {
    // Đề xuất cũ chưa duyệt của bài này bỏ đi, thay bằng lượt đọc mới
    await tx.execute(
      Sql.named(
        "update kg_proposals set status = 'rejected', reason = 'superseded', "
        "reviewed_at = now() where article_id = @id and status in ('pending', "
        "'invalid')",
      ),
      parameters: {'id': article.id},
    );
    final batch = await tx.execute('select gen_random_uuid()::text as id');
    final batchId = batch.first.toColumnMap()['id'] as String;
    for (final p in proposals) {
      await tx.execute(
        Sql.named(
          'insert into kg_proposals (batch, article_id, lang, kind, payload, '
          'evidence, '
          'confidence, status, reason, provider, model) values (@batch::uuid, '
          '@article, '
          '@lang, @kind, @payload::jsonb, @evidence, @confidence, @status, '
          '@reason, '
          '@provider, @model)',
        ),
        parameters: {
          'batch': batchId,
          'article': article.id,
          'lang': article.lang,
          'kind': p['kind'],
          'payload': jsonEncode(p['payload']),
          'evidence': p['evidence'],
          'confidence': (p['confidence'] as num?)?.toDouble(),
          'status': p['status'],
          'reason': p['reason'],
          'provider': provider,
          'model': model,
        },
      );
    }
    await tx.execute(
      Sql.named(
        'insert into kg_extractions (article_id, lang, content_hash, provider, '
        'model, proposals) '
        'values (@id, @lang, @hash, @provider, @model, @n) on conflict '
        '(article_id, lang) do update '
        'set content_hash = excluded.content_hash, provider = '
        'excluded.provider, '
        'model = excluded.model, proposals = excluded.proposals, extracted_at '
        '= now()',
      ),
      parameters: {
        'id': article.id,
        'lang': article.lang,
        'hash': article.hash,
        'provider': provider,
        'model': model,
        'n': proposals.length,
      },
    );
  });

  static Map<String, dynamic> _proposalJson(Map<String, dynamic> r) => {
    'id': r['id'],
    'batch': r['batch'],
    'articleId': r['article_id'],
    'lang': r['lang'],
    'kind': r['kind'],
    'payload': r['payload'],
    'evidence': r['evidence'],
    'confidence': r['confidence'],
    'status': r['status'],
    'reason': r['reason'],
    'provider': r['provider'],
    'model': r['model'],
    'createdAt': (r['created_at'] as DateTime).toIso8601String(),
    'reviewedBy': r['reviewed_by'],
  };

  static const _proposalColumns =
      'id::text, batch::text, article_id, lang, kind, payload, evidence, '
      'confidence, '
      'status, reason, provider, model, created_at, reviewed_by';

  @override
  Future<List<Map<String, dynamic>>> proposals({
    String? status,
    int limit = 200,
  }) async {
    final rows = await _db.query(
      'select $_proposalColumns from kg_proposals '
      'where (@status::text is null or status = @status) '
      // Nút trước cạnh trong cùng bài để duyệt theo thứ tự
      "order by status = 'pending' desc, created_at desc, article_id, kind "
      'desc, '
      'confidence desc nulls last limit @limit',
      params: {'status': status, 'limit': limit},
      fromPrimary: true,
    );
    return [for (final r in rows) _proposalJson(r)];
  }

  @override
  Future<Map<String, dynamic>?> proposal(String id) async {
    final rows = await _db.query(
      'select $_proposalColumns from kg_proposals where id = @id::uuid',
      params: {'id': id},
      fromPrimary: true,
    );
    return rows.isEmpty ? null : _proposalJson(rows.first);
  }

  @override
  Future<void> approve(
    List<Map<String, dynamic>> proposals, {
    required String reviewer,
  }) => _db.transaction((tx) async {
    for (final p in proposals.where((p) => p['kind'] == 'node')) {
      final n = p['payload'] as Map<String, dynamic>;
      await tx.execute(
        Sql.named(
          'insert into kg_nodes (id, type, class_id, labels, summaries, '
          'aliases, origin) '
          'values (@id, @type, @class, @labels::jsonb, @summaries::jsonb, '
          "@aliases, 'extracted') "
          'on conflict (id) do nothing',
        ),
        parameters: {
          'id': n['id'],
          'type': n['type'],
          'class': n['class'],
          'labels': jsonEncode(n['labels']),
          'summaries': jsonEncode(n['summaries'] ?? const {}),
          'aliases': (n['aliases'] as List? ?? const []).cast<String>(),
        },
      );
    }
    for (final p in proposals.where((p) => p['kind'] == 'edge')) {
      final e = p['payload'] as Map<String, dynamic>;
      await tx.execute(
        Sql.named(
          'insert into kg_edges (source, relation, target, origin, evidence, '
          'article_id) '
          "values (@s, @r, @t, 'extracted', @evidence, @article) "
          'on conflict (source, relation, target) do update set origin = '
          "'extracted', "
          'evidence = excluded.evidence, article_id = excluded.article_id, '
          "rule_id = null, premises = null where kg_edges.origin = 'inferred'",
        ),
        parameters: {
          's': e['source'],
          'r': e['relation'],
          't': e['target'],
          'evidence': p['evidence'],
          'article': p['articleId'],
        },
      );
    }
    await tx.execute(
      Sql.named(
        "update kg_proposals set status = 'approved', reason = null, "
        'reviewed_by = @who, '
        'reviewed_at = now() where id = any(@ids::uuid[])',
      ),
      parameters: {
        'who': reviewer,
        'ids': [for (final p in proposals) p['id'] as String],
      },
    );
  });

  @override
  Future<void> reject(
    List<String> ids, {
    required String reviewer,
    String? reason,
  }) => _db.execute(
    "update kg_proposals set status = 'rejected', reason = @reason, "
    'reviewed_by = @who, '
    'reviewed_at = now() where id = any(@ids::uuid[]) and status in '
    "('pending', 'invalid')",
    params: {'ids': ids, 'who': reviewer, 'reason': reason},
  );
}
