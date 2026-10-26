/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/job_position.dart';

/// Vị trí tuyển dụng ở service recruitment của khu vực
class JobPositionRepository {
  JobPositionRepository(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  String get _root => '$baseUrl/recruitment/positions';

  /// Ứng viên chỉ nhận vị trí đang tuyển; HR đặt [all] để thấy cả vị trí đã đóng
  Future<List<JobPosition>> list({bool all = false}) async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>(_root, queryParameters: {if (all) 'all': '1'}));
    return [for (final p in d['items'] as List) positionFromJson(p as Map<String, dynamic>)];
  }

  Future<JobPosition> find(int id) async => positionFromJson(await _call(() => _dio.get<Map<String, dynamic>>('$_root/$id')));

  Future<JobPosition> create(JobPositionInput input) async => positionFromJson(await _call(() => _dio.post<Map<String, dynamic>>(_root, data: _body(input))));

  Future<JobPosition> update(int id, JobPositionInput input) async => positionFromJson(await _call(() => _dio.put<Map<String, dynamic>>('$_root/$id', data: _body(input))));

  static Map<String, Object?> _body(JobPositionInput i) => {
        'title': i.title,
        'headcount': i.headcount,
        'department': i.department,
        'description': i.description,
        'requirements': i.requirements,
        'status': i.status,
      };

  Future<Map<String, dynamic>> _call(Future<Response<Map<String, dynamic>>> Function() send) async {
    try {
      return (await send()).data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}

JobPosition positionFromJson(Map<String, dynamic> p) => JobPosition(
      id: (p['id'] as num).toInt(),
      title: p['title'] as String? ?? '',
      department: p['department'] as String?,
      description: p['description'] as String? ?? '',
      requirements: p['requirements'] as String? ?? '',
      headcount: (p['headcount'] as num? ?? 1).toInt(),
      status: p['status'] as String? ?? 'open',
      applicants: (p['applicants'] as num? ?? 0).toInt(),
      hired: (p['hired'] as num? ?? 0).toInt(),
      candidates: [
        for (final c in p['candidates'] as List? ?? const [])
          PositionApplicant(
            id: (c as Map<String, dynamic>)['id'] as String,
            fullName: c['fullName'] as String? ?? '',
            status: c['status'] as String? ?? 'submitted',
            matchScore: (c['matchScore'] as num?)?.toInt(),
            matchVerdict: c['matchVerdict'] as String?,
            matched: c['matched'] == true,
          ),
      ],
    );

PositionMatch positionMatchFromJson(Map<String, dynamic> m) => PositionMatch(
      id: (m['id'] as num).toInt(),
      title: m['title'] as String? ?? '',
      score: (m['matchScore'] as num?)?.toInt(),
      verdict: m['matchVerdict'] as String?,
      strengths: m['matchStrengths'] as String?,
      gaps: m['matchGaps'] as String?,
      matched: m['matched'] == true,
    );
