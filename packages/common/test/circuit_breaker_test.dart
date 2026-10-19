/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

void main() {
  late DateTime now;
  late CircuitBreaker breaker;
  var calls = 0;

  Future<String> failing() async {
    calls++;
    throw StateError('bank down');
  }

  Future<String> working() async {
    calls++;
    return 'ok';
  }

  setUp(() {
    now = DateTime(2026, 10, 15, 7);
    calls = 0;
    breaker = CircuitBreaker(
      'bank',
      openFor: const Duration(seconds: 30),
      clock: () => now,
    );
  });

  Future<void> failTimes(int n) async {
    for (var i = 0; i < n; i++) {
      await expectLater(breaker.call(failing), throwsStateError);
    }
  }

  test('lỗi 3 lần liên tiếp thì ngắt, lời gọi sau bị từ chối ngay', () async {
    await failTimes(3);
    expect(breaker.state, CircuitState.open);
    await expectLater(
      breaker.call(working),
      throwsA(isA<CircuitOpenException>()),
    );
    expect(calls, 3, reason: 'không gọi dịch vụ khi mạch đang mở');
  });

  test('hết thời gian ngắt thì thử lại một lần, thành công thì đóng', () async {
    await failTimes(3);
    now = now.add(const Duration(seconds: 31));
    expect(breaker.state, CircuitState.halfOpen);
    expect(await breaker.call(working), 'ok');
    expect(breaker.state, CircuitState.closed);
  });

  test('lần thử lại vẫn lỗi thì ngắt tiếp', () async {
    await failTimes(3);
    now = now.add(const Duration(seconds: 31));
    await failTimes(1);
    expect(breaker.state, CircuitState.open);
  });

  test('thành công xen giữa thì đếm lại từ đầu', () async {
    await failTimes(2);
    await breaker.call(working);
    await failTimes(2);
    expect(breaker.state, CircuitState.closed);
  });

  test('lỗi không tính là dịch vụ hỏng thì không làm ngắt mạch', () async {
    for (var i = 0; i < 5; i++) {
      await expectLater(
        breaker.call(failing, isFailure: (_) => false),
        throwsStateError,
      );
    }
    expect(breaker.state, CircuitState.closed);
  });
}
