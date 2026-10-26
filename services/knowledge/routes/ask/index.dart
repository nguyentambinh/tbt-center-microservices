/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/qa/answer_models.dart';
import 'package:knowledge_service/src/qa/answer_service.dart';
import 'package:knowledge_service/src/qa/personal_data.dart';
import 'package:tbt_common/tbt_common.dart';

final _personal = PersonalData.fromEnvironment();

/// Mỗi người tối đa 10 câu hỏi một phút, gọi AI tốn tiền
const questionsPerMinute = 10;

/// POST /ask {question, lang, history: [{question, answer}]}
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_body', 'JSON object expected');
  }
  final question = (body['question'] as String? ?? '').trim();
  if (question.isEmpty || question.length > 500) {
    return apiError(400, 'invalid_question', 'Question must be 1 to 500 chars');
  }
  final history = <Turn>[];
  for (final t
      in (body['history'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()) {
    final q = t['question'] as String? ?? '';
    final a = t['answer'] as String? ?? '';
    if (q.isNotEmpty && a.isNotEmpty) {
      history.add(Turn(_cut(q, 500), _cut(a, 2000)));
    }
  }

  final claims = context.read<Claims>();
  if (!await _allow(context.read<CacheStore?>(), claims.username)) {
    return apiError(
      429,
      'too_many_questions',
      'At most $questionsPerMinute questions per minute',
    );
  }
  final result = await context.read<AnswerService>().ask(
    AskInput(
      question: question,
      lang: body['lang'] as String? ?? 'en',
      region: claims.region ?? 'vn',
      username: claims.username,
      roles: claims.roles.toList()..sort(),
      country: claims.countryCode,
      employeeId: claims.employeeId,
      // Nhân viên hỏi về chính mình: AI tra API khu vực bằng token của họ
      personal: claims.employeeId == null
          ? null
          : _personal.forUser(
              claims.region ?? 'vn',
              context.request.headers['authorization'] ?? '',
            ),
      // Giữ 4 lượt gần nhất là đủ hiểu câu hỏi nối tiếp
      history: history.length > 4
          ? history.sublist(history.length - 4)
          : history,
    ),
  );
  return Response.json(body: result);
}

String _cut(String s, int max) => s.length <= max ? s : s.substring(0, max);

Future<bool> _allow(CacheStore? cache, String username) async {
  if (cache == null) return true;
  final minute = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 60000;
  final key = 'kb:ask:$username:$minute';
  try {
    final n = await cache.incr(key);
    if (n == 1) await cache.set(key, '1', const Duration(seconds: 90));
    return n <= questionsPerMinute;
  } on Object {
    // Redis hỏng thì không chặn người dùng
    return true;
  }
}
