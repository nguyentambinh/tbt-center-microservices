/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/knowledge_graph.dart';
import '../../domain/entities/ontology.dart';
import '../../domain/repositories/knowledge_repository.dart';

/// Kho tri thức ở Hub, gọi qua Kong của khu vực
class KnowledgeRepositoryImpl implements KnowledgeRepository {
  KnowledgeRepositoryImpl(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  @override
  Future<List<ArticleHit>> search(String query, {required String lang}) async {
    final d = await _get('$baseUrl/knowledge/articles', {'q': query, 'lang': lang});
    return [
      for (final r in (d['items'] as List).cast<Map<String, dynamic>>())
        ArticleHit(
          id: r['id'] as String,
          title: r['title'] as String,
          category: r['category'] as String,
          snippet: r['snippet'] as String? ?? '',
        ),
    ];
  }

  @override
  Future<Article> article(String id, {required String lang}) async {
    final d = await _get('$baseUrl/knowledge/articles/$id', {'lang': lang});
    return Article(
      id: d['id'] as String,
      title: d['title'] as String,
      category: d['category'] as String,
      body: d['body'] as String,
      source: d['source'] as String?,
    );
  }

  @override
  Future<Answer> ask(String question, {required String lang, List<(String, String)> history = const []}) async {
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/knowledge/ask',
        data: {
          'question': question,
          'lang': lang,
          'history': [
            for (final (q, a) in history) {'question': q, 'answer': a},
          ],
        },
        // AI chính lỗi thì server thử AI dự phòng, cần chờ lâu hơn mặc định
        options: Options(receiveTimeout: const Duration(seconds: 70), extra: {slowExpected: true}),
      );
      return Answer.fromJson(r.data!);
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  @override
  Future<void> feedback(String answerId, {required bool helpful}) async {
    try {
      await _dio.post<void>('$baseUrl/knowledge/ask/$answerId/feedback', data: {'helpful': helpful});
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  @override
  Future<List<GraphNode>> graphNodes(String query, {required String lang}) async {
    final d = await _get('$baseUrl/knowledge/graph', {'q': query, 'lang': lang});
    return [for (final n in (d['items'] as List).cast<Map<String, dynamic>>()) GraphNode.fromJson(n)];
  }

  @override
  Future<GraphView> graph(String id, {required String lang}) async {
    final d = await _get('$baseUrl/knowledge/graph/${Uri.encodeComponent(id)}', {'lang': lang});
    return GraphView(
      center: GraphNode.fromJson(d['center'] as Map<String, dynamic>),
      nodes: [for (final n in (d['nodes'] as List).cast<Map<String, dynamic>>()) GraphNode.fromJson(n)],
      edges: [for (final e in (d['edges'] as List).cast<Map<String, dynamic>>()) GraphEdge.fromJson(e)],
    );
  }

  @override
  Future<GraphPath?> graphPath(String from, String to, {required String lang}) async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        '$baseUrl/knowledge/graph/${Uri.encodeComponent(from)}',
        queryParameters: {'to': to, 'lang': lang},
      );
      return GraphPath.fromJson(r.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  @override
  Future<OntologyInfo> ontology({required String lang}) async =>
      OntologyInfo.fromJson(await _get('$baseUrl/knowledge/ontology', {'lang': lang}));

  @override
  Future<SparqlAnswer> sparql(String query, {required String lang, bool inferred = true}) async =>
      SparqlAnswer.fromJson(await _post('$baseUrl/knowledge/sparql', {'query': query, 'lang': lang, 'inferred': inferred}));

  @override
  Future<ProposalList> proposals({String? status}) async {
    final d = await _get('$baseUrl/knowledge/proposals', {'status': ?status});
    return ProposalList(
      items: [for (final p in (d['items'] as List).cast<Map<String, dynamic>>()) GraphProposal.fromJson(p)],
      running: d['running'] as bool? ?? false,
      configured: d['configured'] as bool? ?? false,
    );
  }

  @override
  Future<int> extract({String? articleId}) async =>
      (await _post('$baseUrl/knowledge/proposals', {'articleId': ?articleId}))['queued'] as int? ?? 0;

  @override
  Future<void> reviewProposal(String id, {required bool approve, String? reason}) => _post(
        '$baseUrl/knowledge/proposals/$id',
        {'action': approve ? 'approve' : 'reject', 'reason': ?reason},
      );

  @override
  Future<void> runReasoner() => _post('$baseUrl/knowledge/reasoner', const {});

  Future<Map<String, dynamic>> _post(String url, Map<String, Object?> body) async {
    try {
      return (await _dio.post<Map<String, dynamic>>(url, data: body)).data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> _get(String url, Map<String, String> query) async {
    try {
      return (await _dio.get<Map<String, dynamic>>(url, queryParameters: query)).data!;
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}
