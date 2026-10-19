/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/config/env.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/locale/locale_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/knowledge_repository_impl.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/knowledge_graph.dart';
import '../../domain/entities/ontology.dart';
import '../../domain/repositories/knowledge_repository.dart';

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return KnowledgeRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final knowledgeSearchProvider = FutureProvider.autoDispose.family<List<ArticleHit>, String>(
  (ref, query) => ref
      .watch(knowledgeRepositoryProvider)
      .search(query, lang: ref.watch(appLocaleProvider).languageCode),
);

final articleProvider = FutureProvider.autoDispose.family<Article, String>(
  (ref, id) => ref.watch(knowledgeRepositoryProvider).article(id, lang: ref.watch(appLocaleProvider).languageCode),
);

/// Một lượt hỏi; chưa có [answer] và [error] là đang chờ trả lời
class ChatEntry {
  const ChatEntry({required this.question, this.answer, this.error, this.helpful});

  final String question;
  final Answer? answer;
  final Object? error;
  final bool? helpful;

  bool get pending => answer == null && error == null;

  ChatEntry copyWith({Answer? answer, Object? error, bool? helpful}) =>
      ChatEntry(question: question, answer: answer, error: error, helpful: helpful ?? this.helpful);
}

final knowledgeChatProvider = NotifierProvider<KnowledgeChat, List<ChatEntry>>(KnowledgeChat.new);

/// Hội thoại hỏi đáp; giữ khi chuyển tab, đổi người đăng nhập thì xóa
class KnowledgeChat extends Notifier<List<ChatEntry>> {
  @override
  List<ChatEntry> build() {
    ref.watch(authControllerProvider.select((s) => s.value?.username));
    return const [];
  }

  bool get busy => state.any((e) => e.pending);

  Future<void> send(String question) async {
    final q = question.trim();
    if (q.isEmpty || busy) return;
    // Gửi kèm 4 lượt đã trả lời gần nhất để hiểu câu hỏi nối tiếp
    final history = [
      for (final e in state)
        if (e.answer case final a? when a.answerable) (e.question, a.answer),
    ];
    state = [...state, ChatEntry(question: q)];
    await _answer(state.length - 1, history.length > 4 ? history.sublist(history.length - 4) : history);
  }

  Future<void> retry(int index) async {
    if (busy) return;
    state = [
      for (var i = 0; i < state.length; i++) i == index ? ChatEntry(question: state[i].question) : state[i],
    ];
    await _answer(index, const []);
  }

  Future<void> rate(int index, {required bool helpful}) async {
    final id = state[index].answer?.id;
    if (id == null) return;
    _replace(index, state[index].copyWith(answer: state[index].answer, helpful: helpful));
    try {
      await ref.read(knowledgeRepositoryProvider).feedback(id, helpful: helpful);
    } on Object catch (e) {
      reportFailure(e);
    }
  }

  void clear() {
    if (!busy) state = const [];
  }

  Future<void> _answer(int index, List<(String, String)> history) async {
    final entry = state[index];
    try {
      final answer = await ref
          .read(knowledgeRepositoryProvider)
          .ask(entry.question, lang: ref.read(appLocaleProvider).languageCode, history: history);
      if (!ref.mounted) return;
      _replace(index, entry.copyWith(answer: answer));
    } on Object catch (e) {
      if (!ref.mounted) return;
      _replace(index, entry.copyWith(error: e));
      reportFailure(e);
    }
  }

  void _replace(int index, ChatEntry entry) {
    if (index >= state.length) return;
    state = [for (var i = 0; i < state.length; i++) i == index ? entry : state[i]];
  }
}

/// Nút đang ở giữa màn đồ thị; mặc định là quy trình chốt lương (nhiều liên kết nhất)
final graphCenterProvider = NotifierProvider<GraphCenter, String>(GraphCenter.new);

class GraphCenter extends Notifier<String> {
  @override
  String build() => 'payroll-closing';

  void focus(String id) => state = id;
}

final graphViewProvider = FutureProvider.autoDispose.family<GraphView, String>(
  (ref, id) => ref.watch(knowledgeRepositoryProvider).graph(id, lang: ref.watch(appLocaleProvider).languageCode),
);

final graphNodeSearchProvider = FutureProvider.autoDispose.family<List<GraphNode>, String>(
  (ref, query) =>
      ref.watch(knowledgeRepositoryProvider).graphNodes(query, lang: ref.watch(appLocaleProvider).languageCode),
);

/// Đường ngắn nhất nối (từ, tới)
final graphPathProvider = FutureProvider.autoDispose.family<GraphPath?, (String, String)>(
  (ref, ends) => ref
      .watch(knowledgeRepositoryProvider)
      .graphPath(ends.$1, ends.$2, lang: ref.watch(appLocaleProvider).languageCode),
);

final ontologyProvider = FutureProvider.autoDispose<OntologyInfo>(
  (ref) => ref.watch(knowledgeRepositoryProvider).ontology(lang: ref.watch(appLocaleProvider).languageCode),
);

/// Đề xuất theo trạng thái: pending, invalid, approved, rejected
final proposalsProvider = FutureProvider.autoDispose.family<ProposalList, String>(
  (ref, status) => ref.watch(knowledgeRepositoryProvider).proposals(status: status),
);

/// Vai trò được duyệt đề xuất AI, khớp với reviewerRoles ở service knowledge
const proposalReviewerRoles = {'hr', 'admin', 'executive'};
