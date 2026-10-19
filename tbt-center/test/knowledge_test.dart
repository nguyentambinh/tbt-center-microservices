/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/features/knowledge/domain/entities/answer.dart';
import 'package:tbtcenter/features/knowledge/domain/entities/article.dart';
import 'package:tbtcenter/core/error/app_failure.dart';
import 'package:tbtcenter/features/knowledge/domain/entities/knowledge_graph.dart';
import 'package:tbtcenter/features/knowledge/domain/entities/ontology.dart';
import 'package:tbtcenter/features/knowledge/domain/repositories/knowledge_repository.dart';
import 'package:tbtcenter/features/knowledge/presentation/providers/knowledge_providers.dart';
import 'package:tbtcenter/features/knowledge/presentation/widgets/graph_canvas.dart';

import 'helpers.dart';

class FakeKnowledgeRepository implements KnowledgeRepository {
  final queries = <String>[];
  final questions = <(String, List<(String, String)>)>[];
  final feedbacks = <(String, bool)>[];
  String provider = 'gemini';

  @override
  Future<List<ArticleHit>> search(String query, {required String lang}) async {
    queries.add(query);
    const all = [
      ArticleHit(id: 'overtime', title: 'Cách tính tiền tăng ca', category: 'payroll', snippet: 'Giờ <<tăng ca>> ngày thường x1,5'),
      ArticleHit(id: 'leave', title: 'Nghỉ phép năm', category: 'attendance', snippet: 'Mỗi năm 12 ngày phép'),
    ];
    return query.isEmpty ? all : [all.first];
  }

  @override
  Future<Article> article(String id, {required String lang}) async => const Article(
        id: 'overtime',
        title: 'Cách tính tiền tăng ca',
        category: 'payroll',
        body: 'Giờ tăng ca ngày thường nhân 1,5 lương giờ.',
        source: 'Bộ luật Lao động 2019, Điều 98',
      );

  @override
  Future<Answer> ask(String question, {required String lang, List<(String, String)> history = const []}) async {
    questions.add((question, history));
    return Answer(
      id: 'a${questions.length}',
      answerable: true,
      answer: 'Mỗi giờ tăng ca tính 1,5 lần lương giờ [1]. HR duyệt đơn tăng ca.',
      sources: const [
        AnswerSource(n: 1, id: 'overtime', title: 'Cách tính lương tăng ca', via: ['keyword', 'graph']),
      ],
      facts: const [AnswerFact(source: 'Đơn tăng ca', relation: 'do ai duyệt', target: 'HR (nhân sự)')],
      followUps: const ['Ai duyệt đơn tăng ca?'],
      provider: provider,
      model: provider == 'none' ? null : 'gemini-3.8-flash',
    );
  }

  @override
  Future<void> feedback(String answerId, {required bool helpful}) async => feedbacks.add((answerId, helpful));

  @override
  Future<List<GraphNode>> graphNodes(String query, {required String lang}) async => [
        const GraphNode(id: 'overtime', type: NodeType.concept, label: 'Tăng ca', degree: 4),
      ];

