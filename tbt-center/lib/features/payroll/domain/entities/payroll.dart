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
    this.base,
    this.overtime,
    this.bonus,
    this.insurance,
    this.tax,
  });

  /// Kỳ lương dạng `YYYY-MM`.
  final String period;
  final double gross;
  final double net;
  final String currency;

  /// Số thực nhận quy về USD theo tỷ giá ngày trả, lưu bất biến lúc phát lương.
  final double? netUsd;
  final DateTime? paidOn;

  /// Từng khoản: phiếu cũ chưa lưu thì chỉ có bảo hiểm, thuế (tách theo tỷ lệ)
  final double? base;
  final double? overtime;
  final double? bonus;
  final double? insurance;
  final double? tax;
}

class BonusPenalty {
  const BonusPenalty({required this.date, required this.isBonus, required this.total, required this.currency});

  final DateTime date;
  final bool isBonus;
  final double total;
  final String currency;
}

/// Đề xuất tăng lương: nhân viên gửi → HR chuyển lên → quản trị hoặc Ban điều hành duyệt
class RaiseRequest {
  const RaiseRequest({
    required this.id,
    required this.employeeId,
    required this.currentSalary,
    required this.requested,
    required this.proposed,
    required this.currency,
    required this.reason,
    required this.status,
    required this.updatedAt,
    this.events = const [],
    this.skipHr = false,
    this.bonusesPenalties = const [],
  });

  final int id;
  final String employeeId;
  final double currentSalary;

  /// Đề xuất của nhân viên HR: đi thẳng Ban lãnh đạo
  final bool skipHr;

  /// Thưởng phạt 12 tháng trước khi gửi, kèm theo cho bên duyệt xem
  final List<BonusPenalty> bonusesPenalties;
  final double requested;

  /// Mức đang đề xuất, chỉ giữ hoặc tăng qua mỗi lần sửa
  final double proposed;
  final String currency;
  final String reason;

  /// awaiting_hr, awaiting_approver, awaiting_employee, approved, rejected, withdrawn
  final String status;
  final DateTime updatedAt;
  final List<({String action, String actor, double? amount, String? note, DateTime at})> events;

  bool get open => status.startsWith('awaiting');
}

class PayrollSummary {
  const PayrollSummary({this.baseSalary, this.currency, this.payslips = const [], this.bonusesPenalties = const []});

  final double? baseSalary;
  final String? currency;
  final List<Payslip> payslips;
  final List<BonusPenalty> bonusesPenalties;
}
