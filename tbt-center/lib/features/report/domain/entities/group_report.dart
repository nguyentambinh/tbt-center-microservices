/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

class RegionPayroll {
  const RegionPayroll({required this.region, required this.period, required this.employees, required this.totalUsd});

  final String region;
  final String period;
  final int employees;
  final double totalUsd;
}

class RegionFinance {
  const RegionFinance({required this.region, required this.period, required this.revenueUsd, required this.costUsd});

  final String region;
  final String period;
  final double revenueUsd;
  final double costUsd;
}

/// Giờ làm và giờ tăng ca đã duyệt của một khu vực trong một tháng (R76, R77).
class RegionWork {
  const RegionWork({
    required this.region,
    required this.period,
    required this.employees,
    required this.hours,
    required this.overtimeHours,
  });

  final String region;
  final String period;
  final int employees;
  final double hours;
  final double overtimeHours;
}

class RegionCount {
  const RegionCount({required this.region, required this.status, required this.count, this.days});

  final String region;
  final String status;
  final int count;
  final int? days;
}

class GroupReport {
  const GroupReport({
    this.payroll = const [],
    this.finance = const [],
    this.work = const [],
    this.leaves = const [],
    this.candidates = const [],
    this.projectedUntilEvent = 0,
  });

  final List<RegionPayroll> payroll;

  /// Doanh thu, chi phí các tháng đã chốt sổ ở từng khu vực.
  final List<RegionFinance> finance;
  final List<RegionWork> work;
  final List<RegionCount> leaves;
  final List<RegionCount> candidates;

  /// Báo cáo đọc từ Doris đi sau dữ liệu thật vài giây: đã cập nhật tới sự kiện nào.
  final int projectedUntilEvent;
}
