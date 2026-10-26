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

  /// Nhân viên thấy đề xuất của mình; HR, quản trị, Ban điều hành thấy cả khu vực
  Future<List<RaiseRequest>> raiseRequests({String? status});

  Future<RaiseRequest> requestRaise({required double amount, required String reason});

  /// edit, withdraw (nhân viên); forward, return, reject (HR); approve, return, reject (bên duyệt)
  Future<RaiseRequest> respondRaise(int id, {required String action, double? amount, String? note});
}
