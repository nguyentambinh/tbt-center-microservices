/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:report_service/src/projector.dart';
import 'package:test/test.dart';

AuditEvent _event(String type, Map<String, dynamic> payload) => AuditEvent(
  id: 1,
  region: 'de',
  eventType: type,
  payload: payload,
  occurredAt: DateTime.utc(2026, 10, 15, 7, 30, 5),
);

void main() {
  test('chốt lương xong thành một dòng chi phí lương quy USD', () {
    final p = projectEvent(
      _event('PayrollRunCompleted', {
        'runId': 'R1',
        'region': 'de',
        'period': '2026-10',
        'employees': 40,
        'currency': 'EUR',
        'totalNet': '100000.00',
        'totalNetUsd': '116279.07',
      }),
    )!;
    expect(p.table, 'payroll_cost');
    expect(p.row['total_net_usd'], '116279.07');
    expect(p.row['updated_at'], '2026-10-15 07:30:05');
  });

  test('chốt sổ tài chính thành một dòng theo khu vực và kỳ', () {
    final p = projectEvent(
      _event('FinancePeriodClosed', {
        'period': '2025-04',
        'currency': 'EUR',
        'revenue': '50000.00',
        'revenueUsd': '58000.00',
        'cost': '20000.00',
        'costUsd': '23200.00',
      }),
    )!;
    expect(p.table, 'finance_summary');
    expect(p.row['region'], 'de');
    expect(p.row['cost_usd'], '23200.00');
  });

  test('ra ca thành giờ làm; tăng ca bị từ chối thì về 0 trên cùng dòng', () {
    final shift = projectEvent(
      _event('ClockedOut', {
        'employeeId': 'E1',
        'workDate': '2026-10-15',
        'totalHours': 8.75,
        'overtimeHours': 0.75,
      }),
    )!;
    expect(shift.table, 'work_hours');
    expect(shift.row['source_id'], 'shift:E1:2026-10-15');
    expect(shift.row['hours'], 8.75);

    final approved = projectEvent(
      _event('OvertimeApproved', {'id': 'O1', 'employeeId': 'E1', 'hours': 2}),
    )!;
    final rejected = projectEvent(
      _event('OvertimeRejected', {'id': 'O1', 'employeeId': 'E1', 'hours': 2}),
    )!;
    expect(approved.row['overtime_hours'], 2);
    expect(rejected.row['source_id'], approved.row['source_id']);
    expect(rejected.row['overtime_hours'], 0);
  });

  test('các sự kiện của một đơn nghỉ cùng ghi vào một dòng theo leave_id', () {
    final requested = projectEvent(
      _event('LeaveRequested', {'id': 'L1', 'status': 'pending', 'days': 3}),
    )!;
    final approved = projectEvent(
      _event('LeaveApproved', {'id': 'L1', 'status': 'approved', 'days': 3}),
    )!;
    expect(requested.table, approved.table);
    expect(approved.row['leave_id'], 'L1');
    expect(approved.row['status'], 'approved');
    expect(approved.row['region'], 'de');
  });

  test('sự kiện ứng viên không mang email, số điện thoại', () {
    final p = projectEvent(
      _event('CandidateStatusChanged', {
        'candidateId': 'C1',
        'status': 'interview',
        'countryCode': 'DE',
      }),
    )!;
    expect(p.table, 'candidates');
    expect(p.row.keys, isNot(contains('email')));
  });

  test('sự kiện báo cáo không cần thì bỏ qua', () {
    expect(projectEvent(_event('PayrollRunFailed', {'runId': 'R1'})), isNull);
  });
}
