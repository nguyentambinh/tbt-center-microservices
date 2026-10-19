/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:knowledge_service/src/graph/extractor.dart';
import 'package:knowledge_service/src/graph/fold.dart';
import 'package:knowledge_service/src/graph/ontology.dart';
import 'package:knowledge_service/src/graph/rdf.dart';
import 'package:knowledge_service/src/graph/reasoner.dart';
import 'package:knowledge_service/src/graph/sparql.dart';
import 'package:knowledge_service/src/graph/turtle.dart';
import 'package:test/test.dart';

// Bản thể học nhỏ, giống phần chốt lương trong tools/knowledge_graph/build.py
Ontology _ontology() => Ontology(
  classes: const [
    KgClass('thing', null, {'en': 'Thing'}),
    KgClass('activity', 'thing', {'en': 'Activity'}),
    KgClass('process', 'activity', {'en': 'Process'}),
    KgClass('step', 'activity', {'en': 'Step'}),
    KgClass('concept', 'thing', {'en': 'Concept'}),
    KgClass('request', 'concept', {'en': 'Request'}),
    KgClass('rule', 'thing', {'en': 'Rule'}),
    KgClass('role', 'thing', {'en': 'Role'}),
    KgClass('service', 'thing', {'en': 'Service'}),
  ],
  relations: const [
    KgRelation(
      id: 'step_of',
      labels: {'en': 'step of'},
      domain: ['step'],
      range: ['process'],
      inverseOf: 'has_step',
    ),
    KgRelation(
      id: 'has_step',
      labels: {'en': 'has step', 'vi': 'gồm bước'},
      domain: ['process'],
      range: ['step'],
      derived: true,
    ),
    KgRelation(
      id: 'next_step',
      labels: {'en': 'next step'},
      domain: ['step'],
      range: ['step'],
      subPropertyOf: 'precedes',
    ),
    KgRelation(
      id: 'precedes',
      labels: {'en': 'precedes'},
      domain: ['step'],
      range: ['step'],
      transitive: true,
      derived: true,
    ),
    KgRelation(
      id: 'handled_by',
      labels: {'en': 'handled by'},
      domain: ['thing'],
      range: ['service'],
    ),
    KgRelation(
      id: 'depends_on',
      labels: {'en': 'depends on'},
      domain: ['service'],
      range: ['service'],
      transitive: true,
    ),
    KgRelation(
      id: 'involves',
      labels: {'en': 'involves'},
      domain: ['process'],
      range: ['service'],
      derived: true,
    ),
    KgRelation(
      id: 'produces',
      labels: {'en': 'produces'},
      domain: ['activity'],
      range: ['thing'],
    ),
    KgRelation(
      id: 'blocks',
      labels: {'en': 'blocks'},
      domain: ['rule', 'step'],
      range: ['request'],
    ),
    KgRelation(
      id: 'approved_by',
      labels: {'en': 'approved by'},
      domain: ['request', 'step'],
      range: ['role'],
    ),
  ],
  rules: const [
    KgRule(
      id: 'step_of-inverse',
      kind: RuleKind.inverse,
      first: 'step_of',
      result: 'has_step',
    ),
    KgRule(
      id: 'next_step-sub-precedes',
      kind: RuleKind.subproperty,
      first: 'next_step',
      result: 'precedes',
    ),
    KgRule(
      id: 'precedes-transitive',
      kind: RuleKind.transitive,
      first: 'precedes',
      result: 'precedes',
    ),
    KgRule(
      id: 'depends_on-transitive',
      kind: RuleKind.transitive,
      first: 'depends_on',
      result: 'depends_on',
    ),
    KgRule(
      id: 'steps-involve-services',
      kind: RuleKind.chain,
      first: 'has_step',
      second: 'handled_by',
      result: 'involves',
    ),
    KgRule(
      id: 'involve-dependencies',
      kind: RuleKind.chain,
      first: 'involves',
      second: 'depends_on',
      result: 'involves',
    ),
    KgRule(
      id: 'produced-blockers',
      kind: RuleKind.chain,
      first: 'produces',
      second: 'blocks',
      result: 'blocks',
    ),
  ],
);

const _classes = {
  'payroll-closing': 'process',
  'step-lock': 'step',
  'step-rate': 'step',
  'step-pay': 'step',
  'period-lock': 'rule',
  'leave-request': 'request',
  'role-hr': 'role',
  'svc-payroll': 'service',
  'svc-attendance': 'service',
  'svc-currency': 'service',
  'svc-integration': 'service',
  'svc-bank-mock': 'service',
};

