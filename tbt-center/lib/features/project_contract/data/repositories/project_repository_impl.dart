/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._dio, {required String baseUrl}) : _root = '$baseUrl/project-contract';

  final Dio _dio;
  final String _root;

  @override
  Future<List<ProjectSummary>> projects({String? search}) async {
    final data = await _get('/projects', {'limit': 100, if (search != null && search.isNotEmpty) 'q': search});
    return [for (final p in data['items'] as List) _summary(p as Map<String, dynamic>)];
  }

  @override
  Future<ProjectDetail> project(String id) async => _detail(await _get('/projects/${Uri.encodeComponent(id)}'));

  @override
  Future<ProjectDetail> accept(String id) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('$_root/acceptances/${Uri.encodeComponent(id)}');
      return _detail(response.data!);
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  static ProjectDetail _detail(Map<String, dynamic> d) {
    final customer = d['customer'] as Map<String, dynamic>?;
    return ProjectDetail(
      summary: _summary(d),
      customer: customer == null
          ? null
          : Customer(
              name: customer['name'] as String,
              contact: customer['contact'] as String?,
              address: customer['address'] as String?,
            ),
      contracts: [
        for (final c in d['contracts'] as List)
          ProjectContract(
            contractId: (c as Map<String, dynamic>)['contractId'] as String,
            name: c['name'] as String?,
            startDate: _date(c['startDate']),
            expectedEndDate: _date(c['expectedEndDate']),
            endDate: _date(c['endDate']),
          ),
      ],
      notices: [
        for (final n in d['customerNotices'] as List? ?? const [])
          CustomerNotice(
            channel: (n as Map<String, dynamic>)['channel'] as String,
            status: n['status'] as String,
          ),
      ],
      members: [
        for (final m in d['members'] as List)
          ProjectMember(
            employeeId: (m as Map<String, dynamic>)['employeeId'] as String,
            hours: (m['hours'] as num?)?.toDouble() ?? 0,
            projectSalary: _number(m['projectSalary']),
          ),
      ],
    );
  }

  @override
  Future<List<MyProject>> myProjects() async {
    final data = await _get('/me/projects');
    return [
      for (final p in data['items'] as List)
        MyProject(
          projectId: (p as Map<String, dynamic>)['projectId'] as String,
          name: p['name'] as String?,
          hours: (p['hours'] as num?)?.toDouble() ?? 0,
          startDate: _date(p['startDate']),
          endDate: _date(p['endDate']),
        ),
    ];
  }

  Future<Map<String, dynamic>> _get(String path, [Map<String, Object>? query]) async {
    try {
      return (await _dio.get<Map<String, dynamic>>('$_root$path', queryParameters: query)).data!;
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  static ProjectSummary _summary(Map<String, dynamic> p) => ProjectSummary(
        id: p['id'] as String,
        name: p['name'] as String?,
        customerName: p['customerName'] as String?,
        deposit: _number(p['deposit']),
        expectedAcceptance: _number(p['expectedAcceptance']),
        currency: p['currency'] as String? ?? 'USD',
        status: p['status'] as String? ?? 'in_progress',
        acceptedOn: _date(p['acceptedOn']),
        // Danh sách trả số người, trang chi tiết trả hẳn danh sách thành viên.
        members: switch (p['members']) { final num n => n.toInt(), final List l => l.length, _ => 0 },
      );

  static double? _number(Object? value) => value == null ? null : double.tryParse(value.toString());

  static DateTime? _date(Object? value) => value is String ? DateTime.tryParse(value) : null;
}
