/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

class Payslip {
  const Payslip({
    required this.period,
    required this.gross,
    required this.net,
    required this.currency,
    this.netUsd,
    this.paidOn,
  });

  /// Kỳ lương dạng `YYYY-MM`.
  final String period;
  final double gross;
  final double net;
  final String currency;

  /// Số thực nhận quy về USD theo tỷ giá ngày trả, lưu bất biến lúc phát lương.
  final double? netUsd;
  final DateTime? paidOn;
}

class BonusPenalty {
  const BonusPenalty({required this.date, required this.isBonus, required this.total, required this.currency});

  final DateTime date;
  final bool isBonus;
  final double total;
  final String currency;
}

class PayrollSummary {
  const PayrollSummary({this.baseSalary, this.currency, this.payslips = const [], this.bonusesPenalties = const []});

  final double? baseSalary;
  final String? currency;
  final List<Payslip> payslips;
  final List<BonusPenalty> bonusesPenalties;
}