const _asserted = [
  Triple('step-lock', 'step_of', 'payroll-closing'),
  Triple('step-rate', 'step_of', 'payroll-closing'),
  Triple('step-pay', 'step_of', 'payroll-closing'),
  Triple('step-lock', 'next_step', 'step-rate'),
  Triple('step-rate', 'next_step', 'step-pay'),
  Triple('step-lock', 'handled_by', 'svc-attendance'),
  Triple('step-rate', 'handled_by', 'svc-currency'),
  Triple('step-pay', 'handled_by', 'svc-payroll'),
  Triple('svc-payroll', 'depends_on', 'svc-integration'),
  Triple('svc-integration', 'depends_on', 'svc-bank-mock'),
  Triple('step-lock', 'produces', 'period-lock'),
  Triple('period-lock', 'blocks', 'leave-request'),
  Triple('leave-request', 'approved_by', 'role-hr'),
];

GraphSnapshot _snapshot({bool withInferred = true}) {
  final o = _ontology();
  final inferred = withInferred
      ? Reasoner(o).run(_asserted, (n) => _classes[n]).inferred
      : const <Triple, Derivation>{};
  return GraphSnapshot(
    ontology: o,
    nodes: [
      for (final e in _classes.entries)
        KgNode(
          id: e.key,
          classId: e.value,
          type: e.value,
          labels: {'en': e.key, 'vi': 'VI ${e.key}'},
        ),
    ],
    edges: [
      for (final t in _asserted) KgEdge(t),
      for (final e in inferred.entries)
        KgEdge(
          e.key,
          origin: 'inferred',
          ruleId: e.value.rule,
          premises: e.value.premises,
        ),
    ],
  );
}

