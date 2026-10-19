/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:payroll_service/src/payroll_repository.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/payslips/index.dart' as route;

class _MockContext extends Mock implements RequestContext {}

class _MockRepository extends Mock implements PayrollRepository {}

Claims _claims(List<String> roles, {String? employeeId = 'E1'}) => Claims({
  'employee_id': ?employeeId,
  'realm_access': {'roles': roles},
});

void main() {
  late _MockContext context;
  late _MockRepository repository;

  setUp(() {
    context = _MockContext();
    repository = _MockRepository();
    when(() => context.read<PayrollRepository>()).thenReturn(repository);
    when(() => repository.salary(any())).thenAnswer((_) async => null);
    when(() => repository.payslips(any())).thenAnswer(
      (_) async => [
        {'period': '2026-09', 'net': '11000000.00', 'currency': 'VND'},
      ],
    );
    when(() => repository.bonusesPenalties(any())).thenAnswer((_) async => []);
  });

  void request(String path, Claims claims) {
    when(
      () => context.request,
    ).thenReturn(Request('GET', Uri.parse('http://localhost$path')));
    when(() => context.read<Claims>()).thenReturn(claims);
  }

  test('nhân viên xem phiếu lương của mình', () async {
    request('/payslips', _claims(['employee']));
    final body = await (await route.onRequest(context)).json() as Map;
    expect(body['employeeId'], 'E1');
    final slip = (body['payslips'] as List).single as Map;
    expect(slip['period'], '2026-09');
  });

  test('nhân viên xem lương người khác thì 403', () async {
    request('/payslips?employee=E2', _claims(['employee']));
    expect((await route.onRequest(context)).statusCode, 403);
    verifyNever(() => repository.payslips(any()));
  });

  test('tài chính xem được lương người khác', () async {
    request('/payslips?employee=E2', _claims(['finance']));
    final body = await (await route.onRequest(context)).json() as Map;
    expect(body['employeeId'], 'E2');
  });

  test('tài khoản chưa gắn nhân viên thì 403 no_employee', () async {
    request('/payslips', _claims(['employee'], employeeId: null));
    final body = await (await route.onRequest(context)).json() as Map;
    expect(body['code'], 'no_employee');
  });
}
