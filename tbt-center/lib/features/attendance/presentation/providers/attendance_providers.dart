/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/config/env.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/work_time_repository_impl.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/work_time.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/work_time_repository.dart';

/// Vai trò được duyệt đơn nghỉ, khớp với service attendance.
const leaveApproverRoles = {'hr', 'admin', 'executive'};

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return AttendanceRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

/// Chấm công của tháng chứa [month] (lấy ngày 1 của tháng làm khóa).
final timesheetProvider = FutureProvider.family<Timesheet, DateTime>((ref, month) {
  final from = DateTime(month.year, month.month);
  final to = DateTime(month.year, month.month + 1, 0);
  return ref.watch(attendanceRepositoryProvider).timesheet(from: from, to: to);
});

final myLeavesProvider = FutureProvider<List<LeaveRequest>>(
  (ref) => ref.watch(attendanceRepositoryProvider).leaveRequests(),
);

final pendingLeavesProvider = FutureProvider<List<LeaveRequest>>(
  (ref) => ref.watch(attendanceRepositoryProvider).leaveRequests(pendingOnly: true),
);

final workTimeRepositoryProvider = Provider<WorkTimeRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return WorkTimeRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final clockTodayProvider = FutureProvider<ClockToday>((ref) => ref.watch(workTimeRepositoryProvider).today());

final myOvertimeProvider = FutureProvider<List<OvertimeRequest>>(
  (ref) => ref.watch(workTimeRepositoryProvider).overtimeRequests(),
);

final pendingOvertimeProvider = FutureProvider<List<OvertimeRequest>>(
  (ref) => ref.watch(workTimeRepositoryProvider).overtimeRequests(pendingOnly: true),
);
