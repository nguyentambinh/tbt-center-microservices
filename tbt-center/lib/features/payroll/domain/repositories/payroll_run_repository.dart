/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/payroll_run.dart';

/// Saga chốt lương ở service payroll của khu vực.
abstract interface class PayrollRunRepository {
  Future<List<PayrollRun>> runs();
  Future<PayrollRun> run(String id);
  Future<PayrollRun> start(String period);
  Future<PayrollRun> retry(String id);
}
