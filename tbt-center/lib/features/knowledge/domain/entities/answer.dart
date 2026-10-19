/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

class AnswerSource {
  const AnswerSource({required this.n, required this.id, required this.title, this.via = const []});

  final int n;
  final String id;
  final String title;

  /// Cách tìm ra nguồn: keyword, semantic, graph
  final List<String> via;
}

class AnswerFact {
  const AnswerFact({required this.source, required this.relation, required this.target, this.note});

  final String source;
  final String relation;
  final String target;
  final String? note;
}

/// Câu trả lời của trợ lý; [answer] có đánh dấu nguồn kiểu [1]
class Answer {
  const Answer({
    required this.id,
    required this.answerable,
    required this.answer,
    required this.sources,
    required this.facts,
    required this.followUps,
    required this.provider,
    this.model,
    this.cached = false,
  });

  factory Answer.fromJson(Map<String, dynamic> j) => Answer(
        id: j['id'] as String?,
        answerable: j['answerable'] as bool? ?? false,
        answer: j['answer'] as String? ?? '',
        sources: [
          for (final s in (j['sources'] as List? ?? const []).cast<Map<String, dynamic>>())
            AnswerSource(
              n: s['n'] as int,
              id: s['id'] as String,
              title: s['title'] as String,
              via: (s['via'] as List? ?? const []).cast<String>(),
            ),
        ],
        facts: [
          for (final f in (j['facts'] as List? ?? const []).cast<Map<String, dynamic>>())
            AnswerFact(
              source: f['sourceLabel'] as String,
              relation: f['relationLabel'] as String,
              target: f['targetLabel'] as String,
              note: f['note'] as String?,
            ),
        ],
        followUps: (j['followUps'] as List? ?? const []).cast<String>(),
        provider: j['provider'] as String? ?? 'none',
        model: j['model'] as String?,
        cached: j['cached'] as bool? ?? false,
      );

  /// Mã lượt hỏi để gửi phản hồi; null khi server không ghi được nhật ký
  final String? id;
  final bool answerable;
  final String answer;
  final List<AnswerSource> sources;
  final List<AnswerFact> facts;
  final List<String> followUps;
  final String provider;
  final String? model;
  final bool cached;
}
