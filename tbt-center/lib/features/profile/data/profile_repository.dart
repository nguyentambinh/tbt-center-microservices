/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dio/dio.dart';

import '../../../core/error/app_failure.dart';
import '../../hr/data/models/employee_models.dart';
import '../../hr/domain/entities/employee.dart';
import '../domain/change_request.dart';

/// Hồ sơ của chính mình và đề xuất sửa thông tin, qua service hr của khu vực
abstract interface class ProfileRepository {
  Future<EmployeeDetail> me();
  Future<List<ChangeRequest>> myRequests();
  Future<ChangeRequest> submit(Map<String, Object?> changes, {String? reason});

  /// HR: đề xuất theo trạng thái (null là tất cả)
  Future<List<ChangeRequest>> requests({String? status});
  Future<ChangeRequest> decide(int id, {required bool approve, String? note});
}

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  @override
  Future<EmployeeDetail> me() async => employeeDetailFromJson(await _call('GET', '/hr/me'));

  @override
  Future<List<ChangeRequest>> myRequests() async => _list(await _call('GET', '/hr/me/change-requests'));

  @override
  Future<ChangeRequest> submit(Map<String, Object?> changes, {String? reason}) async =>
      ChangeRequest.fromJson(await _call('POST', '/hr/me/change-requests', {'changes': changes, 'reason': reason}));

  @override
  Future<List<ChangeRequest>> requests({String? status}) async =>
      _list(await _call('GET', '/hr/change-requests', null, {'status': ?status}));

  @override
  Future<ChangeRequest> decide(int id, {required bool approve, String? note}) async =>
      ChangeRequest.fromJson(await _call('POST', '/hr/change-requests/$id/decision', {'approve': approve, 'note': note}));

  static List<ChangeRequest> _list(Map<String, dynamic> data) => [
        for (final r in data['items'] as List) ChangeRequest.fromJson(r as Map<String, dynamic>),
      ];

  Future<Map<String, dynamic>> _call(String method, String path, [Object? body, Map<String, Object>? query]) async {
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        '$baseUrl$path',
        data: body,
        queryParameters: query,
        options: Options(method: method),
      );
      return response.data!;
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}
