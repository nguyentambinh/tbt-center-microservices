/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/payroll_run.dart';
import '../../domain/repositories/payroll_run_repository.dart';

class PayrollRunRepositoryImpl implements PayrollRunRepository {
  PayrollRunRepositoryImpl(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  String get _root => '$baseUrl/payroll/payroll-runs';

  @override
  Future<List<PayrollRun>> runs() async {
    final data = await _call(() => _dio.get<Map<String, dynamic>>(_root));
    return [for (final r in data['items'] as List) payrollRunFromJson(r as Map<String, dynamic>)];
  }

  @override
  Future<PayrollRun> run(String id) async =>
      payrollRunFromJson(await _call(() => _dio.get<Map<String, dynamic>>('$_root/$id')));

  @override
  Future<PayrollRun> start(String period) async =>
      payrollRunFromJson(await _call(() => _dio.post<Map<String, dynamic>>(_root, data: {'period': period})));

  @override
  Future<PayrollRun> retry(String id) async =>
      payrollRunFromJson(await _call(() => _dio.post<Map<String, dynamic>>('$_root/$id/retry')));

  Future<Map<String, dynamic>> _call(Future<Response<Map<String, dynamic>>> Function() request) async {
    try {
      return (await request()).data!;
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}

PayrollRun payrollRunFromJson(Map<String, dynamic> json) {
  final paid = (json['payslips'] as Map<String, dynamic>?)?['paid'] as Map<String, dynamic>?;
  return PayrollRun(
    id: json['id'] as String,
    period: json['period'] as String,
    status: json['status'] as String,
    error: json['error'] as String?,
    paidCount: paid?['count'] as int? ?? 0,
    paidUsd: double.tryParse('${paid?['totalUsd']}'),
    steps: [
      for (final s in json['steps'] as List? ?? const [])
        SagaStep(
          step: (s as Map<String, dynamic>)['step'] as String,
          status: s['status'] as String,
          detail: s['detail'] as String?,
          at: DateTime.parse(s['at'] as String),
        ),
    ],
  );
}
