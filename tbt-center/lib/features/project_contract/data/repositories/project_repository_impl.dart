/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../../../../core/error/app_failure.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._dio, {required String baseUrl}) : _root = '$baseUrl/project-contract';

  final Dio _dio;
  final String _root;

  @override
  Future<List<ProjectSummary>> projects({String? search, int? tier, DateTimeRange? range}) async {
    String? day(DateTime? d) => d?.toIso8601String().substring(0, 10);
    final data = await _get('/projects', {
      'limit': 100,
      if (search != null && search.isNotEmpty) 'q': search,
      'tier': ?tier,
      'from': ?day(range?.start),
      'to': ?day(range?.end),
    });
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

  @override
  Future<List<ProjectProposal>> proposals({String? status}) async {
    final data = await _get('/project-proposals', {'status': ?status});
    return [for (final p in data['items'] as List) _proposal(p as Map<String, dynamic>)];
  }

  @override
  Future<ProjectProposal> proposal(int id) async => _proposal(await _get('/project-proposals/$id'));

  @override
  Future<String> uploadFile({required String kind, required String fileName, required List<int> bytes}) async {
    final target = await _post('/project-files/upload-url', {'kind': kind, 'fileName': fileName});
    if (bytes.length > (target['maxBytes'] as int)) {
      throw const AppFailure(FailureKind.validation, serverCode: 'file_too_large');
    }
    try {
      // URL ký sẵn trỏ thẳng vào kho lưu trữ, không gắn token
      await _dio.put<void>(
        target['uploadUrl'] as String,
        data: Stream.fromIterable([bytes]),
        options: Options(headers: {Headers.contentLengthHeader: bytes.length}, extra: {noCache: true}),
      );
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
    return target['objectKey'] as String;
  }

  @override
  Future<({ProposalData fields, String source})> extract({required String objectKey, required String fileName}) async {
    final data = await _post('/project-proposals/extract', {'objectKey': objectKey, 'fileName': fileName});
    return (fields: ProposalData.fromJson(data['fields'] as Map<String, dynamic>? ?? const {}), source: data['source'] as String? ?? 'manual');
  }

  @override
  Future<MemberSuggestion> suggestMembers(ProposalData data, {required String language}) async {
    final json = await _post('/project-proposals/suggest-members', {'data': data.toJson(), 'language': language});
    return MemberSuggestion(
      tier: json['tier'] as int? ?? 1,
      minMembers: json['minMembers'] as int? ?? 1,
      memberIds: [for (final id in json['memberIds'] as List? ?? const []) '$id'],
      reason: json['reason'] as String?,
      source: json['source'] as String? ?? 'rules',
      employees: [
        for (final e in json['employees'] as List? ?? const [])
          StaffOption(
            id: (e as Map<String, dynamic>)['id'] as String,
            name: e['name'] as String? ?? e['id'] as String,
            position: e['position'] as String?,
            activeProjects: e['activeProjects'] as int? ?? 0,
          ),
      ],
    );
  }

  @override
  Future<ProjectProposal> propose(ProposalData data, {String? contractKey, String? contractName, String? imageKey}) async => _proposal(
        await _post('/project-proposals', {
          'data': data.toJson(),
          'contractKey': ?contractKey,
          'contractName': ?contractName,
          'imageKey': ?imageKey,
        }),
      );

  @override
  Future<ProjectProposal> respond(int id, {required String action, ProposalData? data, String? note}) async => _proposal(
        await _post('/project-proposals/$id/respond', {'action': action, 'data': ?data?.toJson(), 'note': ?note}),
      );

  Future<Map<String, dynamic>> _post(String path, Object body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('$_root$path', data: body);
      return response.data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  static ProjectProposal _proposal(Map<String, dynamic> p) => ProjectProposal(
        id: p['id'] as int,
        status: p['status'] as String,
        data: ProposalData.fromJson(p['data'] as Map<String, dynamic>? ?? const {}),
        version: p['version'] as int? ?? 1,
        createdBy: p['createdBy'] as String? ?? '',
        updatedAt: DateTime.tryParse('${p['updatedAt']}')?.toLocal() ?? DateTime.now(),
        projectId: p['projectId'] as String?,
        contractName: p['contractName'] as String?,
        contractUrl: p['contractUrl'] as String?,
        imageUrl: p['imageUrl'] as String?,
        events: [
          for (final e in p['events'] as List? ?? const [])
            ProposalEvent(
              action: (e as Map<String, dynamic>)['action'] as String,
              actor: e['actor'] as String? ?? '',
              at: DateTime.parse(e['at'] as String).toLocal(),
              note: e['note'] as String?,
            ),
        ],
      );

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
            type: c['type'] as String?,
            summary: c['summary'] as String?,
            fileUrl: c['fileUrl'] as String?,
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
            employeeId: (m as Map<String, dynamic>)['employeeId'] as String?,
            name: m['name'] as String?,
            isMe: m['isMe'] == true,
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
          imageUrl: p['imageUrl'] as String?,
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
        imageUrl: p['imageUrl'] as String?,
        // Danh sách trả số người, trang chi tiết trả hẳn danh sách thành viên.
        members: switch (p['members']) { final num n => n.toInt(), final List l => l.length, _ => 0 },
        tier: p['tier'] as int? ?? 1,
        progress: (p['progress'] as num?)?.toDouble() ?? 0,
        warning: p['warning'] as String? ?? 'normal',
        startDate: _date(p['startDate']),
        endDate: _date(p['endDate']),
        valueUsd: _number(p['valueUsd']),
      );

  static double? _number(Object? value) => value == null ? null : double.tryParse(value.toString());

  static DateTime? _date(Object? value) => value is String ? DateTime.tryParse(value) : null;
}
