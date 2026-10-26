/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/work_region.dart';
import '../../../../core/config/env.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/work_time_repository_impl.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/work_calendar.dart';
import '../../domain/entities/work_time.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/work_time_repository.dart';

/// Vai trò được duyệt đơn nghỉ, khớp với service attendance.
const leaveApproverRoles = {'hr', 'admin', 'executive'};

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final region = ref.watch(workRegionProvider);
  return AttendanceRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

/// Chấm công của tháng chứa [month] (lấy ngày 1 của tháng làm khóa).
final timesheetProvider = FutureProvider.family<Timesheet, DateTime>((ref, month) {
  final from = DateTime(month.year, month.month);
  final to = DateTime(month.year, month.month + 1, 0);
  return ref.watch(attendanceRepositoryProvider).timesheet(from: from, to: to);
});

/// Lịch làm việc của tháng chứa [month] (khóa là ngày 1 của tháng)
final calendarProvider = FutureProvider.autoDispose.family<List<CalendarDay>, DateTime>((ref, month) {
  final from = DateTime(month.year, month.month);
  final to = DateTime(month.year, month.month + 1, 0);
  return ref.watch(attendanceRepositoryProvider).calendar(from: from, to: to);
});

final clockStatsProvider = FutureProvider.autoDispose.family<ClockStats, int>(
  (ref, months) => ref.watch(attendanceRepositoryProvider).stats(months: months),
);

final leaveFilesProvider = FutureProvider.autoDispose.family<List<LeaveFile>, String>(
  (ref, id) => ref.watch(attendanceRepositoryProvider).leaveFiles(id),
);

final myLeavesProvider = FutureProvider<List<LeaveRequest>>(
  (ref) => ref.watch(attendanceRepositoryProvider).leaveRequests(),
);

final pendingLeavesProvider = FutureProvider<List<LeaveRequest>>(
  (ref) => ref.watch(attendanceRepositoryProvider).leaveRequests(pendingOnly: true),
);

final workTimeRepositoryProvider = Provider<WorkTimeRepository>((ref) {
  final region = ref.watch(workRegionProvider);
  return WorkTimeRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final clockTodayProvider = FutureProvider<ClockToday>((ref) => ref.watch(workTimeRepositoryProvider).today());

/// Ngày hôm nay theo múi giờ khu vực của tài khoản (server trả), chưa có thì theo điện thoại
final regionTodayProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return ref.watch(clockTodayProvider).value?.workDate ?? DateTime(now.year, now.month, now.day);
});

final myOvertimeProvider = FutureProvider<List<OvertimeRequest>>(
  (ref) => ref.watch(workTimeRepositoryProvider).overtimeRequests(),
);

final pendingOvertimeProvider = FutureProvider<List<OvertimeRequest>>(
  (ref) => ref.watch(workTimeRepositoryProvider).overtimeRequests(pendingOnly: true),
);
