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
            base: _number(p['base']),
            overtime: _number(p['overtime']),
            bonus: _number(p['bonus']),
            insurance: _number(p['insurance']),
            tax: _number(p['tax']),
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

  @override
  Future<List<RaiseRequest>> raiseRequests({String? status}) async {
    final data = await _send(() => _dio.get<Map<String, dynamic>>('$baseUrl/payroll/raise-requests', queryParameters: {'status': ?status}));
    return [for (final r in data['items'] as List) _raise(r as Map<String, dynamic>)];
  }

  @override
  Future<RaiseRequest> requestRaise({required double amount, required String reason}) async =>
      _raise(await _send(() => _dio.post<Map<String, dynamic>>('$baseUrl/payroll/raise-requests', data: {'requested': amount, 'reason': reason})));

  @override
  Future<RaiseRequest> respondRaise(int id, {required String action, double? amount, String? note}) async => _raise(
        await _send(() => _dio.post<Map<String, dynamic>>(
              '$baseUrl/payroll/raise-requests/$id/respond',
              data: {'action': action, 'amount': ?amount, 'note': ?note},
            )),
      );

  Future<Map<String, dynamic>> _send(Future<Response<Map<String, dynamic>>> Function() request) async {
    try {
      return (await request()).data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  static RaiseRequest _raise(Map<String, dynamic> r) => RaiseRequest(
        id: r['id'] as int,
        employeeId: r['employeeId'] as String,
        currentSalary: _number(r['currentSalary']) ?? 0,
        requested: _number(r['requested']) ?? 0,
        proposed: _number(r['proposed']) ?? 0,
        currency: r['currency'] as String? ?? 'USD',
        reason: r['reason'] as String? ?? '',
        status: r['status'] as String,
        skipHr: r['skipHr'] == true,
        bonusesPenalties: [
          for (final b in r['bonusesPenalties'] as List? ?? const [])
            BonusPenalty(
              date: DateTime.parse((b as Map<String, dynamic>)['date'] as String),
              isBonus: b['kind'] == 'bonus',
              total: _number(b['total']) ?? 0,
              currency: b['currency'] as String? ?? 'USD',
            ),
        ],
        updatedAt: DateTime.tryParse('${r['updatedAt']}')?.toLocal() ?? DateTime.now(),
        events: [
          for (final e in r['events'] as List? ?? const [])
            (
              action: (e as Map<String, dynamic>)['action'] as String,
              actor: e['actor'] as String? ?? '',
              amount: _number(e['amount']),
              note: e['note'] as String?,
              at: DateTime.parse(e['at'] as String).toLocal(),
            ),
        ],
      );

  /// Server trả tiền dạng chuỗi để không mất số lẻ khi đi qua JSON.
  static double? _number(Object? value) => value == null ? null : double.tryParse(value.toString());
}
