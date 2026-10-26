/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dio/dio.dart';

import '../../../core/error/app_failure.dart';
import '../domain/organization.dart';

/// Phòng ban, xếp hạng, đề cử, bảo lưu hồ sơ qua service hr của khu vực
abstract interface class OrganizationRepository {
  Future<List<Department>> departments();
  Future<DepartmentDetail> department(String id);
  Future<Department> createDepartment(String name, String companyId);
  Future<void> dissolve(String id, {required String reasonCode, String? note, String? mergeInto});
  Future<({List<String> moved, List<String> failed})> transfer(String departmentId, List<String> employeeIds);
  Future<void> setHead(String departmentId, String employeeId);
  Future<List<OrgPerson>> unassigned();
  Future<PlacementSuggestion> suggest({required String language});
  Future<List<OrgPerson>> rankings({int months = 3, String? departmentId});
  Future<EmployeeFilters> filters();

  /// Dự án nhân viên đang tham gia, để cảnh báo trước khi bảo lưu
  Future<List<Map<String, dynamic>>> projectsOf(String employeeId);
  Future<int> archive(String employeeId, String reason);
  Future<void> restore(String employeeId);

  Future<List<Nomination>> nominations({String? status});

  /// Cây tổ chức: phòng ban, trưởng phòng, người theo cấp chức vụ
  Future<OrgTree> orgTree();

  /// Chức vụ cấp cao hơn chức vụ hiện tại của nhân viên, để đề cử thăng chức
  Future<List<({String id, String name, int level})>> positionsAbove(String employeeId);
  Future<void> nominate({required String employeeId, required String proposedPosition, required double raisePercent, required String reason, String? groupRole});
  Future<bool> decideNomination(int id, {required bool approve, String? note});
}

class OrganizationRepositoryImpl implements OrganizationRepository {
  OrganizationRepositoryImpl(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  @override
  Future<OrgTree> orgTree() async => OrgTree.fromJson(await _call('GET', '/hr/org-tree'));

  @override
  Future<List<({String id, String name, int level})>> positionsAbove(String employeeId) async => [
        for (final p in (await _call('GET', '/hr/org-tree/positions-above/${Uri.encodeComponent(employeeId)}'))['items'] as List)
          (id: (p as Map<String, dynamic>)['id'] as String, name: p['name'] as String, level: (p['level'] as num).toInt()),
      ];

  @override
  Future<List<Department>> departments() async =>
      [for (final d in (await _call('GET', '/hr/departments'))['items'] as List) Department.fromJson(d as Map<String, dynamic>)];

  @override
  Future<DepartmentDetail> department(String id) async =>
      DepartmentDetail.fromJson(await _call('GET', '/hr/departments/${Uri.encodeComponent(id)}'));

  @override
  Future<Department> createDepartment(String name, String companyId) async =>
      Department.fromJson(await _call('POST', '/hr/departments', {'name': name, 'companyId': companyId}));

  @override
  Future<void> dissolve(String id, {required String reasonCode, String? note, String? mergeInto}) =>
      _call('POST', '/hr/departments/${Uri.encodeComponent(id)}/dissolve', {'reasonCode': reasonCode, 'note': note, 'mergeInto': mergeInto});

  @override
  Future<({List<String> moved, List<String> failed})> transfer(String departmentId, List<String> employeeIds) async {
    final data = await _call('POST', '/hr/departments/${Uri.encodeComponent(departmentId)}/members', {'employeeIds': employeeIds});
    return (
      moved: [for (final m in data['moved'] as List? ?? const []) m as String],
      failed: [for (final f in data['failed'] as List? ?? const []) (f as Map<String, dynamic>)['employeeId'] as String],
    );
  }

  @override
  Future<void> setHead(String departmentId, String employeeId) =>
      _call('POST', '/hr/departments/${Uri.encodeComponent(departmentId)}/head', {'employeeId': employeeId});

  @override
  Future<List<OrgPerson>> unassigned() async => _people(await _call('GET', '/hr/departments/unassigned'));

  @override
  Future<PlacementSuggestion> suggest({required String language}) async =>
      PlacementSuggestion.fromJson(await _call('POST', '/hr/departments/suggest', {'language': language}));

  @override
  Future<List<OrgPerson>> rankings({int months = 3, String? departmentId}) async =>
      _people(await _call('GET', '/hr/rankings', null, {'months': months, 'departmentId': ?departmentId}));

  @override
  Future<EmployeeFilters> filters() async => EmployeeFilters.fromJson(await _call('GET', '/hr/employees/filters'));

  @override
  Future<List<Map<String, dynamic>>> projectsOf(String employeeId) async =>
      ((await _call('GET', '/hr/archives/${Uri.encodeComponent(employeeId)}'))['projects'] as List).cast<Map<String, dynamic>>();

  @override
  Future<int> archive(String employeeId, String reason) async =>
      (await _call('POST', '/hr/archives/${Uri.encodeComponent(employeeId)}', {'reason': reason}))['projectsLeft'] as int? ?? 0;

  @override
  Future<void> restore(String employeeId) => _call('DELETE', '/hr/archives/${Uri.encodeComponent(employeeId)}');

  @override
  Future<List<Nomination>> nominations({String? status}) async => [
        for (final n in (await _call('GET', '/hr/nominations', null, {'status': ?status}))['items'] as List)
          Nomination.fromJson(n as Map<String, dynamic>),
      ];

  @override
  Future<void> nominate({required String employeeId, required String proposedPosition, required double raisePercent, required String reason, String? groupRole}) =>
      _call('POST', '/hr/nominations', {'employeeId': employeeId, 'proposedPosition': proposedPosition, 'raisePercent': raisePercent, 'reason': reason, 'groupRole': ?groupRole});

  @override
  Future<bool> decideNomination(int id, {required bool approve, String? note}) async =>
      (await _call('POST', '/hr/nominations/$id/decision', {'approve': approve, 'note': note}))['salaryRaised'] != false;

  static List<OrgPerson> _people(Map<String, dynamic> data) =>
      [for (final p in data['items'] as List) OrgPerson.fromJson(p as Map<String, dynamic>)];

  Future<Map<String, dynamic>> _call(String method, String path, [Object? body, Map<String, Object>? query]) async {
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        '$baseUrl$path',
        data: body,
        queryParameters: query,
        options: Options(method: method),
      );
      return response.data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}
