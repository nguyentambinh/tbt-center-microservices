/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../../domain/entities/employee.dart';

EmployeeSummary employeeSummaryFromJson(Map<String, dynamic> json) => EmployeeSummary(
      id: json['id'] as String,
      familyName: json['familyName'] as String? ?? '',
      givenName: json['givenName'] as String? ?? '',
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      position: json['position'] as String?,
      department: json['department'] as String?,
      company: json['company'] as String?,
    );

EmployeePage employeePageFromJson(Map<String, dynamic> json, {bool fromCache = false}) => EmployeePage(
      items: [
        for (final item in json['items'] as List) employeeSummaryFromJson(item as Map<String, dynamic>),
      ],
      total: json['total'] as int,
      page: json['page'] as int,
      fromCache: fromCache,
    );

EmployeeDetail employeeDetailFromJson(Map<String, dynamic> json) {
  final work = json['work'] as Map<String, dynamic>? ?? const {};
  return EmployeeDetail(
    summary: employeeSummaryFromJson(json),
    birthYear: work['birthYear'] as int?,
    gender: work['gender'] as int?,
    laborContract: work['laborContract'] as String?,
    hiredOn: DateTime.tryParse(work['hiredOn'] as String? ?? ''),
    contact: json['contact'] as Map<String, dynamic>? ?? const {},
    health: json['health'] as Map<String, dynamic>? ?? const {},
    insurance: json['insurance'] as Map<String, dynamic>? ?? const {},
    relatives: [
      for (final r in json['relatives'] as List? ?? const [])
        Relative(
          fullName: (r as Map<String, dynamic>)['fullName'] as String? ?? '',
          phone: r['phone'] as String?,
          address: r['address'] as String?,
          relationship: r['relationship'] as String?,
        ),
    ],
  );
}
