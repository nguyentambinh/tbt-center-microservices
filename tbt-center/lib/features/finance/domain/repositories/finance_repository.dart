/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/finance.dart';

abstract interface class FinanceRepository {
  Future<FinanceYear> year(int year);

  Future<List<Supplier>> suppliers();

  Future<SupplierDetail> supplier(String id);

  /// Số tiền gửi dạng chuỗi, server tự lấy tỷ giá của ngày phát sinh.
  Future<void> recordPurchase({
    required String supplierId,
    required String materialName,
    required DateTime date,
    required String amount,
  });

  Future<void> recordPayment({required String supplierId, required DateTime date, required String amount, String? note});

  Future<void> closePeriod(String period);

  /// Thu, chi vật liệu, chi lương, lợi nhuận theo `day`, `month` hoặc `year`
  Future<FinanceSeries> analytics(String granularity);

  /// Dự án xếp theo lợi nhuận
  Future<List<ProjectFinance>> projectRanking();

  /// Doanh thu theo đợt, vật liệu đã dùng của một dự án
  Future<ProjectFinanceDetail> projectFinance(String projectId);
}
