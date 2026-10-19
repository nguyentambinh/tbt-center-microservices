/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import '../entities/answer.dart';
import '../entities/article.dart';
import '../entities/knowledge_graph.dart';
import '../entities/ontology.dart';

abstract interface class KnowledgeRepository {
  Future<List<ArticleHit>> search(String query, {required String lang});

  Future<Article> article(String id, {required String lang});

  /// [history] là các lượt hỏi trước (câu hỏi, câu trả lời) để hiểu câu hỏi nối tiếp
  Future<Answer> ask(String question, {required String lang, List<(String, String)> history = const []});

  Future<void> feedback(String answerId, {required bool helpful});

  Future<List<GraphNode>> graphNodes(String query, {required String lang});

  Future<GraphView> graph(String id, {required String lang});

  /// Đường ngắn nhất nối hai nút, null nếu không nối được
  Future<GraphPath?> graphPath(String from, String to, {required String lang});

  Future<OntologyInfo> ontology({required String lang});

  /// Truy vấn SPARQL (chỉ đọc); [inferred] là có tính cạnh suy luận không
  Future<SparqlAnswer> sparql(String query, {required String lang, bool inferred = true});

  Future<ProposalList> proposals({String? status});

  /// Cho AI đọc lại một bài (hoặc mọi bài mới, bài đã sửa); trả về số bài sẽ đọc
  Future<int> extract({String? articleId});

  Future<void> reviewProposal(String id, {required bool approve, String? reason});

  /// Chạy lại suy luận trên toàn đồ thị (HR, quản trị, ban điều hành)
  Future<void> runReasoner();
}
