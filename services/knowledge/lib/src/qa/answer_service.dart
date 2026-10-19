/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:knowledge_service/src/graph_repository.dart';
import 'package:knowledge_service/src/knowledge_repository.dart';
import 'package:knowledge_service/src/qa/answer_models.dart';
import 'package:knowledge_service/src/qa/embedder.dart';
import 'package:knowledge_service/src/qa/vectors.dart';
import 'package:tbt_common/tbt_common.dart';

const _languageNames = {
  'vi': 'Vietnamese',
  'en': 'English',
  'de': 'German',
  'pt': 'Portuguese',
};

// Câu báo khi kho không có thông tin; trả lời khi không còn AI nào dùng được
const _notCovered = {
  'vi': 'Kho tri thức chưa có thông tin cho câu hỏi này. Bạn hỏi HR giúp nhé.',
  'en': 'The knowledge base does not cover this yet. Please ask HR.',
  'de': 'Dazu gibt es noch keinen Eintrag. Bitte wenden Sie sich an HR.',
  'pt': 'A base de conhecimento ainda não cobre isso. Pergunte ao RH.',
};
const _noAi = {
  'vi': 'Trợ lý AI đang tạm ngưng, đây là phần trích từ kho tri thức:',
  'en': 'The AI assistant is unavailable, here is the relevant excerpt:',
  'de': 'Der KI-Assistent ist nicht verfügbar, hier der passende Auszug:',
  'pt': 'O assistente de IA está indisponível, eis o trecho relevante:',
};

class AskInput {
  const AskInput({
    required this.question,
    required this.lang,
    required this.region,
    required this.username,
    this.roles = const [],
    this.country,
    this.history = const [],
  });

  final String question;
  final String lang;
  final String region;
  final String username;
  final List<String> roles;
  final String? country;
  final List<Turn> history;
}

/// Hỏi đáp GraphRAG: tìm nguồn, ghép sự kiện đồ thị, AI trả lời có trích dẫn
class AnswerService {
  AnswerService({
    required this.articles,
    required this.graph,
    required this.models,
    this.embedder,
    this.cache,
    this.semanticThreshold = 0.55,
  });

  final KnowledgeRepository articles;
  final GraphRepository graph;

  /// Thử lần lượt, model đầu lỗi phía nhà cung cấp thì dùng model sau
  final List<({AnswerModel model, CircuitBreaker breaker})> models;
  final GeminiEmbedder? embedder;
  final CacheStore? cache;
  final double semanticThreshold;

  Future<Map<String, dynamic>> ask(AskInput input) async {
    final started = DateTime.now();
    final lang = _languageNames.containsKey(input.lang) ? input.lang : 'en';
    // Bài chỉ có tiếng Việt và tiếng Anh; hỏi tiếng Đức, Bồ thì đọc bản Anh
    final contentLang = lang == 'vi' ? 'vi' : 'en';
    final question = input.question.trim();

    final version = await articles.contentVersion();
    final cacheKey = input.history.isEmpty
        ? 'kb:qa:v4:${_hash('$version|${input.region}|$lang|$question')}'
        : null;
    if (cacheKey != null) {
      final hit = await _cacheGet(cacheKey);
      if (hit != null) {
        final id = await _log(input, lang, hit, started, cached: true);
        return {...hit, 'id': id, 'cached': true};
      }
    }

    // Câu nối tiếp ("còn đơn tăng ca thì sao?"): tìm theo câu hiện tại trước,
    // câu trước chỉ để bổ sung khi câu hiện tại không tự nhận ra chủ đề
    final previous = input.history.isEmpty ? null : input.history.last.question;
    final withContext = previous == null ? question : '$previous $question';
    var entities = await graph.linkEntities(question);
    if (entities.isEmpty && previous != null) {
      entities = await graph.linkEntities(withContext);
    }
    final results = await Future.wait([
      articles.rankAnyWord(question, lang: contentLang, region: input.region),
      _semantic(question, contentLang, input.region),
      graph.articlesFor(entities),
      if (previous != null)
        articles.rankAnyWord(
          withContext,
          lang: contentLang,
          region: input.region,
        ),
    ]);
    final channels = {
      'keyword': {...results[0], if (previous != null) ...results[3]}.toList(),
      'semantic': results[1],
      'graph': results[2],
    };
    final ranked = fuseRankings(channels).take(4).toList();
    final rows = await articles.byIds(ranked, lang: contentLang);
    final sources = [
      for (var i = 0; i < rows.length; i++)
        Source(
          n: i + 1,
          id: rows[i]['id'] as String,
          title: rows[i]['title'] as String,
          body: rows[i]['body'] as String,
        ),
    ];
    final facts = await graph.factsAround(entities, lang: lang);
    final request = AnswerRequest(
      question: question,
      language: _languageNames[lang]!,
      sources: sources,
      facts: [for (final f in facts) f.sentence],
      history: input.history,
      roles: input.roles,
      country: input.country,
    );

    var provider = 'none';
    String? model;
    late ModelAnswer answer;
    if (sources.isEmpty && facts.isEmpty) {
      answer = ModelAnswer(
        answerable: false,
        answer: _notCovered[lang]!,
        citations: const [],
        followUps: const [],
      );
    } else {
      final ai = await _callModels(request);
      if (ai != null) {
        (provider, model, answer) = ai;
      } else {
        answer = _extractive(lang, sources, facts);
      }
    }

    final text = normalizeMarkers(answer.answer, sources.length);
    final cited = _validCitations(answer, text, sources.length);
    final result = <String, dynamic>{
      'answerable': answer.answerable,
      'answer': text,
      'sources': [
        for (final s in sources)
          if (cited.contains(s.n))
            {
              'n': s.n,
              'id': s.id,
              'title': s.title,
              'via': [
                for (final c in channels.entries)
                  if (c.value.contains(s.id)) c.key,
              ],
            },
      ],
      'facts': [for (final f in facts.take(8)) f.toJson()],
      'entities': entities,
      'followUps': answer.followUps.take(3).toList(),
      'provider': provider,
      'model': ?model,
    };
    final id = await _log(input, lang, result, started, cached: false);
    if (cacheKey != null && provider != 'none' && answer.answerable) {
      await _cacheSet(cacheKey, result);
    }
    return {...result, 'id': id, 'cached': false};
  }

