/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:typed_data';

import 'package:tbt_common/tbt_common.dart';

abstract interface class KnowledgeRepository {
  /// Tìm bài theo từ khóa (gõ không dấu vẫn ra), bài chung và bài của nước
  Future<List<Map<String, dynamic>>> search(
    String query, {
    required String lang,
    required String region,
    int limit = 20,
  });

  Future<Map<String, dynamic>?> find(String id, {required String lang});

  /// Tìm cho câu hỏi dài: khớp từ nào cũng tính, bài khớp nhiều từ xếp trước
  Future<List<String>> rankAnyWord(
    String question, {
    required String lang,
    required String region,
  });

  /// Bài theo mã, đúng ngôn ngữ, thiếu thì bản tiếng Anh
  Future<List<Map<String, dynamic>>> byIds(
    List<String> ids, {
    required String lang,
  });

  /// Mọi bài kèm dấu băm nội dung và dấu băm của vector đang lưu
  Future<List<Map<String, dynamic>>> embeddingStatus();

  Future<void> saveEmbedding(
    String id,
    String lang,
    String model,
    String hash,
    List<int> bytes,
  );

  /// Vector của bài theo ngôn ngữ (bài chung và bài của nước)
  Future<List<({String id, List<int> bytes})>> embeddings({
    required String lang,
    required String region,
  });

  /// Bài hoặc đồ thị đổi thì câu trả lời cũ trong cache hết hiệu lực
  Future<String> contentVersion();

  /// Trả về mã lượt hỏi để người hỏi gửi phản hồi
  Future<String> logAnswer(Map<String, Object?> row);

  /// Chỉ người hỏi mới chấm được câu trả lời của mình
  Future<bool> saveFeedback(
    String id, {
    required String username,
    required bool helpful,
    String? comment,
  });

  Future<Map<String, dynamic>> stats({int days = 30});

  Future<int> purgeLog({int days = 90});
}

class PostgresKnowledgeRepository implements KnowledgeRepository {
  PostgresKnowledgeRepository(this._db);

  final Database _db;

  @override
  Future<List<Map<String, dynamic>>> search(
    String query, {
    required String lang,
    required String region,
    int limit = 20,
  }) async {
    // Gõ không dấu vẫn ra: cả câu hỏi và bài đều qua kb_unaccent
    const tsq = "websearch_to_tsquery('simple', kb_unaccent(@q))";
    final where = query.trim().isEmpty ? '' : 'and search @@ $tsq ';
    final rows = await _db.query(
      'select id, category, title, region, '
      "ts_headline('simple', body, $tsq, "
      "'MaxWords=24, MinWords=10, StartSel=<<, StopSel=>>') as snippet, "
      'ts_rank(search, $tsq) as rank from articles '
      'where lang = @lang and (region is null or region = @region) '
      '$where'
      'order by rank desc, title limit @limit',
      params: {'q': query, 'lang': lang, 'region': region, 'limit': limit},
    );
    return [
      for (final r in rows)
        {
          'id': r['id'],
          'category': r['category'],
          'title': r['title'],
          'region': r['region'],
          'snippet': r['snippet'],
        },
    ];
  }

