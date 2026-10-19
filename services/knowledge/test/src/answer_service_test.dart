/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'package:knowledge_service/src/graph_repository.dart';
import 'package:knowledge_service/src/knowledge_repository.dart';
import 'package:knowledge_service/src/qa/answer_models.dart';
import 'package:knowledge_service/src/qa/answer_service.dart';
import 'package:knowledge_service/src/qa/vectors.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

class _MockArticles extends Mock implements KnowledgeRepository {}

class _MockGraph extends Mock implements GraphRepository {}

class _FakeModel implements AnswerModel {
  _FakeModel(this.provider, this._reply);

  @override
  final String provider;
  final Future<ModelAnswer> Function(AnswerRequest) _reply;
  final requests = <AnswerRequest>[];

  @override
  String get model => '$provider-test';

  @override
  bool get configured => true;

  @override
  Future<ModelAnswer> answer(AnswerRequest request) {
    requests.add(request);
    return _reply(request);
  }
}

class _MemoryCache implements CacheStore {
  final data = <String, String>{};

  @override
  Future<String?> get(String key) async => data[key];

  @override
  Future<void> set(String key, String value, Duration ttl) async =>
      data[key] = value;

  @override
  Future<int> incr(String key) async => 1;
}

const _overtime = {
  'id': 'overtime',
  'title': 'Cách tính lương tăng ca',
  'body': 'Lương giờ bằng lương tháng chia 176. Mỗi giờ tăng ca tính 1,5 lần.',
  'source': 'payroll_saga.dart',
};

const _fact = GraphFact(
  source: 'overtime-request',
  relation: 'approved_by',
  target: 'role-hr',
  sourceLabel: 'Đơn tăng ca',
  relationLabel: 'do ai duyệt',
  targetLabel: 'HR (nhân sự)',
);

