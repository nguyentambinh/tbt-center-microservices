/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/candidate.dart';
import '../../domain/repositories/candidate_repository.dart';
import 'job_position_repository.dart';

/// Gọi service `recruitment` qua Kong của khu vực nhận hồ sơ.
class CandidateRepositoryImpl implements CandidateRepository {
  CandidateRepositoryImpl(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  String get _root => '$baseUrl/recruitment';

  @override
  Future<Candidate?> myApplication() async {
    try {
      return candidateFromJson(await _call(() => _dio.get<Map<String, dynamic>>('$_root/me')));
    } on AppFailure catch (e) {
      if (e.serverCode == 'not_applied') return null;
      rethrow;
    }
  }

  @override
  Future<Candidate> saveMyApplication(CandidateInput input) async => candidateFromJson(
        await _call(() => _dio.put<Map<String, dynamic>>('$_root/me', data: {
              'fullName': input.fullName,
              'email': input.email,
              'phone': input.phone,
              'appliedPosition': input.appliedPosition,
              'consentAi': input.consentAi,
              'positionIds': ?input.positionIds,
            })),
      );

  @override
  Future<Candidate> uploadCv(List<int> pdf) async {
    final target = await _call(() => _dio.post<Map<String, dynamic>>('$_root/me/cv/upload-url'));
    if (pdf.length > (target['maxBytes'] as int)) {
      throw const AppFailure(FailureKind.validation, serverCode: 'cv_too_large');
    }
    // URL ký sẵn trỏ thẳng vào kho lưu trữ, không phải Kong nên không gắn token.
    await _call(() => _dio.put<Map<String, dynamic>>(
          target['uploadUrl'] as String,
          data: Stream.fromIterable([pdf]),
          options: Options(
            headers: {Headers.contentLengthHeader: pdf.length, Headers.contentTypeHeader: 'application/pdf'},
            extra: {noCache: true},
          ),
        ));
    return candidateFromJson(
      await _call(() => _dio.post<Map<String, dynamic>>('$_root/me/cv', data: {'objectKey': target['objectKey']})),
    );
  }

  @override
  Future<Uri> cvDownloadUrl(String candidateId) async {
    final data = await _call(() => _dio.get<Map<String, dynamic>>('$_root/candidates/$candidateId/cv'));
    return Uri.parse(data['downloadUrl'] as String);
  }

  @override
  Future<List<Candidate>> candidates({String? status}) async {
    final data = await _call(() => _dio.get<Map<String, dynamic>>(
          '$_root/candidates',
          queryParameters: {'status': ?status},
        ));
    return [for (final c in data['items'] as List) candidateFromJson(c as Map<String, dynamic>)];
  }

  @override
  Future<Candidate> candidate(String id) async =>
      candidateFromJson(await _call(() => _dio.get<Map<String, dynamic>>('$_root/candidates/$id')));

  @override
  Future<Candidate> changeStage(String id, {required String status, String? note}) async => candidateFromJson(
        await _call(() => _dio.post<Map<String, dynamic>>(
              '$_root/candidates/$id/status',
              data: {'status': status, 'note': ?note},
            )),
      );

  @override
  Future<HireResult> hire(String id, {HireOffer? offer}) async {
    final json = await _call(() => _dio.post<Map<String, dynamic>>('$_root/candidates/$id/hire', data: {
          'departmentId': ?offer?.departmentId,
          'baseSalary': ?offer?.baseSalary,
          'currency': ?offer?.currency,
        }));
    return HireResult(
      employeeId: json['employeeId'] as String,
      login: json['login'] as String,
      temporaryPassword: json['temporaryPassword'] as String?,
      salarySet: json['salarySet'] != false,
    );
  }

  @override
  Future<Candidate> reconsider(String id) async =>
      candidateFromJson(await _call(() => _dio.post<Map<String, dynamic>>('$_root/candidates/$id/reconsider', data: const {})));

  @override
  Future<Candidate> scheduleInterview(String id, {required DateTime at, String? location, String? note}) async => candidateFromJson(
        await _call(() => _dio.post<Map<String, dynamic>>('$_root/candidates/$id/interview', data: {
              'scheduledAt': at.toUtc().toIso8601String(),
              'location': ?location,
              'note': ?note,
            })),
      );

  @override
  Future<Candidate> respondInterview(String id, {required String action, DateTime? at, String? note}) async => candidateFromJson(
        await _call(() => _dio.post<Map<String, dynamic>>('$_root/candidates/$id/interview/respond', data: {
              'action': action,
              'scheduledAt': ?at?.toUtc().toIso8601String(),
              'note': ?note,
            })),
      );

  @override
  Future<Candidate> respondMyInterview({required String action, DateTime? at, String? note}) async => candidateFromJson(
        await _call(() => _dio.post<Map<String, dynamic>>('$_root/me/interview', data: {
              'action': action,
              'scheduledAt': ?at?.toUtc().toIso8601String(),
              'note': ?note,
            })),
      );

  @override
  Future<Candidate> uploadMinutes(String id, {required String fileName, required List<int> bytes}) async {
    final target = await _call(() => _dio.post<Map<String, dynamic>>('$_root/candidates/$id/minutes/upload-url', data: {'fileName': fileName}));
    if (bytes.length > (target['maxBytes'] as int)) {
      throw const AppFailure(FailureKind.validation, serverCode: 'file_too_large');
    }
    // URL ký sẵn trỏ thẳng vào kho lưu trữ, không gắn token
    await _call(() => _dio.put<Map<String, dynamic>>(
          target['uploadUrl'] as String,
          data: Stream.fromIterable([bytes]),
          options: Options(headers: {Headers.contentLengthHeader: bytes.length}, extra: {noCache: true}),
        ));
    return candidateFromJson(await _call(() => _dio.post<Map<String, dynamic>>(
          '$_root/candidates/$id/minutes',
          data: {'objectKey': target['objectKey'], 'fileName': fileName},
        )));
  }

  @override
  Future<Uri> minutesUrl(String id) async {
    final data = await _call(() => _dio.get<Map<String, dynamic>>('$_root/candidates/$id/minutes', options: Options(extra: {noCache: true})));
    return Uri.parse(data['downloadUrl'] as String);
  }

  @override
  Future<OfferSuggestion> offerSuggestion(String id, {required String language}) async {
    final json = await _call(() => _dio.get<Map<String, dynamic>>(
          '$_root/candidates/$id/offer',
          queryParameters: {'language': language},
          options: Options(extra: {noCache: true}),
        ));
    return OfferSuggestion(
      departments: [
        for (final d in json['departments'] as List? ?? const [])
          (id: (d as Map<String, dynamic>)['id'] as String, name: d['name'] as String? ?? '', company: d['company'] as String?),
      ],
      departmentId: json['departmentId'] as String?,
      baseSalary: (json['baseSalary'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      reason: json['reason'] as String?,
      source: json['source'] as String? ?? 'rules',
    );
  }

  Future<Map<String, dynamic>> _call(Future<Response<Map<String, dynamic>>> Function() request) async {
    try {
      return (await request()).data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}

Candidate candidateFromJson(Map<String, dynamic> json) => Candidate(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      status: json['status'] as String? ?? 'submitted',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      appliedPosition: json['appliedPosition'] as String?,
      consentAi: json['consentAi'] == true,
      hasCv: json['hasCv'] == true,
      aiSummary: json['aiSummary'] as Map<String, dynamic>?,
      positions: [for (final p in json['positions'] as List? ?? const []) positionMatchFromJson(p as Map<String, dynamic>)],
      viewedAt: DateTime.tryParse('${json['viewedAt']}')?.toLocal(),
      interview: switch (json['interview']) {
        final Map<String, dynamic> i => Interview(
            scheduledAt: DateTime.parse(i['scheduledAt'] as String).toLocal(),
            state: i['state'] as String? ?? 'awaiting_candidate',
            proposedBy: i['proposedBy'] as String? ?? 'hr',
            location: i['location'] as String?,
            note: i['note'] as String?,
            minutesName: i['minutesName'] as String?,
          ),
        _ => null,
      },
      history: [
        for (final h in json['history'] as List? ?? const [])
          StageChange(
            status: (h as Map<String, dynamic>)['status'] as String,
            changedAt: DateTime.parse(h['changedAt'] as String),
            note: h['note'] as String?,
            changedBy: h['changedBy'] as String?,
          ),
      ],
    );
