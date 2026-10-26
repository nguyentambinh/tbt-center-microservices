/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

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

  /// Tên đầy đủ theo thứ tự của dữ liệu: ở VN họ trước tên, nước khác tên trước họ.
  String fullName({required bool familyFirst}) =>
      familyFirst ? '$familyName $givenName' : '$givenName $familyName';

  String get initials => '${givenName.isEmpty ? '' : givenName[0]}${familyName.isEmpty ? '' : familyName[0]}';
}

class Relative {
  const Relative({required this.fullName, this.phone, this.address, this.relationship});

  final String fullName;
  final String? phone;
  final String? address;
  final String? relationship;
}

class EmployeeDetail {
  const EmployeeDetail({
    required this.summary,
    this.birthYear,
    this.gender,
    this.laborContract,
    this.hiredOn,
    this.contact = const {},
    this.health = const {},
    this.insurance = const {},
    this.relatives = const [],
    this.departmentId,
    this.status = 'active',
    this.archivedReason,
  });

  final EmployeeSummary summary;
  final int? birthYear;

  /// 1 là nam, 0 là nữ (theo dữ liệu cũ).
  final int? gender;
  final String? laborContract;
  final DateTime? hiredOn;
  final Map<String, Object?> contact;
  final Map<String, Object?> health;
  final Map<String, Object?> insurance;
  final List<Relative> relatives;
  final String? departmentId;

  /// active hoặc archived (bảo lưu)
  final String status;
  final String? archivedReason;

  bool get archived => status == 'archived';
}

/// Bộ lọc hồ sơ: phòng ban, chức vụ, công ty, trạng thái (đang làm/bảo lưu)
class EmployeeFilter {
  const EmployeeFilter({this.departmentId, this.positionId, this.companyId, this.status});

  final String? departmentId;
  final String? positionId;
  final String? companyId;
  final String? status;

  @override
  bool operator ==(Object other) =>
      other is EmployeeFilter && other.departmentId == departmentId && other.positionId == positionId && other.companyId == companyId && other.status == status;

  @override
  int get hashCode => Object.hash(departmentId, positionId, companyId, status);
}

class EmployeePage {
  const EmployeePage({required this.items, required this.total, required this.page, this.fromCache = false});

  final List<EmployeeSummary> items;
  final int total;
  final int page;

  /// Dữ liệu lấy từ cache vì đang mất mạng.
  final bool fromCache;
}
