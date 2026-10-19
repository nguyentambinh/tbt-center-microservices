/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:integration_service/src/bank_gateway.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as index_route;
import '../../routes/internal/payouts.dart' as payouts_route;

class _MockContext extends Mock implements RequestContext {}

class _MockGateway extends Mock implements BankGateway {}

PayoutItem _item(String ref) => PayoutItem(
  reference: ref,
  account: 'ACC',
  amount: 100,
  currency: 'VND',
);

void main() {
  late _MockContext context;
  late _MockGateway gateway;

  setUpAll(() => registerFallbackValue(_item('x')));

  setUp(() {
    context = _MockContext();
    gateway = _MockGateway();
    when(() => context.read<BankGateway>()).thenReturn(gateway);
    when(() => gateway.breaker).thenReturn(CircuitBreaker('bank'));
  });

  void post(Object body) => when(() => context.request).thenReturn(
    Request.post(
      Uri.parse('http://localhost/internal/payouts'),
      body: jsonEncode(body),
    ),
  );

  test('GET / hiện trạng thái mạch ngân hàng', () async {
    final response = index_route.onRequest(context);
    expect((await response.json() as Map)['circuits'], {'bank': 'closed'});
  });

  test('chi đủ mọi khoản thì trả danh sách mã giao dịch', () async {
    post({
      'items': [
        {'reference': 'R1', 'account': 'A', 'amount': 1, 'currency': 'VND'},
        {'reference': 'R2', 'account': 'B', 'amount': 2, 'currency': 'VND'},
      ],
    });
    when(() => gateway.transfer(any())).thenAnswer((i) async {
      final item = i.positionalArguments.first as PayoutItem;
      return 'BNK-${item.reference}';
    });
    final body = await (await payouts_route.onRequest(context)).json() as Map;
    expect((body['paid'] as List).length, 2);
  });

  test('ngân hàng lỗi giữa chừng thì dừng, trả 503 kèm khoản đã chi', () async {
    post({
      'items': [
        {'reference': 'R1', 'account': 'A', 'amount': 1, 'currency': 'VND'},
        {'reference': 'R2', 'account': 'B', 'amount': 2, 'currency': 'VND'},
        {'reference': 'R3', 'account': 'C', 'amount': 3, 'currency': 'VND'},
      ],
    });
    var calls = 0;
    when(() => gateway.transfer(any())).thenAnswer((_) async {
      calls++;
      if (calls == 2) throw const BankError(503, 'down');
      return 'BNK$calls';
    });
    final response = await payouts_route.onRequest(context);
    final body = await response.json() as Map;
    expect(response.statusCode, 503);
    expect((body['paid'] as List).length, 1);
    expect(body['failedReference'], 'R2');
    expect(calls, 2, reason: 'không gửi tiếp R3 sau khi lỗi');
  });
}
