/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/attendance.dart';
import '../entities/work_calendar.dart';

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

  /// Lịch làm việc từng ngày trong khoảng (tối đa 3 tháng)
  Future<List<CalendarDay>> calendar({required DateTime from, required DateTime to});

  /// Tần suất chấm công [months] tháng gần nhất; quản lý xem cả khu vực
  Future<ClockStats> stats({int months = 3});

  Future<List<LeaveFile>> leaveFiles(String leaveId);

  /// Tải minh chứng lên kho rồi báo server; server cho AI tóm tắt lại cả đơn
  Future<List<LeaveFile>> uploadLeaveFile(String leaveId, {required String fileName, required List<int> bytes, required String language});
}
