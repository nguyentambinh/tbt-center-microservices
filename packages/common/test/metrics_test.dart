/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

class _MockContext extends Mock implements RequestContext {}

void main() {
  setUp(ServiceMetrics.instance.reset);

  Future<Response> call(String path, Handler inner) {
    final context = _MockContext();
    when(() => context.request)
        .thenReturn(Request('GET', Uri.parse('http://localhost$path')));
    return Future.value(metrics('hr')(inner)(context));
  }

  test('đếm request theo đoạn đầu đường dẫn và mã trả về', () async {
    Response ok(RequestContext _) => Response();
    Response denied(RequestContext _) => Response(statusCode: 403);
    await call('/employees/AN001', ok);
    await call('/employees/BIN002', ok);
    await call('/employees', denied);

    final text = await (await call('/metrics', ok)).body();
    expect(
      text,
      contains(
        'tbt_http_requests_total{service="hr",method="GET",'
        'route="/employees",status="200"} 2',
      ),
    );
    expect(text, contains('status="403"} 1'));
    expect(text, contains('tbt_http_request_seconds_count{service="hr"} 3'));
  });

  test('báo trạng thái Circuit Breaker: ngắt là 2', () async {
    final breaker = CircuitBreaker('bank', failureThreshold: 1);
    ServiceMetrics.instance.watch(breaker);
    await expectLater(
      breaker.call<void>(() => throw Exception('bank down')),
      throwsException,
    );

    final text = await (await call('/metrics', (_) => Response())).body();
    expect(text, contains('tbt_circuit_state{service="hr",name="bank"} 2'));
  });
}