void main() {
  group('Ontology', () {
    test('lớp con được dùng ở chỗ cho phép lớp cha', () {
      final o = _ontology();
      expect(o.isA('request', 'thing'), isTrue);
      expect(o.isA('step', 'process'), isFalse);
      expect(
        o.violation(
          const Triple('step-lock', 'blocks', 'leave-request'),
          (n) => _classes[n],
        ),
        isNull,
      );
    });

    test('sai miền, sai phạm vi, quan hệ lạ đều bị chặn', () {
      final o = _ontology();
      String? check(Triple t) => o.violation(t, (n) => _classes[n]);
      expect(
        check(const Triple('role-hr', 'step_of', 'payroll-closing')),
        'domain:role',
      );
      expect(
        check(const Triple('step-lock', 'step_of', 'role-hr')),
        'range:role',
      );
      expect(
        check(const Triple('step-lock', 'owns', 'role-hr')),
        'unknown_relation',
      );
      expect(
        check(const Triple('step-lock', 'next_step', 'step-lock')),
        'self_loop',
      );
    });
  });

  group('Reasoner', () {
    final result = Reasoner(_ontology()).run(_asserted, (n) => _classes[n]);

    test('chiều ngược và bắc cầu', () {
      expect(
        result.inferred.keys,
        containsAll(const [
          Triple('payroll-closing', 'has_step', 'step-lock'),
          Triple('step-lock', 'precedes', 'step-pay'),
          Triple('svc-payroll', 'depends_on', 'svc-bank-mock'),
        ]),
      );
    });

    test('luật chuỗi đi nhiều bước: chốt lương cần cả ngân hàng giả lập', () {
      expect(
        result.inferred.keys,
        containsAll(const [
          Triple('payroll-closing', 'involves', 'svc-attendance'),
          Triple('payroll-closing', 'involves', 'svc-payroll'),
          Triple('payroll-closing', 'involves', 'svc-bank-mock'),
        ]),
      );
      final d =
          result.inferred[const Triple(
            'payroll-closing',
            'involves',
            'svc-bank-mock',
          )]!;
      expect(d.rule, 'involve-dependencies');
      expect(d.premises.last.relation, 'depends_on');
    });

    test('bước tạo ra quy tắc chặn đơn thì chính bước đó chặn đơn', () {
      final d =
          result.inferred[const Triple('step-lock', 'blocks', 'leave-request')];
      expect(d?.rule, 'produced-blockers');
      expect(d?.premises, const [
        Triple('step-lock', 'produces', 'period-lock'),
        Triple('period-lock', 'blocks', 'leave-request'),
      ]);
    });

    test('không suy ra cạnh đã có, không tự nối vào chính nó', () {
      for (final t in result.inferred.keys) {
        expect(_asserted, isNot(contains(t)));
        expect(t.source, isNot(t.target));
      }
    });

    test('luật sinh cạnh sai phạm vi thì loại và ghi lý do', () {
      final o = _ontology();
      final broken = Ontology(
        classes: o.classes.values.toList(),
        relations: o.relations.values.toList(),
        rules: const [
          KgRule(
            id: 'bad',
            kind: RuleKind.inverse,
            first: 'approved_by',
            result: 'approved_by',
          ),
        ],
      );
      final r = Reasoner(broken).run(_asserted, (n) => _classes[n]);
      expect(r.inferred, isEmpty);
      expect(r.rejected.values.single, startsWith('bad: domain:role'));
    });
  });

  group('SPARQL', () {
    final store = TripleStore(_snapshot().rdfTriples());
    SparqlResult run(String q) => SparqlEngine(store).query(q);
    List<String> column(SparqlResult r, String v) => [
      for (final row in r.rows) '${row[v]}',
    ];

    test('mẫu bộ ba và lớp cha qua rdf:type', () {
      final r = run(
        'SELECT ?r WHERE { kg:leave-request kgo:approved_by ?r . '
        '?r a kgo:thing }',
      );
      expect(column(r, 'r'), ['kg:role-hr']);
    });

    test('đường thuộc tính + và cạnh suy ra', () {
      final r = run('''
        SELECT DISTINCT ?svc WHERE { kg:payroll-closing ^kgo:step_of/kgo:handled_by/kgo:depends_on* ?svc }
        ORDER BY ?svc''');
      expect(column(r, 'svc'), [
        'kg:svc-attendance',
        'kg:svc-bank-mock',
        'kg:svc-currency',
        'kg:svc-integration',
        'kg:svc-payroll',
      ]);
      final inferred = run(
        'SELECT ?s WHERE { kg:payroll-closing kgo:involves ?s }',
      );
      expect(inferred.rows, hasLength(5));
    });

    test('FILTER, OPTIONAL, nhãn theo ngôn ngữ', () {
      final r = run('''
        SELECT ?s ?label WHERE {
          ?s a kgo:step .
          OPTIONAL { ?s rdfs:label ?label FILTER(LANG(?label) = "vi") }
          FILTER(STRSTARTS(STR(?s), "http://tbt-center.local/kg/step-p"))
        }''');
      expect(column(r, 's'), ['kg:step-pay']);
      expect(column(r, 'label'), ['"VI step-pay"@vi']);
    });

    test('UNION và COUNT theo nhóm', () {
      final r = run('''
        SELECT ?p (COUNT(?x) AS ?n) WHERE {
          { ?x kgo:step_of ?p } UNION { ?x kgo:produces ?p }
        } GROUP BY ?p ORDER BY DESC(?n)''');
      expect(column(r, 'p').first, 'kg:payroll-closing');
      expect(column(r, 'n').first, '"3"');
    });

    test('biến ở vị trí quan hệ', () {
      final r = run('SELECT ?p WHERE { kg:step-lock ?p kg:step-rate }');
      expect(column(r, 'p'), containsAll(['kgo:next_step', 'kgo:precedes']));
    });

    test('câu sai cú pháp báo lỗi rõ', () {
      expect(
        () => run('SELECT ?x WHERE { ?x kgo:a '),
        throwsA(isA<SparqlError>()),
      );
      expect(
        () => run('DELETE WHERE { ?x ?p ?o }'),
        throwsA(isA<SparqlError>()),
      );
      expect(
        () => run('SELECT ?x WHERE { ?x foo:bar ?y }'),
        throwsA(isA<SparqlError>()),
      );
    });
  });

  group('Turtle', () {
    test('lớp, quan hệ, luật chuỗi xuất đúng cú pháp OWL', () {
      final ttl = toTurtle(_snapshot(withInferred: false));
      expect(
        ttl,
        contains('kgo:step a owl:Class ;\n  rdfs:subClassOf kgo:activity'),
      );
      expect(
        ttl,
        contains('kgo:precedes a owl:ObjectProperty, owl:TransitiveProperty'),
      );
      expect(
        ttl,
        contains('owl:propertyChainAxiom ( kgo:has_step kgo:handled_by )'),
      );
      expect(
        ttl,
        contains(
          'rdfs:domain [ a owl:Class ; owl:unionOf ( kgo:rule kgo:step ) ]',
        ),
      );
      expect(ttl, contains('kg:step-lock a kgo:step'));
      expect(ttl, isNot(contains('kgo:involves kg:')));
    });
  });

  group('Kiểm đề xuất của AI', () {
    const article = (
      id: 'leave',
      lang: 'vi',
      title: 'Xin nghỉ phép',
      body:
          'Đơn nghỉ phép do HR duyệt. '
          'Khi khóa kỳ, hệ thống dùng service chấm công.',
      hash: 'h',
    );

    test('câu trích phải có thật trong bài, đúng miền và phạm vi', () {
      final out = validateExtraction(
        {
          'nodes': [
            {
              'id': 'leave-balance',
              'class': 'concept',
              'labels': {'vi': 'Số ngày phép còn lại', 'en': 'Leave balance'},
              'aliases': ['so ngay phep'],
              'summary': {'vi': 'x', 'en': 'x'},
            },
          ],
          'edges': [
            {
              'source': 'step-lock',
              'relation': 'handled_by',
              'target': 'svc-payroll',
              'evidence': 'Khi khóa kỳ, hệ thống dùng service chấm công.',
              'confidence': 0.9,
            },
            {
              'source': 'leave-request',
              'relation': 'approved_by',
              'target': 'role-hr',
              'evidence': 'Đơn nghỉ phép do HR duyệt',
              'confidence': 0.95,
            },
            {
              'source': 'role-hr',
              'relation': 'approved_by',
              'target': 'leave-request',
              'evidence': 'Đơn nghỉ phép do HR duyệt',
              'confidence': 0.9,
            },
            {
              'source': 'step-pay',
              'relation': 'handled_by',
              'target': 'svc-currency',
              'evidence': 'Tỷ giá lấy từ currency',
              'confidence': 0.9,
            },
            {
              'source': 'step-lock',
              'relation': 'has_step',
              'target': 'step-pay',
              'evidence': 'Khi khóa kỳ, hệ thống dùng service chấm công.',
              'confidence': 0.9,
            },
          ],
        },
        _snapshot(),
        article,
      );
      Map<String, dynamic> edge(String s, String r) => out.firstWhere(
        (p) =>
            p['kind'] == 'edge' &&
            (p['payload'] as Map)['source'] == s &&
            (p['payload'] as Map)['relation'] == r,
      );
      expect(edge('step-lock', 'handled_by')['status'], 'pending');
      // Đã có trong đồ thị thì không đề xuất lại
      expect(
        out.where((p) => (p['payload'] as Map)['source'] == 'leave-request'),
        isEmpty,
      );
      expect(edge('role-hr', 'approved_by')['reason'], 'domain:role');
      expect(
        edge('step-pay', 'handled_by')['reason'],
        'evidence_not_in_article',
      );
      expect(edge('step-lock', 'has_step')['reason'], 'bad_relation');
      final node = out.firstWhere((p) => p['kind'] == 'node');
      expect(node['reason'], 'unused_node');
    });

    test(
      'nút mới dùng trong cạnh hợp lệ thì chờ duyệt, tên gọi khác được bỏ dấu',
      () {
        final out = validateExtraction(
          {
            'nodes': [
              {
                'id': 'leave-balance',
                'class': 'concept',
                'labels': {'vi': 'Số ngày phép còn lại', 'en': 'Leave balance'},
                'aliases': ['Số ngày phép'],
                'summary': {'vi': 'x', 'en': 'x'},
              },
            ],
            'edges': [
              {
                'source': 'leave-balance',
                'relation': 'handled_by',
                'target': 'svc-attendance',
                'evidence': '"Khi khóa kỳ, hệ thống dùng service chấm công."',
                'confidence': 0.7,
              },
            ],
          },
          _snapshot(),
          article,
        );
        final node = out.firstWhere((p) => p['kind'] == 'node');
        expect(node['status'], 'pending');
        expect((node['payload'] as Map)['aliases'], contains('so ngay phep'));
        expect((node['payload'] as Map)['type'], 'concept');
        expect(out.firstWhere((p) => p['kind'] == 'edge')['status'], 'pending');
      },
    );
  });

  test('fold bỏ dấu giống kb_unaccent', () {
    expect(fold('  Đơn  NGHỈ phép '), 'don nghi phep');
    expect(fold('Überstunden Straße'), 'uberstunden strasse');
  });
}
