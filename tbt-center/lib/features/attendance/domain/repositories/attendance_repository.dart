/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/attendance.dart';

abstract interface class AttendanceRepository {
  Future<Timesheet> timesheet({required DateTime from, required DateTime to});

  /// Đơn của chính mình, hoặc (với quản lý, [pendingOnly]) mọi đơn đang chờ duyệt.
  Future<List<LeaveRequest>> leaveRequests({bool pendingOnly = false});

  Future<LeaveRequest> requestLeave({
    required DateTime fromDate,
    required DateTime toDate,
    required String leaveType,
    String? reason,
  });

  Future<LeaveRequest> decide(String id, {required bool approve});
}