void main() {
  late _MockArticles articles;
  late _MockGraph graph;

  setUpAll(() => registerFallbackValue(<String, Object?>{}));

  setUp(() {
    articles = _MockArticles();
    graph = _MockGraph();
    when(() => articles.contentVersion()).thenAnswer((_) async => 'v1');
    when(
      () => articles.rankAnyWord(
        any(),
        lang: any(named: 'lang'),
        region: any(named: 'region'),
      ),
    ).thenAnswer((_) async => ['overtime']);
    when(
      () => articles.byIds(any(), lang: any(named: 'lang')),
    ).thenAnswer((_) async => [_overtime]);
    when(() => articles.logAnswer(any())).thenAnswer((_) async => 'log-1');
    when(() => graph.linkEntities(any())).thenAnswer((_) async => ['overtime']);
    when(() => graph.articlesFor(any())).thenAnswer((_) async => ['overtime']);
    when(
      () => graph.factsAround(any(), lang: any(named: 'lang')),
    ).thenAnswer((_) async => [_fact]);
  });

  AnswerService service(List<AnswerModel> models, {CacheStore? cache}) =>
      AnswerService(
        articles: articles,
        graph: graph,
        cache: cache,
        models: [
          for (final m in models)
            (model: m, breaker: CircuitBreaker(m.provider)),
        ],
      );

  const input = AskInput(
    question: 'Làm thêm giờ được trả bao nhiêu?',
    lang: 'vi',
    region: 'vn',
    username: 'employee.vn',
  );

  ModelAnswer ok(String text, List<int> citations) => ModelAnswer(
    answerable: true,
    answer: text,
    citations: citations,
    followUps: const ['Ai duyệt đơn tăng ca?'],
  );

  test(
    'Claude hết credit thì Gemini trả lời, nguồn và sự kiện đồ thị đúng',
    () async {
      final claude = _FakeModel(
        'claude',
        (_) async => throw const AnswerError(
          'claude',
          'Your credit balance is too low',
          statusCode: 400,
        ),
      );
      final gemini = _FakeModel(
        'gemini',
        (_) async => ok('Mỗi giờ tăng ca tính 1,5 lần lương giờ [1].', [1]),
      );
      final result = await service([claude, gemini]).ask(input);

      expect(result['provider'], 'gemini');
      expect(result['id'], 'log-1');
      final source = (result['sources'] as List).single as Map;
      expect(source['id'], 'overtime');
      expect(source['via'], ['keyword', 'graph']);
      final sent = gemini.requests.single;
      expect(sent.language, 'Vietnamese');
      expect(sent.facts.single, 'Đơn tăng ca —do ai duyệt→ HR (nhân sự)');
      expect(buildUserMessage(sent), contains('[1] Cách tính lương tăng ca'));
    },
  );

  test('trích dẫn số không có thật thì bị bỏ khỏi câu trả lời', () async {
    final gemini = _FakeModel(
      'gemini',
      (_) async => ok('Tính 1,5 lần [1]. Theo luật [7].', [1, 7]),
    );
    final result = await service([gemini]).ask(input);
    expect(result['answer'], 'Tính 1,5 lần [1]. Theo luật.');
    expect((result['sources'] as List).length, 1);
  });

  test('mọi AI đều hỏng thì vẫn trả đoạn trích từ kho, không bịa', () async {
    final down = _FakeModel(
      'gemini',
      (_) async => throw const AnswerError('gemini', 'quota', statusCode: 429),
    );
    final result = await service([down]).ask(input);
    expect(result['provider'], 'none');
    expect(result['answerable'], isTrue);
    expect(result['answer'], contains('Lương giờ bằng lương tháng chia 176.'));
    expect(result['answer'], contains('[1]'));
    expect(result['answer'], contains('Đơn tăng ca —do ai duyệt→ HR'));
  });

  test('kho không có gì liên quan thì báo chưa có, không gọi AI', () async {
    when(
      () => articles.rankAnyWord(
        any(),
        lang: any(named: 'lang'),
        region: any(named: 'region'),
      ),
    ).thenAnswer((_) async => []);
    when(() => graph.linkEntities(any())).thenAnswer((_) async => []);
    when(() => graph.articlesFor(any())).thenAnswer((_) async => []);
    when(
      () => articles.byIds(any(), lang: any(named: 'lang')),
    ).thenAnswer((_) async => []);
    when(
      () => graph.factsAround(any(), lang: any(named: 'lang')),
    ).thenAnswer((_) async => []);
    final gemini = _FakeModel('gemini', (_) async => ok('x', []));
    final result = await service([gemini]).ask(
      const AskInput(
        question: 'Giá vàng hôm nay?',
        lang: 'vi',
        region: 'vn',
        username: 'employee.vn',
      ),
    );
    expect(result['answerable'], isFalse);
    expect(result['answer'], contains('chưa có thông tin'));
    expect(gemini.requests, isEmpty);
  });

  test('hỏi lại cùng câu thì lấy từ cache, không gọi AI lần hai', () async {
    final cache = _MemoryCache();
    final gemini = _FakeModel('gemini', (_) async => ok('1,5 lần [1].', [1]));
    final s = service([gemini], cache: cache);
    await s.ask(input);
    final second = await s.ask(input);
    expect(second['cached'], isTrue);
    expect(second['provider'], 'gemini');
    expect(gemini.requests.length, 1);
  });

  test('hỏi tiếng Đức thì đọc bài tiếng Anh, trả lời bằng tiếng Đức', () async {
    final gemini = _FakeModel('gemini', (_) async => ok('1,5-fach [1].', [1]));
    await service([gemini]).ask(
      const AskInput(
        question: 'Wie werden Überstunden bezahlt?',
        lang: 'de',
        region: 'de',
        username: 'employee.de',
      ),
    );
    verify(() => articles.byIds(any(), lang: 'en')).called(1);
    expect(gemini.requests.single.language, 'German');
  });

  test(
    'câu nối tiếp tìm theo câu hiện tại trước, câu trước chỉ bổ sung',
    () async {
      when(
        () => graph.linkEntities('Còn đơn tăng ca thì sao?'),
      ).thenAnswer((_) async => ['overtime-request']);
      when(
        () => articles.rankAnyWord(
          'Còn đơn tăng ca thì sao?',
          lang: any(named: 'lang'),
          region: any(named: 'region'),
        ),
      ).thenAnswer((_) async => ['overtime-request']);
      when(
        () => articles.rankAnyWord(
          'Ai duyệt đơn nghỉ phép? Còn đơn tăng ca thì sao?',
          lang: any(named: 'lang'),
          region: any(named: 'region'),
        ),
      ).thenAnswer((_) async => ['leave', 'overtime-request']);
      when(
        () => graph.articlesFor(['overtime-request']),
      ).thenAnswer((_) async => ['overtime-request']);
      final gemini = _FakeModel(
        'gemini',
        (_) async => ok('HR duyệt [1].', [1]),
      );
      await service([gemini]).ask(
        const AskInput(
          question: 'Còn đơn tăng ca thì sao?',
          lang: 'vi',
          region: 'vn',
          username: 'employee.vn',
          history: [Turn('Ai duyệt đơn nghỉ phép?', 'HR duyệt [1].')],
        ),
      );
      final ids =
          verify(
                () => articles.byIds(captureAny(), lang: any(named: 'lang')),
              ).captured.single
              as List<String>;
      expect(ids.first, 'overtime-request');
      expect(
        gemini.requests.single.history.single.question,
        'Ai duyệt đơn nghỉ phép?',
      );
    },
  );

  test('trích dẫn gộp "[1, 2]" được tách thành "[1][2]"', () {
    expect(
      AnswerService.normalizeMarkers(
        'Tính 1,5 lần [1, 2]. Xem thêm [2, 9].',
        2,
      ),
      'Tính 1,5 lần [1][2]. Xem thêm [2].',
    );
  });

  group('vector và gộp xếp hạng', () {
    test('mã hóa vector rồi giải mã lại vẫn như cũ', () {
      final v = <double>[0.25, -1.5, 3];
      expect(decodeVector(encodeVector(v)), v);
    });

    test('cosine: cùng hướng là 1, vuông góc là 0', () {
      expect(cosine([1, 2], [2, 4]), closeTo(1, 1e-9));
      expect(cosine([1, 0], [0, 1]), 0);
    });

    test('bài đứng cao ở nhiều cách tìm thì lên đầu', () {
      final fused = fuseRankings({
        'keyword': ['leave', 'overtime'],
        'semantic': ['overtime', 'clock'],
        'graph': ['overtime'],
      });
      expect(fused.first, 'overtime');
      expect(fused.toSet(), {'overtime', 'leave', 'clock'});
    });
  });
}
