/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/payroll.dart';

abstract interface class PayrollRepository {
  /// Lương, phiếu lương các kỳ, thưởng phạt của chính người đăng nhập.
  Future<PayrollSummary> myPayroll();
}