  @override
  Future<GraphView> graph(String id, {required String lang}) async => id == 'overtime'
      ? const GraphView(
          center: GraphNode(id: 'overtime', type: NodeType.concept, label: 'Tăng ca', summary: 'Giờ làm thêm.'),
          nodes: [
            GraphNode(id: 'overtime', type: NodeType.concept, label: 'Tăng ca'),
            GraphNode(id: 'overtime-request', type: NodeType.concept, label: 'Đơn tăng ca'),
            GraphNode(id: 'doc-overtime', type: NodeType.document, label: 'Cách tính lương tăng ca', articleId: 'overtime'),
          ],
          edges: [
            GraphEdge(source: 'overtime', target: 'overtime-request', label: 'do ai tạo'),
            GraphEdge(source: 'overtime', target: 'doc-overtime', label: 'giải thích trong bài'),
          ],
        )
      : const GraphView(
          center: GraphNode(
              id: 'payroll-closing', type: NodeType.process, label: 'Chốt lương', summary: 'Quy trình nhiều bước.'),
          nodes: [
            GraphNode(id: 'payroll-closing', type: NodeType.process, label: 'Chốt lương'),
            GraphNode(id: 'step-lock', type: NodeType.step, label: '1. Khóa kỳ'),
            GraphNode(id: 'role-finance', type: NodeType.role, label: 'Tài chính'),
            GraphNode(id: 'svc-bank-mock', type: NodeType.service, label: 'bank_mock'),
          ],
          edges: [
            GraphEdge(source: 'step-lock', target: 'payroll-closing', label: 'là bước của'),
            GraphEdge(source: 'payroll-closing', target: 'role-finance', label: 'do ai khởi động'),
            GraphEdge(
              source: 'payroll-closing',
              target: 'svc-bank-mock',
              label: 'có sự tham gia của',
              origin: 'inferred',
              rule: 'Quy trình cần service S, S gọi service T thì quy trình cũng cần T',
              because: ['Chốt lương —có sự tham gia của→ integration', 'integration —gọi tới→ bank_mock'],
            ),
          ],
        );

  final reviews = <(String, bool)>[];
  final sparqlQueries = <String>[];

  @override
  Future<GraphPath?> graphPath(String from, String to, {required String lang}) async => GraphPath(
        from: const GraphNode(id: 'payroll-closing', type: NodeType.process, label: 'Chốt lương'),
        to: const GraphNode(id: 'svc-bank-mock', type: NodeType.service, label: 'bank_mock'),
        steps: const [
          (
            node: GraphNode(id: 'svc-bank-mock', type: NodeType.service, label: 'bank_mock'),
            edge: GraphEdge(
                source: 'payroll-closing', target: 'svc-bank-mock', label: 'có sự tham gia của', origin: 'inferred'),
            forward: true,
          ),
        ],
      );

  @override
  Future<OntologyInfo> ontology({required String lang}) async => const OntologyInfo(
        classes: [
          (id: 'thing', parent: null, label: 'Sự vật', nodes: 0),
          (id: 'activity', parent: 'thing', label: 'Hoạt động', nodes: 0),
          (id: 'step', parent: 'activity', label: 'Bước', nodes: 9),
          (id: 'process', parent: 'activity', label: 'Quy trình', nodes: 3),
        ],
        relations: [
          OntologyRelation(
            id: 'precedes',
            label: 'đứng trước',
            summary: 'Bước A làm trước bước B.',
            domain: ['step'],
            range: ['step'],
            transitive: true,
            derived: true,
            edges: 57,
          ),
        ],
        rules: [(id: 'precedes-transitive', kind: 'transitive', label: '"đứng trước" có tính bắc cầu')],
        totals: {'nodes': 167, 'asserted': 484, 'extracted': 3, 'inferred': 222},
        reasoning: {'inferred': 222, 'ms': 22},
      );

  @override
  Future<SparqlAnswer> sparql(String query, {required String lang, bool inferred = true}) async {
    sparqlQueries.add(query);
    if (query.contains('lỗi')) {
      throw const AppFailure(FailureKind.validation,
          statusCode: 400, serverCode: 'bad_query', serverMessage: 'expected "}"');
    }
    return const SparqlAnswer(
      vars: ['service'],
      rows: [
        {'service': (value: 'kg:svc-bank-mock', label: 'bank_mock', iri: true)},
        {'service': (value: 'kg:svc-payroll', label: 'payroll', iri: true)},
      ],
      ms: 2,
    );
  }

  @override
  Future<ProposalList> proposals({String? status}) async => ProposalList(
        running: false,
        configured: true,
        items: [
          if (status == 'pending')
            const GraphProposal(
              id: 'p1',
              articleId: 'suppliers',
              kind: 'edge',
              status: 'pending',
              payload: {'source': 'supplier-debt', 'relation': 'calculated_from', 'target': 'material-purchase'},
              evidence: 'Công nợ nhà cung cấp bằng tổng tiền mua vật liệu trừ tổng tiền đã trả.',
              confidence: 0.95,
              model: 'gemini-3.5-flash',
            ),
        ],
      );

