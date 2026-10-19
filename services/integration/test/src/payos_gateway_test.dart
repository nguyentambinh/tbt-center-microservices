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

    test('chưa bật hoặc thiếu khóa thì dùng bank_mock', () {
      expect(PayOsConfig.fromEnv({..._env, 'PAYOS_ENABLED': 'false'}), isNull);
      expect(PayOsConfig.fromEnv(const {'REGION': 'de'}), isNull);
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
    final paths = <String>[];
    var reply = <String, dynamic>{};
    var listReply = <String, dynamic>{};
    var limited = 0;

    setUp(() async {
      requests.clear();
      paths.clear();
      limited = 0;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0)
        ..listen((request) async {
          final text = await utf8.decodeStream(request);
          paths.add('${request.method} ${request.uri}');
          if (text.isNotEmpty) {
            requests.add((
              request.headers,
              jsonDecode(text) as Map<String, dynamic>,
            ));
          }
          if (limited > 0) {
            limited--;
            request.response
              ..statusCode = 429
              ..write('Too many requests');
          } else {
            request.response
              ..headers.contentType = ContentType.json
              ..write(jsonEncode(request.method == 'GET' ? listReply : reply));
          }
          await request.response.close();
        });
      final config = PayOsConfig.fromEnv({
        ..._env,
        'PAYOS_BASE_URL': 'http://127.0.0.1:${server.port}',
      })!;
      gateway = PayOsGateway(
        config,
        rateLimitDelays: const [Duration.zero, Duration.zero],
      );
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

    test('mã đã có lệnh (606) thì trả lệnh cũ, không chi lần hai', () async {
      reply = {'code': '606', 'desc': 'Idempotency key đã tồn tại'};
      listReply = {
        'code': '00',
        'data': {
          'payouts': [
            {'id': 'PO-OLD', 'referenceId': 'R1'},
          ],
        },
      };
      const item = PayoutItem(
        reference: 'R1',
        account: 'x',
        amount: 1,
        currency: 'VND',
      );
      expect(await gateway.transfer(item), 'PO-OLD');
      expect(paths.last, 'GET /v1/payouts?referenceId=R1&limit=5');
      expect(requests, hasLength(1));
    });

    test('payOS báo gọi quá nhiều thì chờ rồi gửi lại', () async {
      limited = 2;
      reply = {
        'code': '00',
        'data': {'id': 'PO-2'},
      };
      const item = PayoutItem(
        reference: 'R3',
        account: 'x',
        amount: 1,
        currency: 'VND',
      );
      expect(await gateway.transfer(item), 'PO-2');
      expect(paths, hasLength(3));
    });

    test('payOS trả chữ thường thì báo lỗi rõ ràng', () async {
      limited = 5;
      const item = PayoutItem(
        reference: 'R4',
        account: 'x',
        amount: 1,
        currency: 'VND',
      );
      await expectLater(
        gateway.transfer(item),
        throwsA(
          isA<BankError>().having((e) => e.statusCode, 'status', 429),
        ),
      );
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
