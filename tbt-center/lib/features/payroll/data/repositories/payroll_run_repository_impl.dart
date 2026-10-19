/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/payout.dart';
import '../../domain/entities/payroll_run.dart';
import '../../domain/repositories/payroll_run_repository.dart';

class PayrollRunRepositoryImpl implements PayrollRunRepository {
  PayrollRunRepositoryImpl(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  String get _root => '$baseUrl/payroll/payroll-runs';
  String get _payouts => '$baseUrl/payroll/payouts';

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

  @override
  Future<PayoutBoard> payouts(String period) async {
    final data = await _call(() => _dio.get<Map<String, dynamic>>(_payouts, queryParameters: {'period': period}));
    return PayoutBoard(
      period: period,
      runStatus: data['runStatus'] as String?,
      lines: [
        for (final l in data['items'] as List)
          PayoutLine(
            employeeId: (l as Map<String, dynamic>)['employeeId'] as String,
            paid: l['status'] == 'paid',
            transfers: l['transfers'] as int? ?? 0,
            net: double.tryParse('${l['net']}'),
            currency: l['currency'] as String?,
            paidOn: DateTime.tryParse('${l['paidOn']}'),
          ),
      ],
    );
  }

  @override
  Future<PayoutResult> transfer(
    String period, {
    List<String>? employeeIds,
    DuplicateMode duplicates = DuplicateMode.ask,
  }) async {
    final Map<String, dynamic> data;
    try {
      data = (await _dio.post<Map<String, dynamic>>(_payouts, data: {
        'period': period,
        'employeeIds': ?employeeIds,
        'duplicates': duplicates.name,
      }))
          .data!;
    } on DioException catch (e) {
      // Trùng người đã nhận: không phải lỗi, trả danh sách để người dùng chọn
      final body = e.response?.data;
      if (e.response?.statusCode == 409 && body is Map<String, dynamic> && body['code'] == 'already_paid') {
        return PayoutResult(
          pending: body['pending'] as int? ?? 0,
          duplicates: [
            for (final d in body['duplicates'] as List)
              PayoutDuplicate(
                employeeId: (d as Map<String, dynamic>)['employeeId'] as String,
                transfers: d['transfers'] as int? ?? 1,
                paidOn: DateTime.tryParse('${d['paidOn']}'),
              ),
          ],
        );
      }
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
    return PayoutResult(
      paid: data['paid'] as int? ?? 0,
      resent: data['resent'] as int? ?? 0,
      skipped: data['skipped'] as int? ?? 0,
      failed: data['failed'] as int? ?? 0,
      accepted: data['accepted'] as int? ?? 0,
      missing: [for (final m in data['missing'] as List? ?? const []) '$m'],
    );
  }

  @override
  Future<List<PayoutLogItem>> payoutLog(String period) async {
    final data =
        await _call(() => _dio.get<Map<String, dynamic>>('$_payouts/log', queryParameters: {'period': period}));
    return [
      for (final i in data['items'] as List)
        PayoutLogItem(
          employeeId: (i as Map<String, dynamic>)['employeeId'] as String,
          action: i['action'] as String,
          source: i['source'] as String,
          actor: i['actor'] as String,
          at: DateTime.parse(i['at'] as String).toLocal(),
          amount: i['amount'] as String?,
          currency: i['currency'] as String?,
          reference: i['reference'] as String?,
        ),
    ];
  }

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
