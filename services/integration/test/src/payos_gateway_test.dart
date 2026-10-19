/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-19
 */

import 'dart:convert';
import 'dart:io';

import 'package:integration_service/src/bank_gateway.dart';
import 'package:integration_service/src/payos_gateway.dart';
import 'package:test/test.dart';

const _env = {
  'REGION': 'vn',
  'PAYOS_ENABLED': 'true',
  'PAYOS_CLIENT_ID': 'client',
  'PAYOS_API_KEY': 'api',
  'PAYOS_CHECKSUM_KEY': 'checksum',
  'PAYOS_TO_BIN': '971025',
  'PAYOS_TO_ACCOUNT': '0900000000',
};

void main() {
  group('cấu hình', () {
    test('đủ khóa, đúng khu vực thì bật, mặc định chi 2000 đồng', () {
      final config = PayOsConfig.fromEnv(_env)!;
      expect(config.payoutAmount, 2000);
      expect(config.toBin, '971025');
    });

    test('chưa bật, khác khu vực hoặc thiếu khóa thì dùng bank_mock', () {
      expect(PayOsConfig.fromEnv({..._env, 'PAYOS_ENABLED': 'false'}), isNull);
      expect(PayOsConfig.fromEnv({..._env, 'REGION': 'de'}), isNull);
      expect(PayOsConfig.fromEnv({..._env, 'PAYOS_API_KEY': ''}), isNull);
      expect(PayOsConfig.fromEnv({..._env, 'PAYOS_TO_ACCOUNT': ''}), isNull);
    });
  });

  test('chuỗi ký: khóa sắp xếp, giá trị mã hóa URL', () {
    final query = canonicalQuery({
      'toBin': '971025',
      'amount': 2000,
      'description': 'TBT luong 1',
      'referenceId': 'R-1',
      'toAccountNumber': '0900000000',
    });
    expect(
      query,
      'amount=2000&description=TBT%20luong%201&referenceId=R-1'
      '&toAccountNumber=0900000000&toBin=971025',
    );
    expect(payOsSignature({'a': 1}, 'k'), hasLength(64));
  });

  group('chi qua payOS', () {
    late HttpServer server;
    late PayOsGateway gateway;
    final requests = <(HttpHeaders, Map<String, dynamic>)>[];
    var reply = <String, dynamic>{};

    setUp(() async {
      requests.clear();
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0)
        ..listen((request) async {
          final body = jsonDecode(await utf8.decodeStream(request));
          requests.add((request.headers, body as Map<String, dynamic>));
          request.response
            ..headers.contentType = ContentType.json
            ..write(jsonEncode(reply));
          await request.response.close();
        });
      final config = PayOsConfig.fromEnv({
        ..._env,
        'PAYOS_BASE_URL': 'http://127.0.0.1:${server.port}',
      })!;
      gateway = PayOsGateway(config);
    });

    tearDown(() => server.close(force: true));

    test('chi đúng 2000 đồng tới tài khoản cấu hình, có chữ ký', () async {
      reply = {
        'code': '00',
        'desc': 'success',
        'data': {'id': 'PO-1', 'approvalState': 'PROCESSING'},
      };
      const item = PayoutItem(
        reference: 'run-2026-10-EMP01',
        account: 'TK-CU',
        amount: 14200000,
        currency: 'VND',
      );
      expect(await gateway.transfer(item), 'PO-1');

      final (headers, body) = requests.single;
      expect(body['amount'], 2000);
      expect(body['toBin'], '971025');
      expect(body['toAccountNumber'], '0900000000');
      expect(body['referenceId'], 'run-2026-10-EMP01');
      expect(headers.value('x-client-id'), 'client');
      expect(headers.value('x-api-key'), 'api');
      expect(headers.value('x-idempotency-key'), 'run-2026-10-EMP01');
      expect(headers.value('x-signature'), payOsSignature(body, 'checksum'));
    });

    test('payOS từ chối thì báo lỗi, không tính là kênh hỏng', () async {
      reply = {'code': '20', 'desc': 'Số dư không đủ'};
      const item = PayoutItem(
        reference: 'R2',
        account: 'x',
        amount: 1,
        currency: 'VND',
      );
      await expectLater(
        gateway.transfer(item),
        throwsA(isA<BankError>().having((e) => e.statusCode, 'status', 422)),
      );
      expect(gateway.breaker.state.name, 'closed');
    });
  });
}
