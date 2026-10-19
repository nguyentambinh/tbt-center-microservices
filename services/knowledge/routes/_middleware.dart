/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/dependencies.dart';
import 'package:knowledge_service/src/graph/extractor.dart';
import 'package:knowledge_service/src/graph/graph_store.dart';
import 'package:knowledge_service/src/graph/reasoning_service.dart';
import 'package:knowledge_service/src/graph_repository.dart';
import 'package:knowledge_service/src/knowledge_repository.dart';
import 'package:knowledge_service/src/qa/answer_service.dart';
import 'package:tbt_common/tbt_common.dart';

/// Người trong công ty tra cứu; app gọi qua Kong khu vực (route /knowledge)
Handler middleware(Handler handler) {
  final protected = handler.use(
    requireClaims(
      anyRole: const {'executive', 'admin', 'hr', 'finance', 'employee'},
    ),
  );
  return ((RequestContext context) {
        if (context.request.uri.path == '/') return handler(context);
        return protected(context);
      })
      .use(provider<KnowledgeRepository>((_) => articleRepository))
      .use(provider<GraphRepository>((_) => graphRepository))
      .use(provider<GraphReasoningService>((_) => graphReasoning))
      .use(provider<GraphExtractor>((_) => graphExtractor))
      .use(provider<GraphStore>((_) => graphStore))
      .use(provider<AnswerService>((_) => answerService))
      .use(provider<CacheStore?>((_) => cacheStore))
      .use(correlationAndErrors())
      .use(metrics('knowledge'))
      .use(serviceRegistry('knowledge'));
}
