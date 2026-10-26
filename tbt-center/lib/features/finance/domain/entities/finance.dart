/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Thu chi một tháng, bằng tiền khu vực và quy USD.
class MonthFigures {
  const MonthFigures({
    required this.period,
    required this.revenue,
    required this.revenueUsd,
    required this.cost,
    required this.costUsd,
    this.closedAt,
  });

  final String period;
  final double revenue;
  final double revenueUsd;
  final double cost;
  final double costUsd;

  /// Đã chốt sổ thì số liệu tháng này không đổi nữa.
  final DateTime? closedAt;

  double get profit => revenue - cost;
  bool get closed => closedAt != null;
}

class FinanceYear {
  const FinanceYear({required this.year, required this.currency, this.months = const []});

  final int year;
  final String currency;
  final List<MonthFigures> months;
}

class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    required this.purchased,
    required this.paid,
    required this.balance,
    this.contact,
    this.address,
    this.lastImport,
    this.purchases = 0,
    this.paidPercent,
  });

  final String id;
  final String name;
  final String? contact;
  final String? address;
  final double purchased;
  final double paid;

  /// Còn nợ nhà cung cấp.
  final double balance;
  final DateTime? lastImport;

  /// Số lần mua và phần trăm đã trả trên tổng mua, để xếp hạng (R105).
  final int purchases;
  final double? paidPercent;
}

class LedgerEntry {
  const LedgerEntry({required this.date, required this.amount, required this.currency, this.label});

  final DateTime date;
  final double amount;
  final String currency;

  /// Tên vật liệu với lần mua, ghi chú với lần trả.
  final String? label;
}

class SupplierDetail {
  const SupplierDetail({required this.supplier, this.imports = const [], this.payments = const []});

  final Supplier supplier;
  final List<LedgerEntry> imports;
  final List<LedgerEntry> payments;
}

/// Một mốc trên biểu đồ thu chi: ngày, tháng hoặc năm
class FinancePoint {
  const FinancePoint({required this.bucket, required this.revenue, required this.material, required this.payroll, required this.profit});

  final String bucket;
  final double revenue;
  final double material;
  final double payroll;
  final double profit;
}

class FinanceSeries {
  const FinanceSeries({required this.granularity, required this.currency, required this.points});

  final String granularity;
  final String currency;
  final List<FinancePoint> points;
}

/// Một dự án trong bảng xếp hạng lợi nhuận
class ProjectFinance {
  const ProjectFinance({required this.projectId, required this.rank, required this.revenue, required this.cost, required this.profit, this.margin});

  final String projectId;
  final int rank;
  final double revenue;
  final double cost;
  final double profit;
  final double? margin;
}

class ProjectFinanceDetail {
  const ProjectFinanceDetail({required this.projectId, required this.currency, required this.revenue, required this.cost, required this.revenues, required this.materials});

  final String projectId;
  final String currency;
  final double revenue;
  final double cost;
  final List<({DateTime date, double amount, String kind})> revenues;
  final List<({String name, DateTime date, String? supplier, double amount})> materials;

  double get profit => revenue - cost;
}