  @override
  Future<int> extract({String? articleId}) async => 15;

  @override
  Future<void> reviewProposal(String id, {required bool approve, String? reason}) async =>
      reviews.add((id, approve));

  @override
  Future<void> runReasoner() async {}
}

Future<void> _openMenu(WidgetTester tester, String item) async {
  await tester.tap(find.byTooltip('Thêm'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item));
  await tester.pumpAndSettle();
}

Future<FakeKnowledgeRepository> _pump(WidgetTester tester, List<String> roles) async {
  final knowledge = FakeKnowledgeRepository();
  final overrides = await testOverrides(
    language: 'vi',
    store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles))),
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [...overrides, knowledgeRepositoryProvider.overrideWithValue(knowledge)],
    child: const TbtApp(),
  ));
  await tester.pumpAndSettle();
  return knowledge;
}

TextSpan? _span(WidgetTester tester, String text) {
  TextSpan? found;
  for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.text == text) found = span;
      return found == null;
    });
  }
  return found;
}

void main() {
  testWidgets('hỏi AI: câu trả lời có nguồn, đồ thị, gợi ý; chạm số nguồn mở bài; chấm điểm', (tester) async {
    final knowledge = await _pump(tester, ['employee']);
    await openHomeCard(tester, 'Kho tri thức');
    expect(find.text('Làm thêm giờ được trả bao nhiêu?'), findsOneWidget);

    await tester.tap(find.text('Làm thêm giờ được trả bao nhiêu?'));
    await tester.pumpAndSettle();
    expect(knowledge.questions.single.$1, 'Làm thêm giờ được trả bao nhiêu?');
    expect(find.textContaining('Mỗi giờ tăng ca tính 1,5 lần lương giờ'), findsOneWidget);
    expect(find.text('Cách tính lương tăng ca'), findsOneWidget);
    expect(find.text('từ khóa · đồ thị'), findsOneWidget);
    expect(find.text('Trả lời bởi Gemini · gemini-3.8-flash'), findsOneWidget);

    await tester.tap(find.text('Dựa trên đồ thị tri thức'));
    await tester.pumpAndSettle();
    expect(find.textContaining('do ai duyệt', findRichText: true), findsOneWidget);

    // Số [1] trong câu đứng trước số 1 ở danh sách nguồn
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    expect(find.text('Bộ luật Lao động 2019, Điều 98'), findsOneWidget);
    Navigator.of(tester.element(find.text('Bộ luật Lao động 2019, Điều 98'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Hữu ích'));
    await tester.pumpAndSettle();
    expect(knowledge.feedbacks.single, ('a1', true));
    expect(find.text('Cảm ơn góp ý của bạn'), findsOneWidget);

    // Câu hỏi nối tiếp gửi kèm lượt trước
    await tester.tap(find.text('Ai duyệt đơn tăng ca?'));
    await tester.pumpAndSettle();
    expect(knowledge.questions.last.$2.single.$1, 'Làm thêm giờ được trả bao nhiêu?');
  });

  testWidgets('không còn AI thì báo rõ là trích từ kho', (tester) async {
    final knowledge = await _pump(tester, ['employee']);
    knowledge.provider = 'none';
    await openHomeCard(tester, 'Kho tri thức');
    await tester.enterText(find.byType(TextField), 'Tăng ca tính sao?');
    await tester.tap(find.byTooltip('Gửi'));
    await tester.pumpAndSettle();
    expect(find.text('Không dùng AI, trích trực tiếp từ kho'), findsOneWidget);
  });

  testWidgets('tìm bài: từ khớp in đậm, mở bài thấy nội dung', (tester) async {
    final knowledge = await _pump(tester, ['employee']);
    await openHomeCard(tester, 'Kho tri thức');
    await tester.tap(find.text('Tìm bài'));
    await tester.pumpAndSettle();
    expect(find.text('Nghỉ phép năm'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'tang ca');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(knowledge.queries.last, 'tang ca');
    expect(find.text('Nghỉ phép năm'), findsNothing);
    expect(_span(tester, 'tăng ca')?.style?.fontWeight, FontWeight.w800);

    await tester.tap(find.text('Cách tính tiền tăng ca'));
    await tester.pumpAndSettle();
    expect(find.text('Giờ tăng ca ngày thường nhân 1,5 lương giờ.'), findsOneWidget);
  });

  testWidgets('đồ thị: vẽ nút, tìm khái niệm để đổi tâm, đọc bài, hỏi AI về nút', (tester) async {
    final semantics = tester.ensureSemantics();
    final knowledge = await _pump(tester, ['hr']);
    await openHomeCard(tester, 'Kho tri thức');
    await tester.tap(find.text('Đồ thị'));
    await tester.pumpAndSettle();
    expect(find.byType(GraphCanvas), findsOneWidget);
    expect(find.semantics.byLabel('1. Khóa kỳ'), findsOne);
    final panel = find.descendant(of: find.byType(ListView).last, matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.text('1. Khóa kỳ → là bước của'), 80, scrollable: panel);
    expect(find.text('1. Khóa kỳ → là bước của'), findsOneWidget);
    expect(find.text('do ai khởi động → Tài chính'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'tang');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tăng ca'));
    await tester.pumpAndSettle();
    expect(find.text('Giờ làm thêm.'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Đọc bài'), -80, scrollable: panel);
    await tester.tap(find.text('Đọc bài'));
    await tester.pumpAndSettle();
    expect(find.text('Giờ tăng ca ngày thường nhân 1,5 lương giờ.'), findsOneWidget);
    Navigator.of(tester.element(find.text('Giờ tăng ca ngày thường nhân 1,5 lương giờ.'))).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Hỏi AI về mục này'));
    await tester.tap(find.text('Hỏi AI về mục này'));
    await tester.pumpAndSettle();
    expect(knowledge.questions.single.$1, 'Giải thích giúp tôi về Tăng ca');
    expect(find.textContaining('Mỗi giờ tăng ca tính 1,5 lần'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('đồ thị: cạnh suy ra có giải thích, tìm đường nối hai nút', (tester) async {
    await _pump(tester, ['employee']);
    await openHomeCard(tester, 'Kho tri thức');
    await tester.tap(find.text('Đồ thị'));
    await tester.pumpAndSettle();
    final panel = find.descendant(of: find.byType(ListView).last, matching: find.byType(Scrollable)).first;
    final inferred = find.text('có sự tham gia của → bank_mock');
    await tester.scrollUntilVisible(inferred, 80, scrollable: panel);
    await tester.ensureVisible(inferred);
    await tester.pumpAndSettle();
    await tester.tap(inferred);
    await tester.pumpAndSettle();
    expect(find.textContaining('Máy suy ra bằng luật'), findsOneWidget);
    expect(find.text('• integration —gọi tới→ bank_mock'), findsOneWidget);
    await tester.tap(find.text('Mở nút này'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đồ thị'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Nối tới…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nối tới…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tăng ca').last);
    await tester.pumpAndSettle();
    expect(find.text('Từ Chốt lương tới Tăng ca'), findsOneWidget);
    expect(find.text('có sự tham gia của (Suy ra)'), findsOneWidget);
  });

  testWidgets('bản thể học: tổng số, cây lớp, quan hệ kèm tính chất, luật', (tester) async {
    await _pump(tester, ['employee']);
    await openHomeCard(tester, 'Kho tri thức');
    await _openMenu(tester, 'Bản thể học');
    expect(find.textContaining('167 nút · 484 cạnh có sẵn · 3 cạnh AI trích · 222 cạnh suy ra'), findsOneWidget);
    expect(find.text('Lần suy luận gần nhất: 222 cạnh mới trong 22 ms'), findsOneWidget);
    expect(find.text('Bước'), findsOneWidget);
    expect(find.text('Bước  →  Bước'), findsOneWidget);
    expect(find.text('bắc cầu'), findsOneWidget);
    expect(find.text('chỉ do suy luận'), findsOneWidget);
    // Nhân viên không có nút chạy lại suy luận
    expect(find.text('Chạy lại suy luận'), findsNothing);
    await tester.scrollUntilVisible(find.text('"đứng trước" có tính bắc cầu'), 200);
    expect(find.text('"đứng trước" có tính bắc cầu'), findsOneWidget);
  });

  testWidgets('SPARQL: câu mẫu chạy ra bảng, câu sai báo lỗi ngay dưới ô nhập', (tester) async {
    final knowledge = await _pump(tester, ['employee']);
    await openHomeCard(tester, 'Kho tri thức');
    await _openMenu(tester, 'Truy vấn SPARQL');
    await tester.tap(find.text('Chốt lương cần service nào'));
    await tester.pumpAndSettle();
    expect(knowledge.sparqlQueries.single, contains('kgo:involves'));
    expect(find.text('2 dòng · 2 ms'), findsOneWidget);
    expect(find.text('bank_mock'), findsOneWidget);
    expect(find.text('kg:svc-bank-mock'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'SELECT lỗi');
    await tester.tap(find.text('Chạy'));
    await tester.pumpAndSettle();
    expect(find.text('Câu truy vấn lỗi: expected "}"'), findsOneWidget);
  });

  testWidgets('đề xuất AI: HR thấy câu trích và duyệt; nhân viên không có mục này', (tester) async {
    var knowledge = await _pump(tester, ['employee']);
    await openHomeCard(tester, 'Kho tri thức');
    await tester.tap(find.byTooltip('Thêm'));
    await tester.pumpAndSettle();
    expect(find.text('Đề xuất từ AI'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    knowledge = await _pump(tester, ['hr']);
    await openHomeCard(tester, 'Kho tri thức');
    await _openMenu(tester, 'Đề xuất từ AI');
    expect(find.text('“Công nợ nhà cung cấp bằng tổng tiền mua vật liệu trừ tổng tiền đã trả.”'), findsOneWidget);
    expect(find.textContaining('Độ tin cậy 95%'), findsOneWidget);
    await tester.tap(find.text('Duyệt'));
    await tester.pumpAndSettle();
    expect(knowledge.reviews.single, ('p1', true));
    expect(find.text('Đã thêm vào đồ thị, máy đang suy luận lại'), findsOneWidget);

    await tester.tap(find.byTooltip('Cho AI đọc bài mới'));
    await tester.pumpAndSettle();
    expect(find.text('AI sẽ đọc 15 bài'), findsOneWidget);
  });

  testWidgets('ứng viên không thấy thẻ Kho tri thức', (tester) async {
    await _pump(tester, ['candidate']);
    expect(find.text('Kho tri thức'), findsNothing);
  });

  test('bố trí đồ thị: nút giữa đứng yên, mọi nút nằm trong khung, chạy lại ra y hệt', () {
    const view = GraphView(
      center: GraphNode(id: 'c', type: NodeType.process, label: 'C'),
      nodes: [
        GraphNode(id: 'c', type: NodeType.process, label: 'C'),
        GraphNode(id: 'a', type: NodeType.step, label: 'A'),
        GraphNode(id: 'b', type: NodeType.role, label: 'B'),
        GraphNode(id: 'd', type: NodeType.rule, label: 'D'),
      ],
      edges: [
        GraphEdge(source: 'a', target: 'c', label: 'x'),
        GraphEdge(source: 'c', target: 'b', label: 'y'),
        GraphEdge(source: 'b', target: 'd', label: 'z'),
      ],
    );
    const size = Size(400, 400);
    final first = layoutGraph(view, size);
    expect(first['c'], const Offset(200, 200));
    for (final p in first.values) {
      expect(const Rect.fromLTWH(0, 0, 400, 400).contains(p), isTrue);
    }
    expect(layoutGraph(view, size), first);
  });
}
