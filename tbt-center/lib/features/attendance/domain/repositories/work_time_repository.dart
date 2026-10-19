/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/work_time.dart';

/// Chấm công vào/ra và đơn tăng ca (R31–R33, R36).
abstract interface class WorkTimeRepository {
  Future<ClockToday> today();

  /// Server tự biết lượt này là vào ca hay ra ca.
  Future<ClockPunch> clock();

  /// Đơn của chính mình, hoặc (với quản lý, [pendingOnly]) mọi đơn đang chờ duyệt.
  Future<List<OvertimeRequest>> overtimeRequests({bool pendingOnly = false});

  Future<OvertimeRequest> requestOvertime({required DateTime workDate, required double hours, String? reason});

  Future<OvertimeRequest> decideOvertime(String id, {required bool approve});
}
