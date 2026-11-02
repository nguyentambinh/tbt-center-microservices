/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../models/employee_models.dart';

/// Gọi service `hr` của khu vực người dùng qua Kong.
class EmployeeRepositoryImpl implements EmployeeRepository {
  EmployeeRepositoryImpl(this._dio, {required this.baseUrl});

  static const pageSize = 30;
  static const fullPageSize = 100;

  final Dio _dio;
  final String baseUrl;

  @override
  Future<EmployeePage> search({String query = '', int page = 1, EmployeeFilter filter = const EmployeeFilter()}) async {
    final response = await _get('/hr/employees', {
      if (query.isNotEmpty) 'q': query,
      'departmentId': ?filter.departmentId,
      'positionId': ?filter.positionId,
      'companyId': ?filter.companyId,
      'status': ?filter.status,
      'page': page,
      'size': pageSize,
    });
    return employeePageFromJson(response.data!, fromCache: response.extra[fromCache] == true);
  }

  /// Toàn bộ nhân viên theo trạng thái: lấy trang đầu để biết tổng rồi tải song song phần còn lại
  Future<List<EmployeeSummary>> all({required String status}) async {
    Future<EmployeePage> fetch(int page) async {
      final response = await _get('/hr/employees', {'status': status, 'page': page, 'size': fullPageSize});
      return employeePageFromJson(response.data!, fromCache: response.extra[fromCache] == true);
    }

    final first = await fetch(1);
    final pages = (first.total / fullPageSize).ceil();
    final rest = await Future.wait([for (var page = 2; page <= pages; page++) fetch(page)]);
    return [...first.items, for (final page in rest) ...page.items];
  }

  @override
  Future<EmployeeDetail> find(String id) async {
    final response = await _get('/hr/employees/${Uri.encodeComponent(id)}', const {});
    return employeeDetailFromJson(response.data!);
  }

  Future<Response<Map<String, dynamic>>> _get(String path, Map<String, Object> query) async {
    try {
      return await _dio.get<Map<String, dynamic>>('$baseUrl$path', queryParameters: query);
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}
