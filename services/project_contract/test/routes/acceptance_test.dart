/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_contract_service/src/data/project_repository.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/acceptances/[projectId].dart' as route;

class _MockContext extends Mock implements RequestContext {}

class _MockRepository extends Mock implements ProjectRepository {}

class _MockFinance extends Mock implements InternalClient {}

void main() {
  late _MockContext context;
  late _MockRepository repository;
  late _MockFinance finance;

  setUpAll(() => registerFallbackValue(DateTime(2026)));

  setUp(() {
    context = _MockContext();
    repository = _MockRepository();
    finance = _MockFinance();
    when(() => context.read<ProjectRepository>()).thenReturn(repository);
    when(() => context.read<InternalClient>()).thenReturn(finance);
    // Repository giả gọi đúng bước ghi doanh thu như repository thật.
    when(
      () => repository.accept(
        any(),
        acceptedBy: any(named: 'acceptedBy'),
        acceptedOn: any(named: 'acceptedOn'),
        recordRevenue: any(named: 'recordRevenue'),
      ),
    ).thenAnswer((inv) async {
      final record =
          inv.namedArguments[#recordRevenue]
              as Future<void> Function(String amount);
      await record('123870000.00');
      return {'id': 'P1', 'status': 'accepted'};
    });
  });

  void request(List<String> roles) {
    when(() => context.request).thenReturn(
      Request('POST', Uri.parse('http://localhost/acceptances/P1')),
    );
    when(() => context.read<Claims>()).thenReturn(
      Claims({
        'preferred_username': 'finance.vn',
        'realm_access': {'roles': roles},
      }),
    );
  }

  test(
    'tài chính nghiệm thu: ghi doanh thu ở finance rồi đổi trạng thái',
    () async {
      when(
        () => finance.post(
          '/internal/acceptances',
          any(),
          correlationId: any(named: 'correlationId'),
        ),
      ).thenAnswer((_) async => {'created': true});
      request(['finance']);

      final response = await route.onRequest(context, 'P1');
      expect(response.statusCode, 200);
      final sent =
          verify(
                () => finance.post(
                  '/internal/acceptances',
                  captureAny(),
                  correlationId: any(named: 'correlationId'),
                ),
              ).captured.single
              as Map;
      expect(sent['projectId'], 'P1');
      expect(sent['amount'], '123870000.00');
    },
  );

  test('finance không trả lời thì 503, không đổi trạng thái', () async {
    when(
      () => finance.post(
        any(),
        any(),
        correlationId: any(named: 'correlationId'),
      ),
    ).thenThrow(const InternalCallException('finance', 'timeout'));
    request(['finance']);

    final body = await (await route.onRequest(context, 'P1')).json() as Map;
    expect(body['code'], 'finance_unavailable');
  });

  test('HR không nghiệm thu được', () async {
    request(['hr']);
    expect((await route.onRequest(context, 'P1')).statusCode, 403);
  });

  test('đã nghiệm thu rồi thì 409', () async {
    when(
      () => repository.accept(
        any(),
        acceptedBy: any(named: 'acceptedBy'),
        acceptedOn: any(named: 'acceptedOn'),
        recordRevenue: any(named: 'recordRevenue'),
      ),
    ).thenThrow(const ProjectRuleViolation('already_accepted', 'done'));
    request(['finance']);
    expect((await route.onRequest(context, 'P1')).statusCode, 409);
  });
}
