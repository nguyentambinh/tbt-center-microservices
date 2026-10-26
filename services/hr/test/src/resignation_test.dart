/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:hr_service/src/data/resignation_repository.dart';
import 'package:test/test.dart';

void main() {
  group('checkNotice', () {
    final today = DateTime(2026, 10, 25, 15);

    test('đủ 30 ngày thì qua', () {
      expect(() => checkNotice(DateTime(2026, 11, 24), today), returnsNormally);
    });

    test('dưới 30 ngày thì báo notice_too_short', () {
      expect(
        () => checkNotice(DateTime(2026, 11, 23), today),
        throwsA(
          isA<ResignationViolation>().having(
            (e) => e.code,
            'code',
            'notice_too_short',
          ),
        ),
      );
    });
  });

  group('nextResignationStatus', () {
    String next(
      String status,
      String action, {
      bool hr = true,
      bool passed = false,
    }) => nextResignationStatus(
      status,
      action,
      hr: hr,
      lastDayPassed: passed,
    );

    test('HR duyệt, từ chối đơn chờ', () {
      expect(next('pending', 'approve'), 'approved');
      expect(next('pending', 'reject'), 'rejected');
    });

    test('nhân viên chỉ rút được đơn chờ của mình', () {
      expect(next('pending', 'withdraw', hr: false), 'withdrawn');
      expect(
        () => next('pending', 'approve', hr: false),
        throwsA(isA<ResignationViolation>()),
      );
      expect(
        () => next('approved', 'withdraw', hr: false),
        throwsA(isA<ResignationViolation>()),
      );
    });

    test('hoàn tất chỉ sau ngày làm cuối', () {
      expect(
        () => next('approved', 'complete'),
        throwsA(
          isA<ResignationViolation>().having(
            (e) => e.code,
            'code',
            'before_last_day',
          ),
        ),
      );
      expect(next('approved', 'complete', passed: true), 'completed');
    });

    test('đơn đã đóng không đổi được', () {
      for (final status in ['rejected', 'withdrawn', 'completed']) {
        expect(
          () => next(status, 'approve', passed: true),
          throwsA(isA<ResignationViolation>()),
        );
      }
    });
  });
}
