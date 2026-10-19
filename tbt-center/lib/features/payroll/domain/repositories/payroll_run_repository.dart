/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/payout.dart';
import '../entities/payroll_run.dart';

/// Saga chốt lương ở service payroll của khu vực.
abstract interface class PayrollRunRepository {
  Future<List<PayrollRun>> runs();
  Future<PayrollRun> run(String id);
  Future<PayrollRun> start(String period);
  Future<PayrollRun> retry(String id);

  /// Phiếu lương từng người của kỳ, đã chuyển mấy lần
  Future<PayoutBoard> payouts(String period);

  /// Chuyển cho cả công ty ([employeeIds] null) hoặc những người đã chọn
  Future<PayoutResult> transfer(String period, {List<String>? employeeIds, DuplicateMode duplicates});

  Future<List<PayoutLogItem>> payoutLog(String period);
}
