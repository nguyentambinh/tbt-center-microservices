/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:convert';
import 'dart:io';

import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

class _FixedEureka extends EurekaClient {
  _FixedEureka(this.target) : super(Uri.parse('http://eureka/'), region: 'vn');

  final Uri? target;
  var picks = 0;

  @override
  Future<Uri?> pick(String app) async {
    picks++;
    return target;
  }
}

void main() {
  group('RabbitMQ', () {
    test('khóa định tuyến theo khu vực, service, loại sự kiện', () {
      expect(
        routingKeyFor('vn', 'attendance', 'LeaveApproved'),
        'vn.attendance.LeaveApproved',
      );
      // Dấu chấm, khoảng trắng trong tên làm hỏng mẫu khớp nên bị thay
      expect(
        routingKeyFor('de', 'project contract', 'a.b'),
        'de.project_contract.a_b',
      );
      expect(routingKeyFor('', 'hr', 'X'), 'unknown.hr.X');
    });

    test('không cấu hình RABBITMQ_HOST thì không bật', () {
      expect(RabbitEventBus.fromEnvironment(const {}), isNull);
      expect(
        RabbitEventBus.fromEnvironment(const {'RABBITMQ_HOST': 'rabbitmq'}),
        isNotNull,
      );
    });
  });

  group('Eureka', () {
    test('chỉ lấy bản đang UP, đọc đúng cổng và khu vực', () {
      final items = parseInstances({
        'application': {
          'name': 'HR',
          'instance': [
            {
              'instanceId': 'a:hr:8080',
              'ipAddr': '172.20.0.5',
              'status': 'UP',
              'port': {r'$': 8080, '@enabled': 'true'},
              'metadata': {'region': 'vn'},
            },
            {
              'instanceId': 'b:hr:8080',
              'ipAddr': '172.20.0.6',
              'status': 'DOWN',
              'port': {r'$': 8080},
              'metadata': {'region': 'vn'},
            },
          ],
        },
      });
      expect(items.single.baseUrl, Uri.parse('http://172.20.0.5:8080/'));
      expect(items.single.region, 'vn');
    });

    test(
      'Eureka trả một instance là object chứ không phải list vẫn đọc được',
      () {
        final items = parseInstances({
          'application': {
            'instance': {
              'instanceId': 'a',
              'ipAddr': '10.0.0.1',
              'status': 'UP',
              'port': {r'$': '9000'},
            },
          },
        });
        expect(items.single.port, 9000);
      },
    );

    test('InternalClient gọi bản lấy từ Eureka; bản đó chết thì gọi địa chỉ cố định', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((r) {
        r.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'ok': true}))
          ..close();
      });
      // Cổng 1 không có gì nghe: giống bản vừa tắt mà Eureka chưa gỡ
      final eureka = _FixedEureka(Uri.parse('http://127.0.0.1:1/'));
      final client = InternalClient(
        'hr',
        Uri.parse('http://127.0.0.1:${server.port}/'),
        token: 't',
        discovery: eureka,
      );
      expect(await client.get('/internal/x'), {'ok': true});
      expect(eureka.picks, 1);
      await server.close(force: true);
    });
  });

  group('correlation id', () {
    test(
      'InternalClient tự gửi correlation id của request đang xử lý',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        String? seen;
        server.listen((r) {
          seen = r.headers.value('x-correlation-id');
          r.response
            ..headers.contentType = ContentType.json
            ..write('{}')
            ..close();
        });
        final client = InternalClient(
          'hr',
          Uri.parse('http://127.0.0.1:${server.port}/'),
          token: 't',
          discovery: _FixedEureka(null),
        );
        await withCorrelationId('abc-123', () => client.get('/internal/x'));
        expect(seen, 'abc-123');
        await server.close(force: true);
      },
    );

    test('id tự sinh có dạng tbt- và không trùng nhau', () {
      final a = newCorrelationId();
      expect(a, matches(RegExp(r'^tbt-[0-9a-f]{16}$')));
      expect(newCorrelationId(), isNot(a));
    });
  });

  group('Elasticsearch', () {
    test('mỗi ngày một index theo giờ UTC', () {
      expect(
        requestIndexFor(DateTime.utc(2026, 10, 7, 23)),
        'tbt-requests-2026.10.07',
      );
    });

    test('lệnh _bulk: mỗi tài liệu một dòng lệnh và một dòng dữ liệu', () {
      final body = bulkBody([
        {
          '@timestamp': '2026-10-17T03:00:00.000Z',
          'service': 'hr',
          'status': 200,
        },
      ]);
      final lines = const LineSplitter().convert(body);
      expect(lines, hasLength(2));
      expect(jsonDecode(lines[0]), {
        'create': {'_index': 'tbt-requests-2026.10.17'},
      });
      expect((jsonDecode(lines[1]) as Map)['service'], 'hr');
    });
  });
}
