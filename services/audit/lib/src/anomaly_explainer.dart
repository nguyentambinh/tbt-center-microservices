/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:convert';

import 'package:tbt_common/tbt_common.dart';

/// AI giải thích vì sao một sự kiện bị đánh dấu bất thường và cần kiểm tra gì;
/// không kết luận sai phạm, chỉ gợi ý cho người kiểm toán
class AnomalyExplainer {
  AnomalyExplainer(this.ai);

  final StructuredAi ai;

  static const _schema = {
    'type': 'object',
    'properties': {
      'summary': {'type': 'string'},
      'whyFlagged': {'type': 'string'},
      'risk': {
        'type': 'string',
        'enum': ['low', 'medium', 'high'],
      },
      'checks': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'likelyBenign': {'type': 'string'},
    },
    'required': ['summary', 'whyFlagged', 'risk', 'checks'],
  };

  bool get configured => ai.configured;

  Future<({Map<String, dynamic> explanation, String source})?> explain({
    required Map<String, dynamic> event,
    required List<Map<String, dynamic>> history,
    required String language,
  }) async {
    if (!ai.configured) return null;
    final result = await ai.generate(
      system:
          'You assist an internal auditor of a construction company HR and '
          'finance system. An event was flagged by rules: "after_hours" means '
          'it happened between 22:00 and 06:00 local time of its region; '
          '"failure" means the event type is a failure, rejection, '
          'compensation or needs manual attention. Explain in plain words what '
          'the event is, why it was flagged, how risky it looks given its data '
          'and the earlier events of the same record, what the auditor should '
          'check, and a likely harmless explanation if any. Never accuse '
          'anyone. Reply in $language.',
      user: jsonEncode({'event': event, 'earlierEventsOfSameRecord': history}),
      schema: _schema,
    );
    if (result == null) return null;
    return (explanation: result, source: ai.lastProvider ?? 'ai');
  }
}
