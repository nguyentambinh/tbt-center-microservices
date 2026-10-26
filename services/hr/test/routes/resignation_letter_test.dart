/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/resignation_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/resignations/index.dart' as route;

class _MockContext extends Mock implements RequestContext {}

class _MockRepository extends Mock implements ResignationRepository {}

void main() {
  late _MockContext context;
  late _MockRepository repository;

  setUp(() {
    context = _MockContext();
    repository = _MockRepository();
    when(() => context.read<ResignationRepository>()).thenReturn(repository);
    when(() => context.read<ObjectStore?>()).thenReturn(null);
  });

  void request(
    String method, {
    Object? body,
    List<String> roles = const ['employee'],
  }) {
    when(() => context.request).thenReturn(
      Request(
        method,
        Uri.parse('http://localhost/resignations'),
        body: body == null ? null : jsonEncode(body),
      ),
    );
    when(() => context.read<Claims>()).thenReturn(
      Claims({
        'employee_id': 'E1',
        'realm_access': {'roles': roles},
      }),
    );
  }

  test('gửi đơn thôi việc bắt buộc kèm bản đơn của chính mình', () async {
    request('POST', body: {'lastDay': '2026-12-31', 'reason': 'Chuyển nhà'});
    final missing = await route.onRequest(context);
    expect((await missing.json() as Map)['code'], 'letter_required');

    request(
      'POST',
      body: {
        'lastDay': '2026-12-31',
        'reason': 'Chuyển nhà',
        'letterKey': 'resignations/E2/abc.pdf',
        'letterName': 'don.pdf',
      },
    );
    final foreign = await route.onRequest(context);
    expect((await foreign.json() as Map)['code'], 'letter_required');
  });

  test('người gửi không thấy phần AI phân tích đơn của mình', () async {
    when(() => repository.list(employeeId: 'E1')).thenAnswer(
      (_) async => [
        {
          'id': 1,
          'employeeId': 'E1',
          'aiAnalysis': {'summary': 'x'},
          'aiSource': 'claude',
        },
      ],
    );
    request('GET');
    final body = await (await route.onRequest(context)).json() as Map;
    final item = (body['items'] as List).single as Map;
    expect(item['aiAnalysis'], isNull);
  });
}
