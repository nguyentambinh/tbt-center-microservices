/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-19
 */

/// Phiếu lương một người trong kỳ và số lần đã chuyển
class PayoutLine {
  const PayoutLine({required this.employeeId, required this.paid, this.transfers = 0, this.net, this.currency, this.paidOn});

  final String employeeId;
  final bool paid;
  final int transfers;

  /// `null` khi xem công ty khác: lương từng người chỉ hiện trong khu vực
  final double? net;
  final String? currency;
  final DateTime? paidOn;
}

class PayoutBoard {
  const PayoutBoard({required this.period, this.runStatus, this.lines = const []});

  final String period;
  final String? runStatus;
  final List<PayoutLine> lines;
}

/// Gặp người đã nhận lương kỳ này thì hỏi lại, bỏ qua hay chuyển lại
enum DuplicateMode { ask, skip, resend }

class PayoutDuplicate {
  const PayoutDuplicate({required this.employeeId, required this.transfers, this.paidOn});

  final String employeeId;
  final int transfers;
  final DateTime? paidOn;
}

/// Kết quả một lượt chuyển; [duplicates] khác rỗng là chưa chuyển gì, chờ chọn
class PayoutResult {
  const PayoutResult({
    this.paid = 0,
    this.resent = 0,
    this.skipped = 0,
    this.failed = 0,
    this.missing = const [],
    this.duplicates = const [],
    this.pending = 0,
    this.accepted = 0,
  });

  final int paid;
  final int resent;
  final int skipped;
  final int failed;
  final List<String> missing;
  final List<PayoutDuplicate> duplicates;
  final int pending;

  /// Số khoản server đang chuyển ở nền
  final int accepted;

  bool get needsDecision => duplicates.isNotEmpty;
}

class PayoutLogItem {
  const PayoutLogItem({
    required this.employeeId,
    required this.action,
    required this.source,
    required this.actor,
    required this.at,
    this.amount,
    this.currency,
    this.reference,
  });

  final String employeeId;

  /// paid, resent, skipped, duplicate_warning, failed
  final String action;

  /// saga hoặc manual
  final String source;
  final String actor;
  final DateTime at;
  final String? amount;
  final String? currency;
  final String? reference;
}
