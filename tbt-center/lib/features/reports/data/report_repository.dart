/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dio/dio.dart';

import '../../../core/error/app_failure.dart';
import '../domain/report_submission.dart';

/// Báo cáo nhân sự ở service hr, báo cáo tài chính ở service finance của khu vực
class ReportRepository {
  ReportRepository(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  String _root(String kind) => '$baseUrl/${kind == 'hr' ? 'hr' : 'finance'}/reports';

  Future<List<ReportSubmission>> list(String kind) async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>(_root(kind)));
    return [for (final r in d['items'] as List) _report(r as Map<String, dynamic>)];
  }

  Future<ReportSubmission> submit(String kind, {required String period, String? note}) async =>
      _report(await _call(() => _dio.post<Map<String, dynamic>>(_root(kind), data: {'period': period, 'note': ?note})));

  /// `acknowledge` hoặc `return`
  Future<ReportSubmission> review(String kind, int id, {required String action, String? note}) async =>
      _report(await _call(() => _dio.post<Map<String, dynamic>>('${_root(kind)}/$id/review', data: {'action': action, 'note': ?note})));

  Future<Map<String, dynamic>> _call(Future<Response<Map<String, dynamic>>> Function() send) async {
    try {
      return (await send()).data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  static ReportSubmission _report(Map<String, dynamic> r) => ReportSubmission(
        id: r['id'] as int,
        kind: r['kind'] as String,
        period: r['period'] as String,
        status: r['status'] as String,
        data: r['data'] as Map<String, dynamic>? ?? const {},
        submittedBy: r['submittedBy'] as String? ?? '',
        createdAt: DateTime.tryParse('${r['createdAt']}')?.toLocal() ?? DateTime.now(),
        note: r['note'] as String?,
        reviewedBy: r['reviewedBy'] as String?,
        reviewNote: r['reviewNote'] as String?,
      );
}
