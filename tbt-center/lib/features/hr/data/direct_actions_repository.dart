/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/work_region.dart';
import '../../../core/config/env.dart';
import '../../../core/error/app_failure.dart';
import '../../../core/network/api_client.dart';

typedef PositionOption = ({String id, String name});

/// Văn phòng quản lý làm thẳng, có hiệu lực ngay: đổi chức vụ, đổi lương cơ bản, thưởng phạt
class DirectActionsRepository {
  DirectActionsRepository(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  Future<({double? baseSalary, String? currency})> salary(String employeeId) async {
    final data = await _send(() => _dio.get<Map<String, dynamic>>('$baseUrl/payroll/payslips', queryParameters: {'employee': employeeId}));
    final salary = data['salary'] as Map<String, dynamic>?;
    return (baseSalary: double.tryParse('${salary?['baseSalary']}'), currency: salary?['currency'] as String?);
  }

  /// Mọi chức vụ trong danh mục (đổi chức vụ ngang hoặc xuống)
  Future<List<PositionOption>> positions() async {
    final data = await _send(() => _dio.get<Map<String, dynamic>>('$baseUrl/hr/employees/filters'));
    return [
      for (final p in data['positions'] as List? ?? const []) (id: (p as Map<String, dynamic>)['id'] as String, name: p['name'] as String? ?? ''),
    ];
  }

  Future<void> changePosition(String employeeId, {required String positionId, required bool promote, String? reason}) => _send(
        () => _dio.post<Map<String, dynamic>>('$baseUrl/hr/employees/${Uri.encodeComponent(employeeId)}/position',
            data: {'positionId': positionId, 'promote': promote, 'reason': ?reason}),
      );

  Future<void> setBaseSalary(String employeeId, {required double amount, String? reason}) => _send(
        () => _dio.put<Map<String, dynamic>>('$baseUrl/payroll/salaries/${Uri.encodeComponent(employeeId)}', data: {'baseSalary': amount, 'reason': ?reason}),
      );

  Future<void> addBonusPenalty(String employeeId, {required bool bonus, required double amount, String? reason}) => _send(
        () => _dio.post<Map<String, dynamic>>('$baseUrl/payroll/bonuses-penalties',
            data: {'employeeId': employeeId, 'kind': bonus ? 'bonus' : 'penalty', 'amount': amount, 'reason': ?reason}),
      );

  Future<Map<String, dynamic>> _send(Future<Response<Map<String, dynamic>>> Function() call) async {
    try {
      return (await call()).data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}

final directActionsProvider = Provider<DirectActionsRepository>(
  (ref) => DirectActionsRepository(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(ref.watch(workRegionProvider))),
);