  @override
  Future<Map<String, dynamic>?> find(String id, {required String lang}) async {
    final rows = await _db.query(
      'select id, category, title, body, region, source, updated_at '
      'from articles where id = @id and lang = @lang',
      params: {'id': id, 'lang': lang},
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    return {
      'id': r['id'],
      'category': r['category'],
      'title': r['title'],
      'body': r['body'],
      'region': r['region'],
      'source': r['source'],
      'updatedAt': (r['updated_at'] as DateTime).toIso8601String(),
    };
  }

  @override
  Future<List<String>> rankAnyWord(
    String question, {
    required String lang,
    required String region,
  }) async {
    // plainto_tsquery nối các từ bằng & (phải đủ mọi từ); đổi thành |
    final rows = await _db.query(
      '''
      with q as (select to_tsquery('simple', nullif(replace(
        plainto_tsquery('simple', kb_unaccent(@q))::text, '&', '|'), '')) as t)
      select id from articles, q
      where q.t is not null and lang = @lang
        and (region is null or region = @region) and search @@ q.t
      order by ts_rank(search, q.t) desc limit 8''',
      params: {'q': question, 'lang': lang, 'region': region},
    );
    return [for (final r in rows) r['id'] as String];
  }

  @override
  Future<List<Map<String, dynamic>>> byIds(
    List<String> ids, {
    required String lang,
  }) async {
    if (ids.isEmpty) return const [];
    final rows = await _db.query(
      'select distinct on (id) id, title, body, source from articles '
      "where id = any(@ids) and lang in (@lang, 'en') "
      'order by id, lang = @lang desc',
      params: {'ids': ids, 'lang': lang},
    );
    final byId = {for (final r in rows) r['id'] as String: r};
    return [
      for (final id in ids)
        if (byId[id] case final r?)
          {
            'id': r['id'],
            'title': r['title'],
            'body': r['body'],
            'source': r['source'],
          },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> embeddingStatus() => _db.query(
    "select a.id, a.lang, a.title || '. ' || a.body as text, "
    "md5(a.title || '. ' || a.body) as hash, e.content_hash as stored "
    'from articles a left join article_embeddings e '
    'on e.article_id = a.id and e.lang = a.lang',
    fromPrimary: true,
  );

  @override
  Future<void> saveEmbedding(
    String id,
    String lang,
    String model,
    String hash,
    List<int> bytes,
  ) => _db.execute(
    'insert into article_embeddings '
    '(article_id, lang, model, content_hash, embedding) '
    'values (@id, @lang, @model, @hash, @bytes) '
    'on conflict (article_id, lang) do update set model = excluded.model, '
    'content_hash = excluded.content_hash, embedding = excluded.embedding, '
    'updated_at = now()',
    params: {
      'id': id,
      'lang': lang,
      'model': model,
      'hash': hash,
      'bytes': Uint8List.fromList(bytes),
    },
  );

  @override
  Future<List<({String id, List<int> bytes})>> embeddings({
    required String lang,
    required String region,
  }) async {
    final rows = await _db.query(
      'select e.article_id, e.embedding from article_embeddings e '
      'join articles a on a.id = e.article_id and a.lang = e.lang '
      'where e.lang = @lang and (a.region is null or a.region = @region)',
      params: {'lang': lang, 'region': region},
    );
    return [
      for (final r in rows)
        (id: r['article_id'] as String, bytes: r['embedding'] as List<int>),
    ];
  }

  @override
  Future<String> contentVersion() async {
    final rows = await _db.query(
      "select coalesce(max(updated_at)::text, '') || ':' || "
      "(select count(*) from kg_edges)::text || ':' || "
      '(select count(*) from kg_nodes)::text as v from articles',
    );
    return rows.first['v'] as String;
  }

  @override
  Future<String> logAnswer(Map<String, Object?> row) async {
    final rows = await _db.execute(
      'insert into qa_log (id, username, region, lang, question, answer, '
      'answerable, provider, model, sources, entities, cached, latency_ms) '
      'values (gen_random_uuid(), @username, @region, @lang, @question, '
      '@answer, @answerable, @provider, @model, @sources, @entities, @cached, '
      '@latency_ms) returning id::text',
      params: row,
    );
    return rows.first['id'] as String;
  }

  @override
  Future<bool> saveFeedback(
    String id, {
    required String username,
    required bool helpful,
    String? comment,
  }) async {
    final rows = await _db.execute(
      'update qa_log set helpful = @helpful, comment = @comment '
      'where id = @id::uuid and username = @username returning id',
      params: {
        'id': id,
        'username': username,
        'helpful': helpful,
        'comment': comment,
      },
    );
    return rows.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>> stats({int days = 30}) async {
    const recent = 'asked_at > now() - make_interval(days => @days)';
    final since = {'days': days};
    final totals = await _db.query(
      'select count(*)::int as asked, '
      'count(*) filter (where helpful)::int as helpful, '
      'count(*) filter (where helpful = false)::int as "notHelpful", '
      'count(*) filter (where not answerable)::int as unanswered, '
      'count(*) filter (where cached)::int as cached, '
      'coalesce(avg(latency_ms) filter (where not cached), 0)::int as "avgMs" '
      'from qa_log where $recent',
      params: since,
    );
    final providers = await _db.query(
      'select provider, count(*)::int as n from qa_log where $recent '
      'group by 1 order by 2 desc',
      params: since,
    );
    final gaps = await _db.query(
      'select question, count(*)::int as n from qa_log '
      'where (not answerable or helpful = false) and $recent '
      'group by 1 order by 2 desc, 1 limit 10',
      params: since,
    );
    return {
      ...totals.first,
      'providers': {for (final r in providers) r['provider']: r['n']},
      'gaps': [
        for (final r in gaps) {'question': r['question'], 'count': r['n']},
      ],
    };
  }

  @override
  Future<int> purgeLog({int days = 90}) async {
    final rows = await _db.execute(
      'delete from qa_log '
      'where asked_at < now() - make_interval(days => @days) returning id',
      params: {'days': days},
    );
    return rows.length;
  }
}
