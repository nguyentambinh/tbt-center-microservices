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
