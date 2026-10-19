/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Một trang kết quả kèm tổng số dòng để app biết còn trang sau không.
class Page<T> {
  const Page(
    this.items, {
    required this.total,
    required this.page,
    required this.size,
  });

  final List<T> items;
  final int total;
  final int page;
  final int size;

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) encode) => {
    'items': [for (final item in items) encode(item)],
    'total': total,
    'page': page,
    'size': size,
  };
}

class EmployeeSummary {
  const EmployeeSummary({
    required this.id,
    required this.familyName,
    required this.givenName,
    this.email,
    this.photoUrl,
    this.position,
    this.department,
    this.company,
  });

  final String id;
  final String familyName;
  final String givenName;
  final String? email;
  final String? photoUrl;
  final String? position;
  final String? department;
  final String? company;

  Map<String, dynamic> toJson() => {
    'id': id,
    'familyName': familyName,
    'givenName': givenName,
    'email': email,
    'photoUrl': photoUrl,
    'position': position,
    'department': department,
    'company': company,
  };
}

/// Hồ sơ đầy đủ: công việc, liên hệ, người thân, sức khỏe, bảo hiểm.
class EmployeeDetail {
  const EmployeeDetail({
    required this.summary,
    required this.work,
    this.contact,
    this.health,
    this.insurance,
    this.relatives = const [],
  });

  final EmployeeSummary summary;
  final Map<String, dynamic> work;
  final Map<String, dynamic>? contact;
  final Map<String, dynamic>? health;
  final Map<String, dynamic>? insurance;
  final List<Map<String, dynamic>> relatives;

  Map<String, dynamic> toJson() => {
    ...summary.toJson(),
    'work': work,
    'contact': contact,
    'health': health,
    'insurance': insurance,
    'relatives': relatives,
  };
}
