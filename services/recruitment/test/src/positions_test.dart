/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recruitment_service/src/ai/claude_client.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/positions.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/me/index.dart' as me_route;
import '../../routes/positions/index.dart' as positions_route;

class _MockContext extends Mock implements RequestContext {}

class _MockPositions extends Mock implements PositionRepository {}

class _MockCandidates extends Mock implements CandidateRepository {}

Matcher _code(String code) => throwsA(
  isA<CandidateRuleViolation>().having((e) => e.code, 'code', code),
);

Claims _claims(List<String> roles) => Claims({
  'sub': 'sub-1',
  'preferred_username': 'hr.vn',
  'realm_access': {'roles': roles},
});

void main() {
  group('checkPositionInput', () {
    test('cần tên và số người 1–500', () {
      expect(
        () => checkPositionInput(const PositionInput(title: ' ', headcount: 2)),
        _code('invalid_title'),
      );
      expect(
        () => checkPositionInput(
          const PositionInput(title: 'Kỹ sư', headcount: 0),
        ),
        _code('invalid_headcount'),
      );
    });

    test('không hạ số người thấp hơn số đã tuyển', () {
      expect(
        () => checkPositionInput(
          const PositionInput(title: 'Kỹ sư', headcount: 1),
          hired: 2,
        ),
        _code('headcount_below_hired'),
      );
      expect(
        () => checkPositionInput(
          const PositionInput(title: 'Kỹ sư', headcount: 2),
          hired: 2,
        ),
        returnsNormally,
      );
    });
  });

  group('checkSelection', () {
    const found = {
      1: (status: 'open', remaining: 2),
      2: (status: 'open', remaining: 0),
      3: (status: 'closed', remaining: 1),
    };

    test('chọn một hoặc nhiều vị trí đang mở', () {
      expect(() => checkSelection([1], found), returnsNormally);
      expect(() => checkSelection([], found), _code('no_position'));
      expect(
        () => checkSelection([1, 2, 3, 4, 5, 6], found),
        _code('too_many_positions'),
      );
      expect(() => checkSelection([9], found), _code('position_not_found'));
    });

    test('vị trí đã đủ người hoặc đã đóng thì không chọn mới được', () {
      expect(
        () => checkSelection([1, 2], found),
        _code('position_unavailable'),
      );
      expect(() => checkSelection([3], found), _code('position_unavailable'));
    });

    test('vị trí đã chọn từ trước vẫn giữ được khi sửa hồ sơ', () {
      expect(
        () => checkSelection([1, 2], found, current: {2}),
        returnsNormally,
      );
    });
  });

  test('kết quả AI chỉ giữ vị trí ứng viên đã chọn, điểm trong 0–100', () {
    final matches = normalizeMatches(
      [
        {'positionId': 1, 'score': 140, 'verdict': 'Rất hợp'},
        {'positionId': '2', 'score': -5},
        {'positionId': 1, 'score': 10},
        {'positionId': 7, 'score': 90},
        'rác',
      ],
      {1, 2},
    );
    expect([for (final m in matches) (m.id, m.score)], [(1, 100), (2, 0)]);
    expect(matches.first.verdict, 'Rất hợp');
    expect(normalizeMatches(null, {1}), isEmpty);
  });

  test('lời nhắc AI liệt kê từng vị trí kèm yêu cầu', () {
    final prompt = positionPrompt(const [
      PositionBrief(
        id: 4,
        title: 'Kỹ sư kết cấu',
        department: 'Kỹ thuật',
        requirements: 'SAP2000, 3 năm kinh nghiệm',
      ),
    ]);
    expect(prompt, contains('positionId 4: Kỹ sư kết cấu (Kỹ thuật)'));
    expect(prompt, contains('SAP2000'));
    expect(positionPrompt(const []), contains('empty list'));
    expect(cvSummaryFields, contains('positionMatches'));
  });

  group('routes', () {
    late _MockContext context;
    late _MockPositions positions;
    late _MockCandidates candidates;

    setUpAll(() {
      registerFallbackValue(const PositionInput(title: 'x', headcount: 1));
      registerFallbackValue(const CandidateProfileInput(fullName: 'x'));
    });

    setUp(() {
      context = _MockContext();
      positions = _MockPositions();
      candidates = _MockCandidates();
      when(() => context.read<PositionRepository>()).thenReturn(positions);
      when(() => context.read<CandidateRepository>()).thenReturn(candidates);
    });

    void request(String method, String path, Object? body, List<String> roles) {
      when(() => context.request).thenReturn(
        Request(
          method,
          Uri.parse('http://localhost$path'),
          body: body == null ? null : jsonEncode(body),
        ),
      );
      when(() => context.read<Claims>()).thenReturn(_claims(roles));
    }

    test('ứng viên chỉ thấy vị trí đang tuyển, không mở vị trí được', () async {
      when(
        () => positions.list(openOnly: any(named: 'openOnly')),
      ).thenAnswer((_) async => []);
      request('GET', '/positions?all=1', null, ['candidate']);
      await positions_route.onRequest(context);
      verify(() => positions.list(openOnly: true)).called(1);

      request(
        'POST',
        '/positions',
        {
          'title': 'Kỹ sư',
          'headcount': 2,
        },
        ['candidate'],
      );
      expect((await positions_route.onRequest(context)).statusCode, 403);
    });

    test('HR mở vị trí; trùng tên vị trí đang mở thì 409', () async {
      when(
        () => positions.create(any(), by: any(named: 'by')),
      ).thenAnswer((_) async => {'id': 1, 'title': 'Kỹ sư'});
      request(
        'POST',
        '/positions',
        {
          'title': 'Kỹ sư',
          'headcount': 3,
        },
        ['hr'],
      );
      final created = await positions_route.onRequest(context);
      expect(created.statusCode, 201);
      final input =
          verify(
                () => positions.create(captureAny(), by: 'hr.vn'),
              ).captured.single
              as PositionInput;
      expect(input.headcount, 3);

      when(() => positions.create(any(), by: any(named: 'by'))).thenThrow(
        const CandidateRuleViolation('title_exists', 'exists'),
      );
      expect((await positions_route.onRequest(context)).statusCode, 409);
    });

    test('PUT /me gửi kèm danh sách vị trí đã tick', () async {
      when(
        () => candidates.saveOwnProfile(any(), any(), any()),
      ).thenAnswer((_) async => {});
      when(
        () => candidates.findBySubject('sub-1'),
      ).thenAnswer((_) async => {'id': 'C1'});
      request(
        'PUT',
        '/me',
        {
          'fullName': 'Lê Minh Thư',
          'positionIds': [3, '5', 'x'],
        },
        ['candidate'],
      );
      expect((await me_route.onRequest(context)).statusCode, 200);
      final input =
          verify(
                () => candidates.saveOwnProfile('sub-1', any(), captureAny()),
              ).captured.single
              as CandidateProfileInput;
      expect(input.positionIds, [3, 5]);
    });
  });
}
