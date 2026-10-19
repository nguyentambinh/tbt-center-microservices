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
  Future<HireResult> hire(String id) async {
    final json = await _call(() => _dio.post<Map<String, dynamic>>('$_root/candidates/$id/hire'));
    return HireResult(
      employeeId: json['employeeId'] as String,
      login: json['login'] as String,
      temporaryPassword: json['temporaryPassword'] as String?,
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
