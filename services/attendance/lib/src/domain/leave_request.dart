/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Vai trò được xem dữ liệu của người khác và duyệt đơn nghỉ.
const managerRoles = {'hr', 'admin', 'executive'};

/// Một đơn xin nghỉ dài nhất 30 ngày.
const maxLeaveDays = 30;

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.fromDate,
    required this.toDate,
    required this.leaveType,
    required this.status,
    this.reason,
    this.approvedBy,
    this.createdAt,
  });

  final String id;
  final String employeeId;
  final DateTime fromDate;
  final DateTime toDate;
  final String leaveType;
  final String status;
  final String? reason;
  final String? approvedBy;
  final DateTime? createdAt;

  int get days => toDate.difference(fromDate).inDays + 1;

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'fromDate': _date(fromDate),
    'toDate': _date(toDate),
    'days': days,
    'leaveType': leaveType,
    'status': status,
    'reason': reason,
    'approvedBy': approvedBy,
    'createdAt': createdAt?.toIso8601String(),
  };
}

/// Lỗi nghiệp vụ, route đổi thành mã lỗi trả cho app.
class LeaveRuleViolation implements Exception {
  const LeaveRuleViolation(this.code, this.message);

  final String code;
  final String message;
}

/// Kiểm tra đơn trước khi ghi; trả lỗi đầu tiên gặp, `null` nếu hợp lệ.
LeaveRuleViolation? validateLeave({
  required DateTime? fromDate,
  required DateTime? toDate,
  required String? leaveType,
}) {
  if (fromDate == null || toDate == null) {
    return const LeaveRuleViolation(
      'invalid_dates',
      'fromDate, toDate required',
    );
  }
  if (toDate.isBefore(fromDate)) {
    return const LeaveRuleViolation('invalid_dates', 'toDate before fromDate');
  }
  if (toDate.difference(fromDate).inDays + 1 > maxLeaveDays) {
    return const LeaveRuleViolation('too_long', 'At most 30 days per request');
  }
  if (leaveType == null || leaveType.trim().isEmpty) {
    return const LeaveRuleViolation('invalid_type', 'leaveType required');
  }
  return null;
}

DateTime? parseDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

String _date(DateTime d) => d.toIso8601String().substring(0, 10);
