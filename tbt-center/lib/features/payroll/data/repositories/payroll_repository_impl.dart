/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/payroll.dart';
import '../../domain/repositories/payroll_repository.dart';

class PayrollRepositoryImpl implements PayrollRepository {
  PayrollRepositoryImpl(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  @override
  Future<PayrollSummary> myPayroll() async {
    final Map<String, dynamic> data;
    try {
      data = (await _dio.get<Map<String, dynamic>>('$baseUrl/payroll/payslips')).data!;
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
    final salary = data['salary'] as Map<String, dynamic>?;
    return PayrollSummary(
      baseSalary: _number(salary?['baseSalary']),
      currency: salary?['currency'] as String?,
      payslips: [
        for (final p in data['payslips'] as List)
          Payslip(
            period: (p as Map<String, dynamic>)['period'] as String,
            gross: _number(p['gross']) ?? 0,
            net: _number(p['net']) ?? 0,
            currency: p['currency'] as String,
            netUsd: _number(p['netUsd']),
            paidOn: DateTime.tryParse(p['paidOn'] as String? ?? ''),
          ),
      ],
      bonusesPenalties: [
        for (final b in data['bonusesPenalties'] as List)
          BonusPenalty(
            date: DateTime.parse((b as Map<String, dynamic>)['date'] as String),
            isBonus: b['kind'] == 'bonus',
            total: _number(b['total']) ?? 0,
            currency: b['currency'] as String,
          ),
      ],
    );
  }

  /// Server trả tiền dạng chuỗi để không mất số lẻ khi đi qua JSON.
  static double? _number(Object? value) => value == null ? null : double.tryParse(value.toString());
}
