/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/graph_repository.dart';
import 'package:knowledge_service/src/knowledge_repository.dart';
import 'package:knowledge_service/src/qa/answer_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/ask/[id]/feedback.dart' as feedback;
import '../../routes/ask/index.dart' as ask;
import '../../routes/ask/stats.dart' as stats;
import '../../routes/graph/[id].dart' as node;

class _MockContext extends Mock implements RequestContext {}

class _MockService extends Mock implements AnswerService {}

class _MockArticles extends Mock implements KnowledgeRepository {}

class _MockGraph extends Mock implements GraphRepository {}

class _MockCache extends Mock implements CacheStore {}

class _FakeInput extends Fake implements AskInput {}

Claims _claims(List<String> roles) => Claims({
  'preferred_username': 'employee.de',
  'region': 'de',
  'country_code': 'DE',
  'realm_access': {'roles': roles},
});

void main() {
  late _MockContext context;
  late _MockService service;
  late _MockArticles articles;
  late _MockCache cache;

  setUpAll(() {
    registerFallbackValue(_FakeInput());
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    context = _MockContext();
    service = _MockService();
    articles = _MockArticles();
    cache = _MockCache();
    when(() => context.read<AnswerService>()).thenReturn(service);
    when(() => context.read<KnowledgeRepository>()).thenReturn(articles);
    when(() => context.read<CacheStore?>()).thenReturn(cache);
    when(() => context.read<Claims>()).thenReturn(_claims(['employee']));
    when(() => cache.incr(any())).thenAnswer((_) async => 1);
    when(() => cache.set(any(), any(), any())).thenAnswer((_) async {});
  });

  void post(String path, Object body) => when(() => context.request).thenReturn(
    Request.post(Uri.parse('http://localhost$path'), body: jsonEncode(body)),
  );

  test(
    'hỏi đúng thì lấy nước, vai trò từ token và giữ 4 lượt gần nhất',
    () async {
      when(() => service.ask(any())).thenAnswer((_) async => {'answer': 'ok'});
      post('/ask', {
        'question': ' Wie viele Urlaubstage? ',
        'lang': 'de',
        'history': [
          for (var i = 0; i < 6; i++) {'question': 'q$i', 'answer': 'a$i'},
        ],
      });
      final response = await ask.onRequest(context);
      expect(response.statusCode, 200);
      final sent =
          verify(() => service.ask(captureAny())).captured.single as AskInput;
      expect(sent.question, 'Wie viele Urlaubstage?');
      expect(sent.region, 'de');
      expect(sent.country, 'DE');
      expect(sent.roles, ['employee']);
      expect(
        [for (final t in sent.history) t.question],
        ['q2', 'q3', 'q4', 'q5'],
      );
    },
  );

  test('câu hỏi rỗng hoặc quá 500 ký tự thì 400', () async {
    post('/ask', {'question': '  '});
    expect((await ask.onRequest(context)).statusCode, 400);
    post('/ask', {'question': 'a' * 501});
    expect((await ask.onRequest(context)).statusCode, 400);
  });

  test('quá 10 câu một phút thì 429', () async {
    when(() => cache.incr(any())).thenAnswer((_) async => 11);
    post('/ask', {'question': 'Tăng ca tính sao?'});
    expect((await ask.onRequest(context)).statusCode, 429);
    verifyNever(() => service.ask(any()));
  });

  test('chấm câu trả lời của người khác thì 404', () async {
    const id = '0f8fad5b-d9cb-469f-a165-70867728950e';
    when(
      () => articles.saveFeedback(
        id,
        username: 'employee.de',
        helpful: false,
        comment: 'sai',
      ),
    ).thenAnswer((_) async => false);
    post('/ask/$id/feedback', {'helpful': false, 'comment': 'sai'});
    expect((await feedback.onRequest(context, id)).statusCode, 404);
  });

  test('nhân viên không xem được thống kê hỏi đáp', () async {
    when(() => context.request).thenReturn(
      Request.get(Uri.parse('http://localhost/ask/stats')),
    );
    expect((await stats.onRequest(context)).statusCode, 403);
  });

  test('nút không có trong đồ thị thì 404', () async {
    final graph = _MockGraph();
    when(() => context.read<GraphRepository>()).thenReturn(graph);
    when(
      () => graph.neighborhood(
        any(),
        lang: any(named: 'lang'),
        depth: any(named: 'depth'),
      ),
    ).thenAnswer((_) async => null);
    when(() => context.request).thenReturn(
      Request.get(Uri.parse('http://localhost/graph/khong-co')),
    );
    expect((await node.onRequest(context, 'khong-co')).statusCode, 404);
  });
}
