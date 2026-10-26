/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

class TimesheetDay {
  const TimesheetDay({
    required this.date,
    this.checkIn,
    this.checkOut,
    this.workHours = 0,
    this.overtimeHours = 0,
    this.totalHours = 0,
  });

  final DateTime date;
  final String? checkIn;
  final String? checkOut;
  final double workHours;
  final double overtimeHours;
  final double totalHours;
}

class Timesheet {
  const Timesheet({required this.employeeId, required this.days, required this.totalHours});

  final String employeeId;
  final List<TimesheetDay> days;
  final double totalHours;
}

enum LeaveStatus { pending, approved, rejected }

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.leaveType,
    required this.status,
    this.reason,
    this.approvedBy,
    this.aiSummary,
    this.aiSource,
    this.fileCount = 0,
  });

  final String id;
  final String employeeId;
  final DateTime fromDate;
  final DateTime toDate;
  final int days;
  final String leaveType;
  final LeaveStatus status;
  final String? reason;
  final String? approvedBy;

  /// AI tóm tắt minh chứng cho HR (summary, keyPoints, matchesRequest, concerns)
  final Map<String, dynamic>? aiSummary;
  final String? aiSource;
  final int fileCount;
}
