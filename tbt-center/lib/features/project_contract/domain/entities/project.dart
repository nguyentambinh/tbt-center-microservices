/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

class ProjectSummary {
  const ProjectSummary({
    required this.id,
    required this.currency,
    this.name,
    this.customerName,
    this.deposit,
    this.expectedAcceptance,
    this.members = 0,
    this.status = 'in_progress',
    this.acceptedOn,
  });

  final String id;

  /// Tên hợp đồng đầu tiên của dự án; dữ liệu cũ không có tên dự án riêng.
  final String? name;
  final String? customerName;
  final double? deposit;
  final double? expectedAcceptance;
  final String currency;
  final int members;

  /// `in_progress` hoặc `accepted` (đã nghiệm thu, doanh thu đã ghi ở tài chính).
  final String status;
  final DateTime? acceptedOn;

  bool get accepted => status == 'accepted';
}

class ProjectContract {
  const ProjectContract({required this.contractId, this.name, this.startDate, this.expectedEndDate, this.endDate});

  final String contractId;
  final String? name;
  final DateTime? startDate;
  final DateTime? expectedEndDate;
  final DateTime? endDate;
}

class ProjectMember {
  const ProjectMember({required this.employeeId, required this.hours, this.projectSalary});

  final String employeeId;
  final double hours;
  final double? projectSalary;
}

class Customer {
  const Customer({required this.name, this.contact, this.address});

  final String name;

  /// Chỉ tài chính, quản trị, lãnh đạo nhận được; HR thấy `null`.
  final String? contact;
  final String? address;
}

/// Xác nhận gửi khách hàng (R102): kênh `email` hoặc `sms`, trạng thái `queued`, `sent`.
class CustomerNotice {
  const CustomerNotice({required this.channel, required this.status});

  final String channel;
  final String status;
}

class ProjectDetail {
  const ProjectDetail({
    required this.summary,
    this.customer,
    this.contracts = const [],
    this.members = const [],
    this.notices = const [],
  });

  final ProjectSummary summary;
  final Customer? customer;
  final List<ProjectContract> contracts;
  final List<ProjectMember> members;
  final List<CustomerNotice> notices;
}

/// Một dự án mình đang tham gia (R38).
class MyProject {
  const MyProject({required this.projectId, required this.hours, this.name, this.startDate, this.endDate});

  final String projectId;
  final String? name;
  final double hours;
  final DateTime? startDate;
  final DateTime? endDate;
}
