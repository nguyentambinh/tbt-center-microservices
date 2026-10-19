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
import '../../domain/entities/audit.dart';
import '../../domain/repositories/audit_repository.dart';

/// Sổ kiểm toán nằm ở Hub, gọi qua Kong của khu vực để được kiểm token.
class AuditRepositoryImpl implements AuditRepository {
  AuditRepositoryImpl(this._dio, {required String baseUrl}) : _root = '$baseUrl/audit/audit-log';

  final Dio _dio;
  final String _root;

  // Kiểm toán phải thấy số liệu thật lúc này, không dùng bản lưu cũ khi mất mạng.
  static final _live = Options(extra: {noCache: true});

  @override
  Future<List<AuditEvent>> events({String? region}) async {
    final d = await _get<Map<String, dynamic>>(_root, {'limit': 200, 'region': ?region});
    return [
      for (final e in d['items'] as List)
        AuditEvent(
          id: ((e as Map<String, dynamic>)['id'] as num).toInt(),
          region: e['region'] as String,
          sourceService: e['sourceService'] as String,
          eventType: e['eventType'] as String,
          aggregateId: e['aggregateId'] as String,
          occurredAt: DateTime.parse(e['occurredAt'] as String).toLocal(),
          hash: e['hash'] as String,
        ),
    ];
  }

  @override
  Future<ChainCheck> verify() async {
    final d = await _get<Map<String, dynamic>>('$_root/verify');
    return ChainCheck(checked: (d['checked'] as num).toInt(), brokenAt: (d['brokenAt'] as num?)?.toInt());
  }

  @override
  Future<AuditExport> export({String? region}) async {
    try {
      final response = await _dio.get<String>(
        '$_root/export',
        queryParameters: {'region': ?region},
        options: Options(responseType: ResponseType.plain, extra: {noCache: true}),
      );
      return AuditExport(
        rowCount: int.tryParse(response.headers.value('x-row-count') ?? '') ?? 0,
        checksum: response.headers.value('x-checksum-sha256') ?? '',
        csv: response.data ?? '',
      );
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  @override
  Future<List<AccessEntry>> accessLog() async {
    final d = await _get<Map<String, dynamic>>('$_root/access');
    return [
      for (final a in d['items'] as List)
        AccessEntry(
          username: (a as Map<String, dynamic>)['username'] as String,
          action: a['action'] as String,
          accessedAt: DateTime.parse(a['accessedAt'] as String).toLocal(),
          rowCount: (a['rowCount'] as num?)?.toInt(),
          checksum: a['checksum'] as String?,
        ),
    ];
  }

  Future<T> _get<T>(String url, [Map<String, Object>? query]) async {
    try {
      return (await _dio.get<T>(url, queryParameters: query, options: _live)).data as T;
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}
