/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'attendance.dart';

/// Ca hôm nay và tình trạng chấm công, theo giờ của khu vực (không theo máy).
class ClockToday {
  const ClockToday({
    required this.workDate,
    required this.hasShift,
    this.shiftNote,
    this.coefficient,
    this.isHoliday = false,
    this.isSunday = false,
    this.checkIn,
    this.checkOut,
    this.totalHours,
    this.overtimeHours,
  });

  final DateTime workDate;
  final bool hasShift;
  final String? shiftNote;

  /// Hệ số lương của ngày (ngày thường, chủ nhật, ngày lễ), R34.
  final double? coefficient;
  final bool isHoliday;
  final bool isSunday;
  final String? checkIn;
  final String? checkOut;
  final double? totalHours;
  final double? overtimeHours;

  bool get done => checkOut != null;
}

/// Kết quả một lượt bấm: vào ca hay ra ca, ra ca thì kèm tổng giờ (R33).
class ClockPunch {
  const ClockPunch({required this.checkedIn, required this.time, this.totalHours, this.overtimeHours});

  final bool checkedIn;
  final String time;
  final double? totalHours;
  final double? overtimeHours;
}

class OvertimeRequest {
  const OvertimeRequest({
    required this.id,
    required this.employeeId,
    required this.workDate,
    required this.hours,
    required this.status,
    this.reason,
  });

  final String id;
  final String employeeId;
  final DateTime workDate;
  final double hours;
  final LeaveStatus status;
  final String? reason;
}
