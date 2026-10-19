/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:finance_service/src/data/finance_repository.dart';
import 'package:finance_service/src/domain/finance_rules.dart';
import 'package:finance_service/src/rate_source.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/material-imports/index.dart' as imports;
import '../../routes/periods/[period]/close.dart' as close;
import '../../routes/summary.dart' as summary;
import '../../routes/suppliers/[id]/payments.dart' as payments;

class _MockContext extends Mock implements RequestContext {}

class _MockRepository extends Mock implements FinanceRepository {}

class _MockRates extends Mock implements RateSource {}

Claims _claims(List<String> roles) => Claims({
  'preferred_username': 'finance.vn',
  'realm_access': {'roles': roles},
});

void main() {
  late _MockContext context;
  late _MockRepository repository;
  late _MockRates rates;
  final rate = (rate: '25000', date: DateTime(2025, 4));

  setUpAll(() => registerFallbackValue(DateTime(2025)));

  setUp(() {
    context = _MockContext();
    repository = _MockRepository();
    rates = _MockRates();
    when(() => context.read<FinanceRepository>()).thenReturn(repository);
    when(() => context.read<RateSource>()).thenReturn(rates);
    when(() => rates.currency).thenReturn('VND');
    when(() => rates.rateOn(any())).thenAnswer((_) async => rate);
  });

  void request(String method, String path, List<String> roles, [Object? b]) {
    when(() => context.request).thenReturn(
      Request(
        method,
        Uri.parse('http://localhost$path'),
        body: b == null ? null : jsonEncode(b),
      ),
    );
    when(() => context.read<Claims>()).thenReturn(_claims(roles));
  }

  group('quy tắc', () {
    test('số tiền phải dương, tối đa 2 số lẻ', () {
      expect(parseAmount('5200000'), '5200000');
      expect(parseAmount('12.5'), '12.5');
      expect(parseAmount(1500), '1500');
      expect(parseAmount('0'), isNull);
      expect(parseAmount('-3'), isNull);
      expect(parseAmount('1.234'), isNull);
      expect(parseAmount('abc'), isNull);
    });

    test('kỳ dạng YYYY-MM', () {
      expect(isPeriod('2025-04'), isTrue);
      expect(isPeriod('2025-4'), isFalse);
      expect(periodOf(DateTime(2025, 4, 30)), '2025-04');
    });
  });

  test('xem thu chi theo tháng kèm tiền tệ khu vực', () async {
    when(() => repository.monthly(2025)).thenAnswer(
      (_) async => [
        {'period': '2025-04', 'revenue': '100', 'cost': '40'},
      ],
    );
    request('GET', '/summary?year=2025', ['finance']);

    final body = await (await summary.onRequest(context)).json() as Map;
    expect(body['currency'], 'VND');
    expect(body['months'], hasLength(1));
  });

  test('ghi chứng từ mua dùng tỷ giá của ngày nhập', () async {
    when(
      () => repository.recordPurchase(
        supplierId: 'NCC01',
        materialName: 'Thép hộp',
        importedOn: DateTime(2025, 4, 20),
        amount: '5200000',
        currency: 'VND',
        rate: rate,
      ),
    ).thenAnswer((_) async => {'id': 'N1', 'amountUsd': '208.00'});
    request('POST', '/material-imports', ['finance'], {
      'supplierId': 'NCC01',
      'materialName': 'Thép hộp',
      'importedOn': '2025-04-20',
      'amount': '5200000',
    });

    final response = await imports.onRequest(context);
    expect(response.statusCode, 201);
    verify(() => rates.rateOn(DateTime(2025, 4, 20))).called(1);
  });

  test('chứng từ thiếu số tiền thì 400', () async {
    request('POST', '/material-imports', ['finance'], {
      'supplierId': 'NCC01',
      'materialName': 'Thép',
      'importedOn': '2025-04-20',
    });
    final body = await (await imports.onRequest(context)).json() as Map;
    expect(body['code'], 'invalid_amount');
  });

  test('lãnh đạo xem được nhưng không ghi chứng từ', () async {
    request('POST', '/material-imports', ['executive'], {});
    expect((await imports.onRequest(context)).statusCode, 403);
  });

  test('trả quá số nợ thì 409 overpaid', () async {
    when(
      () => repository.recordPayment(
        supplierId: 'NCC01',
        paidOn: any(named: 'paidOn'),
        amount: any(named: 'amount'),
        currency: any(named: 'currency'),
        rate: rate,
        recordedBy: 'finance.vn',
        note: any(named: 'note'),
      ),
    ).thenThrow(const FinanceRuleViolation('overpaid', 'too much'));
    request('POST', '/suppliers/NCC01/payments', ['finance'], {
      'amount': '999999999',
      'paidOn': '2025-04-25',
    });

    final response = await payments.onRequest(context, 'NCC01');
    expect(response.statusCode, 409);
  });

  test('chốt sổ tháng đã chốt thì 409', () async {
    when(
      () => repository.closePeriod(
        '2025-04',
        currency: 'VND',
        closedBy: 'finance.vn',
      ),
    ).thenThrow(const FinanceRuleViolation('period_closed', 'closed'));
    request('POST', '/periods/2025-04/close', ['finance']);

    final response = await close.onRequest(context, '2025-04');
    expect(response.statusCode, 409);
  });

  test('không chốt sổ tháng chưa kết thúc', () async {
    final now = periodOf(DateTime.now());
    request('POST', '/periods/$now/close', ['finance']);
    final body = await (await close.onRequest(context, now)).json() as Map;
    expect(body['code'], 'period_not_ended');
    verifyNever(
      () => repository.closePeriod(
        any(),
        currency: any(named: 'currency'),
        closedBy: any(named: 'closedBy'),
      ),
    );
  });
}
