/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/group_report.dart';
import '../../domain/repositories/report_repository.dart';

/// Báo cáo hợp nhất nằm ở Hub, gọi qua Kong của khu vực người dùng.
class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  @override
  Future<GroupReport> overview() async {
    final Map<String, dynamic> d;
    try {
      d = (await _dio.get<Map<String, dynamic>>('$baseUrl/report/overview')).data!;
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
    int n(Object? v) => (v as num?)?.toInt() ?? 0;
    List<RegionCount> counts(String key, String countKey) => [
          for (final r in d[key] as List)
            RegionCount(
              region: (r as Map<String, dynamic>)['region'] as String,
              status: r['status'] as String,
              count: n(r[countKey]),
              days: r['days'] == null ? null : n(r['days']),
            ),
        ];
    return GroupReport(
      payroll: [
        for (final r in d['payrollByRegion'] as List)
          RegionPayroll(
            region: (r as Map<String, dynamic>)['region'] as String,
            period: r['period'] as String,
            employees: n(r['employees']),
            totalUsd: (r['total_usd'] as num).toDouble(),
          ),
      ],
      finance: [
        for (final r in d['financeByRegion'] as List? ?? const [])
          RegionFinance(
            region: (r as Map<String, dynamic>)['region'] as String,
            period: r['period'] as String,
            revenueUsd: (r['revenue_usd'] as num).toDouble(),
            costUsd: (r['cost_usd'] as num).toDouble(),
          ),
      ],
      work: [
        for (final r in d['workByRegion'] as List? ?? const [])
          RegionWork(
            region: (r as Map<String, dynamic>)['region'] as String,
            period: r['period'] as String,
            employees: n(r['employees']),
            hours: (r['hours'] as num?)?.toDouble() ?? 0,
            overtimeHours: (r['overtime_hours'] as num?)?.toDouble() ?? 0,
          ),
      ],
      leaves: counts('leavesByRegion', 'requests'),
      candidates: counts('candidatesByRegion', 'candidates'),
      projectedUntilEvent: n(d['projectedUntilEvent']),
    );
  }
}
