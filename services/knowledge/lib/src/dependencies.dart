/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:io';

import 'package:knowledge_service/src/graph/extractor.dart';
import 'package:knowledge_service/src/graph/graph_store.dart';
import 'package:knowledge_service/src/graph/reasoning_service.dart';
import 'package:knowledge_service/src/graph/structured_model.dart';
import 'package:knowledge_service/src/graph_repository.dart';
import 'package:knowledge_service/src/knowledge_repository.dart';
import 'package:knowledge_service/src/qa/answer_models.dart';
import 'package:knowledge_service/src/qa/answer_service.dart';
import 'package:knowledge_service/src/qa/embedder.dart';
import 'package:tbt_common/tbt_common.dart';

final _env = Platform.environment;
final database = Database.fromEnvironment();
final cacheStore = RedisCache.fromEnvironment();
final articleRepository = PostgresKnowledgeRepository(database);
final graphRepository = PostgresGraphRepository(database);

final embedder = GeminiEmbedder(
  _env['GEMINI_API_KEY'] ?? '',
  model: _env['GEMINI_EMBED_MODEL'] ?? 'gemini-embedding-2',
);

final geminiModels = [
  for (final m
      in (_env['GEMINI_QA_MODELS'] ??
              'gemini-3.8-flash,gemini-3.5-flash,gemini-2.5-flash')
          .split(','))
    if (m.trim().isNotEmpty) m.trim(),
];

/// Claude trả lời chính, lỗi thì Gemini, cả hai hỏng thì trích từ kho
final answerService = AnswerService(
  articles: articleRepository,
  graph: graphRepository,
  embedder: embedder,
  cache: cacheStore,
  models: [
    (
      model: ClaudeAnswerer(_env['ANTHROPIC_API_KEY'] ?? ''),
      breaker: CircuitBreaker('claude', openFor: const Duration(minutes: 2)),
    ),
    // Bản miễn phí giới hạn lượt mỗi ngày theo model, hết thì sang model kế
    for (final name in geminiModels)
      (
        model: GeminiAnswerer(_env['GEMINI_API_KEY'] ?? '', model: name),
        breaker: CircuitBreaker(name, openFor: const Duration(minutes: 10)),
      ),
  ],
);

final graphStore = PostgresGraphStore(database);
final graphReasoning = GraphReasoningService(graphStore);

/// AI đọc bài viết đề xuất nút, cạnh; cùng thứ tự dự phòng như hỏi đáp
final graphExtractor = GraphExtractor(
  store: graphStore,
  reasoning: graphReasoning,
  models: [
    (
      model: ClaudeStructured(_env['ANTHROPIC_API_KEY'] ?? ''),
      breaker: CircuitBreaker(
        'kg-claude',
        openFor: const Duration(minutes: 10),
      ),
    ),
    for (final name in geminiModels)
      (
        model: GeminiStructured(_env['GEMINI_API_KEY'] ?? '', model: name),
        breaker: CircuitBreaker(
          'kg-$name',
          openFor: const Duration(minutes: 30),
        ),
      ),
  ],
);
