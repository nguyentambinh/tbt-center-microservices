/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/employee.dart';

abstract interface class EmployeeRepository {
  Future<EmployeePage> search({String query = '', int page = 1});
  Future<EmployeeDetail> find(String id);
}
