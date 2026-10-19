/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/candidate_import.dart';
import '../../domain/repositories/candidate_import_repository.dart';

class CandidateImportRepositoryImpl implements CandidateImportRepository {
  CandidateImportRepositoryImpl(this._dio, {required String baseUrl}) : _root = '$baseUrl/recruitment/candidate-imports';

  final Dio _dio;
  final String _root;

  @override
  Future<CandidateImport> upload(String fileName, List<int> bytes) async => _import(await _call(
        () => _dio.post<Map<String, dynamic>>(_root, data: {'fileName': fileName, 'content': base64Encode(bytes)}),
      ));

  @override
  Future<CandidateImport> find(String id) async =>
      _import(await _call(() => _dio.get<Map<String, dynamic>>('$_root/${Uri.encodeComponent(id)}')));

  @override
  Future<({int accepted, CandidateImport draft})> confirm(String id, {List<String>? rowIds}) async {
    final d = await _call(() => _dio.post<Map<String, dynamic>>(
          '$_root/${Uri.encodeComponent(id)}/confirm',
          data: rowIds == null ? {'all': true} : {'rowIds': rowIds},
        ));
    return (accepted: (d['accepted'] as num).toInt(), draft: _import(d['import'] as Map<String, dynamic>));
  }

  Future<Map<String, dynamic>> _call(Future<Response<Map<String, dynamic>>> Function() request) async {
    try {
      return (await request()).data!;
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  static CandidateImport _import(Map<String, dynamic> d) => CandidateImport(
        id: d['id'] as String,
        fileName: d['sourceRef'] as String? ?? '',
        rows: [
          for (final r in d['rows'] as List)
            ImportRow(
              id: (r as Map<String, dynamic>)['id'] as String,
              rowNumber: (r['rowNumber'] as num).toInt(),
              fullName: r['fullName'] as String? ?? '',
              email: r['email'] as String?,
              phone: r['phone'] as String?,
              appliedPosition: r['appliedPosition'] as String?,
              isUpdate: r['action'] == 'update',
              status: r['status'] as String,
              error: r['error'] as String?,
            ),
        ],
      );
}
