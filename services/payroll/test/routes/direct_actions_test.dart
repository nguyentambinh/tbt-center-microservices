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
import 'package:payroll_service/src/payroll_repository.dart';
import 'package:payroll_service/src/saga/payroll_saga.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/bonuses-penalties/index.dart' as bonus_route;
import '../../routes/salaries/[employeeId].dart' as salary_route;

class _MockContext extends Mock implements RequestContext {}

class _MockRepository extends Mock implements PayrollRepository {}

Claims _claims(List<String> roles) => Claims({
  'employee_id': 'EX1',
  'realm_access': {'roles': roles},
});

void main() {
  late _MockContext context;
  late _MockRepository repository;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue((rate: '1', date: DateTime(2026)));
  });

  setUp(() {
    context = _MockContext();
    repository = _MockRepository();
    when(() => context.read<PayrollRepository>()).thenReturn(repository);
    when(() => context.read<RateSource>()).thenReturn(
      (currency, date) async => (rate: '25000', date: DateTime(2026, 10, 26)),
    );
  });

  void request(String method, String path, Object body, List<String> roles) {
    when(() => context.request).thenReturn(
      Request(method, Uri.parse('http://localhost$path'), body: jsonEncode(body)),
    );
    when(() => context.read<Claims>()).thenReturn(_claims(roles));
  }

  test('đổi lương: chỉ văn phòng quản lý, không tự đổi', () async {
    request('PUT', '/salaries/E2', {'baseSalary': 20000000}, ['hr']);
    expect((await salary_route.onRequest(context, 'E2')).statusCode, 403);

    request('PUT', '/salaries/EX1', {'baseSalary': 20000000}, ['executive']);
    final self = await salary_route.onRequest(context, 'EX1');
    expect((await self.json() as Map)['code'], 'self_approval');

    when(
      () => repository.setBaseSalary(
        'E2',
        amount: 20000000,
        by: 'EX1',
        reason: 'Điều chỉnh theo thị trường',
      ),
    ).thenAnswer(
      (_) async => {'employeeId': 'E2', 'baseSalary': '20000000.00'},
    );
    request('PUT', '/salaries/E2', {'baseSalary': 20000000, 'reason': 'Điều chỉnh theo thị trường'}, ['executive']);
    expect((await salary_route.onRequest(context, 'E2')).statusCode, 200);
  });

  test('thưởng phạt ghi thẳng, số tiền phải dương', () async {
    request('POST', '/bonuses-penalties', {'employeeId': 'E2', 'kind': 'bonus', 'amount': -5}, ['executive']);
    expect((await bonus_route.onRequest(context)).statusCode, 400);

    when(() => repository.currencyOf('E2')).thenAnswer((_) async => 'VND');
    when(
      () => repository.addBonusPenalty(
        employeeId: 'E2',
        kind: 'penalty',
        amount: 500000,
        currency: 'VND',
        occurredOn: any(named: 'occurredOn'),
        rate: any(named: 'rate'),
        by: 'EX1',
        reason: 'Đi trễ nhiều lần',
      ),
    ).thenAnswer((_) async => {'id': 1, 'kind': 'penalty'});
    request('POST', '/bonuses-penalties', {'employeeId': 'E2', 'kind': 'penalty', 'amount': 500000, 'reason': 'Đi trễ nhiều lần'}, ['executive']);
    final response = await bonus_route.onRequest(context);
    expect(response.statusCode, 201);
    expect((await response.json() as Map)['kind'], 'penalty');
  });
}
