/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

void main() {
  group('kỳ báo cáo', () {
    final now = DateTime(2026, 10, 26);
    String? refusal(String period, [Set<String> done = const {}]) {
      try {
        checkReportPeriod(period, now: now, acknowledged: done);
        return null;
      } on ReportRuleViolation catch (e) {
        return e.code;
      }
    }

    test('tháng hiện tại, tháng cũ chưa duyệt thì gửi được', () {
      expect(refusal('2026-10'), isNull);
      expect(refusal('2026-08'), isNull);
    });

    test('tháng tương lai, sai dạng, tháng đã duyệt thì không', () {
      expect(refusal('2026-11'), 'future_period');
      expect(refusal('2026-13'), 'invalid_period');
      expect(refusal('2026-09', {'2026-09'}), 'period_acknowledged');
    });
  });

  test('bản trước còn chờ xác nhận thì chưa gửi bản mới', () {
    expect(
      () => checkCanSubmit('submitted'),
      throwsA(
        isA<ReportRuleViolation>().having(
          (e) => e.code,
          'code',
          'awaiting_ack',
        ),
      ),
    );
  });

  test('bản trước đã xác nhận hoặc bị trả lại thì gửi được', () {
    expect(() => checkCanSubmit(null), returnsNormally);
    expect(() => checkCanSubmit('acknowledged'), returnsNormally);
    expect(() => checkCanSubmit('returned'), returnsNormally);
  });

  test(
    'cấp trên xác nhận hoặc trả lại bản đang chờ, không đổi bản đã chốt',
    () {
      expect(nextReportStatus('submitted', 'acknowledge'), 'acknowledged');
      expect(nextReportStatus('submitted', 'return'), 'returned');
      expect(
        () => nextReportStatus('acknowledged', 'return'),
        throwsA(isA<ReportRuleViolation>()),
      );
    },
  );
}