  Future<List<String>> _semantic(
    String text,
    String lang,
    String region,
  ) async {
    final e = embedder;
    if (e == null || !e.configured) return const [];
    try {
      final query = (await e.embed([text], query: true)).first;
      final stored = await articles.embeddings(lang: lang, region: region);
      final scored = [
        for (final s in stored)
          (id: s.id, score: cosine(query, decodeVector(s.bytes))),
      ]..sort((a, b) => b.score.compareTo(a.score));
      return [
        for (final s in scored.take(5))
          if (s.score >= semanticThreshold) s.id,
      ];
    } on Object catch (error) {
      // Tìm theo nghĩa hỏng thì vẫn còn từ khóa và đồ thị
      stderr.writeln('Tìm theo nghĩa lỗi: $error');
      return const [];
    }
  }

  Future<(String, String, ModelAnswer)?> _callModels(
    AnswerRequest request,
  ) async {
    for (final m in models) {
      if (!m.model.configured) continue;
      try {
        final answer = await m.breaker.call(
          () => m.model.answer(request),
          isFailure: isProviderOutage,
        );
        if (answer.answer.isEmpty) throw const FormatException('empty answer');
        return (m.model.provider, m.model.model, answer);
      } on Object catch (error) {
        stderr.writeln('${m.model.provider} không trả lời được: $error');
      }
    }
    return null;
  }

  /// Không còn AI: trả đoạn đầu của bài khớp nhất và vài sự kiện đồ thị
  ModelAnswer _extractive(
    String lang,
    List<Source> sources,
    List<GraphFact> facts,
  ) {
    final b = StringBuffer(_noAi[lang]!);
    if (sources.isNotEmpty) {
      final sentences = sources.first.body.split(RegExp(r'(?<=[.!?])\s+'));
      b.write('\n${sentences.take(2).join(' ')} [1]');
    }
    for (final f in facts.take(3)) {
      b.write('\n- ${f.sentence}');
    }
    return ModelAnswer(
      answerable: sources.isNotEmpty,
      answer: b.toString(),
      citations: sources.isEmpty ? const [] : const [1],
      followUps: const [],
    );
  }

  static Set<int> _validCitations(ModelAnswer a, String text, int count) => {
    for (final c in a.citations)
      if (c >= 1 && c <= count) c,
    for (final m in RegExp(r'\[(\d+)\]').allMatches(text)) int.parse(m[1]!),
  };

  /// "[1, 2]" thành "[1][2]"; bỏ số nguồn không có thật
  static String normalizeMarkers(String text, int count) =>
      text.replaceAllMapped(RegExp(r'(\s?)\[(\d+(?:\s*,\s*\d+)*)\]'), (m) {
        final valid = [
          for (final n in m[2]!.split(',').map((x) => int.parse(x.trim())))
            if (n >= 1 && n <= count) '[$n]',
        ];
        return valid.isEmpty ? '' : '${m[1]}${valid.join()}';
      });

  static String _hash(String s) =>
      sha1.convert(utf8.encode(s.toLowerCase())).toString();

  Future<Map<String, dynamic>?> _cacheGet(String key) async {
    try {
      final raw = await cache?.get(key);
      return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
    } on Object {
      return null;
    }
  }

  Future<void> _cacheSet(String key, Map<String, dynamic> value) async {
    try {
      await cache?.set(key, jsonEncode(value), const Duration(hours: 6));
    } on Object {
      // Redis hỏng thì chỉ mất cache, câu trả lời vẫn trả về
    }
  }

  Future<String?> _log(
    AskInput input,
    String lang,
    Map<String, dynamic> result,
    DateTime started, {
    required bool cached,
  }) async {
    try {
      return await articles.logAnswer({
        'username': input.username,
        'region': input.region,
        'lang': lang,
        'question': input.question.trim(),
        'answer': result['answer'],
        'answerable': result['answerable'],
        'provider': result['provider'],
        'model': result['model'],
        'sources': [
          for (final s in result['sources'] as List) (s as Map)['id'] as String,
        ],
        'entities': (result['entities'] as List).cast<String>(),
        'cached': cached,
        'latency_ms': DateTime.now().difference(started).inMilliseconds,
      });
    } on Object catch (error) {
      stderr.writeln('Không ghi được nhật ký hỏi đáp: $error');
      return null;
    }
  }
}
