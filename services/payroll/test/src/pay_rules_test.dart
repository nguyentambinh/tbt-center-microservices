/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:payroll_service/src/raise_requests.dart';
import 'package:payroll_service/src/saga/payroll_saga.dart';
import 'package:test/test.dart';

void main() {
  test('lương tháng chỉ chốt từ ngày 10 tháng sau', () {
    expect(canRunPeriod('2026-10', DateTime(2026, 11, 9, 23)), isFalse);
    expect(canRunPeriod('2026-10', DateTime(2026, 11, 10)), isTrue);
    expect(canRunPeriod('2026-11', DateTime(2026, 10, 25)), isFalse);
    expect(canRunPeriod('2026-12', DateTime(2027, 1, 10)), isTrue);
    expect(earliestRunDate('2026-12'), DateTime(2027, 1, 10));
  });

  test('phiếu lương chi tiết: tăng ca 150%, thưởng, bảo hiểm và thuế', () {
    final de = breakdown(
      baseSalary: 4400,
      overtimeHours: 8,
      bonus: 200,
      countryCode: 'DE',
    );
    expect(de.overtime, 300);
    expect(de.gross, 4900);
    expect(de.insurance, 980);
    expect(de.tax, 882);
    expect(de.net, de.gross - de.insurance - de.tax);
  });

  group('đề xuất tăng lương', () {
    test('nhân viên gửi → HR chuyển lên → bên duyệt đồng ý', () {
      final s1 = nextRaiseStatus('awaiting_hr', RaiseSide.hr, 'forward');
      expect(s1, 'awaiting_approver');
      expect(nextRaiseStatus(s1, RaiseSide.approver, 'approve'), 'approved');
    });

    test('văn phòng quản lý duyệt, từ chối thẳng đơn chờ HR', () {
      expect(
        nextRaiseStatus('awaiting_hr', RaiseSide.approver, 'approve'),
        'approved',
      );
      expect(
        nextRaiseStatus('awaiting_hr', RaiseSide.approver, 'reject'),
        'rejected',
      );
    });

    test('bên duyệt trả lại HR, HR trả lại nhân viên sửa', () {
      expect(
        nextRaiseStatus('awaiting_approver', RaiseSide.approver, 'return'),
        'awaiting_hr',
      );
      expect(
        nextRaiseStatus('awaiting_hr', RaiseSide.hr, 'return'),
        'awaiting_employee',
      );
      expect(
        nextRaiseStatus('awaiting_employee', RaiseSide.employee, 'edit'),
        'awaiting_hr',
      );
    });

    test('HR không tự duyệt, đề xuất đã chốt thì không đổi', () {
      expect(
        () => nextRaiseStatus('awaiting_hr', RaiseSide.hr, 'approve'),
        throwsA(isA<RaiseRuleViolation>()),
      );
      expect(
        () => nextRaiseStatus('approved', RaiseSide.employee, 'withdraw'),
        throwsA(isA<RaiseRuleViolation>()),
      );
    });

    test('sửa qua lại chỉ giữ hoặc tăng mức đề xuất', () {
      expect(() => checkAmount(21000000, 20000000), returnsNormally);
      expect(() => checkAmount(20000000, 20000000), returnsNormally);
      expect(() => checkAmount(null, 20000000), returnsNormally);
      expect(
        () => checkAmount(19000000, 20000000),
        throwsA(
          isA<RaiseRuleViolation>().having(
            (e) => e.code,
            'code',
            'amount_lowered',
          ),
        ),
      );
    });
  });

  test('phạt trong kỳ làm giảm lương gộp', () {
    final vn = breakdown(
      baseSalary: 17600000,
      overtimeHours: 0,
      bonus: -500000,
      countryCode: 'VN',
    );
    expect(vn.gross, 17100000);
    expect(vn.tax, 0);
    expect(vn.net, 17100000 - 1795500);
  });

  test('đề xuất của HR đi thẳng Ban lãnh đạo, HR không xử lý được', () {
    expect(
      () => nextRaiseStatus(
        'awaiting_approver',
        RaiseSide.hr,
        'forward',
        skipHr: true,
      ),
      throwsA(isA<RaiseRuleViolation>()),
    );
    expect(
      nextRaiseStatus(
        'awaiting_approver',
        RaiseSide.approver,
        'return',
        skipHr: true,
      ),
      'awaiting_employee',
    );
    expect(
      nextRaiseStatus(
        'awaiting_employee',
        RaiseSide.employee,
        'edit',
        skipHr: true,
      ),
      'awaiting_approver',
    );
    expect(raiseApproverRoles, {'executive'});
  });
}
