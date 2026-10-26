/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../core/error/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../domain/resignation.dart';

/// Đơn xin thôi việc ở service hr của khu vực
class ResignationRepository {
  ResignationRepository(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  String get _root => '$baseUrl/hr/resignations';

  Future<List<Resignation>> list({String? status}) async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>(_root, queryParameters: {'status': ?status}));
    return [for (final r in d['items'] as List) _resignation(r as Map<String, dynamic>)];
  }

  /// Tải bản đơn lên kho của khu vực (URL ký sẵn, không gắn token) rồi gửi đơn
  Future<Resignation> submit({
    required DateTime lastDay,
    required String reason,
    required ({String name, List<int> bytes}) letter,
    required String language,
  }) async {
    final target = await _call(() => _dio.post<Map<String, dynamic>>('$_root/letter-url', data: {'fileName': letter.name}));
    if (letter.bytes.length > (target['maxBytes'] as int)) {
      throw const AppFailure(FailureKind.validation, serverCode: 'file_too_large');
    }
    try {
      await _dio.put<void>(
        target['uploadUrl'] as String,
        data: Stream.fromIterable([letter.bytes]),
        options: Options(headers: {Headers.contentLengthHeader: letter.bytes.length}, extra: {noCache: true}),
      );
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
    return _resignation(await _call(() => _dio.post<Map<String, dynamic>>(_root, data: {
          'lastDay': DateFormat('yyyy-MM-dd').format(lastDay),
          'reason': reason,
          'letterKey': target['objectKey'],
          'letterName': letter.name,
          'language': language,
        })));
  }

  /// URL tạm để mở bản đơn gốc
  Future<Uri> letterUrl(int id) async => Uri.parse((await _call(() => _dio.get<Map<String, dynamic>>('$_root/$id/letter')))['url'] as String);

  /// approve, reject, withdraw, complete
  Future<Resignation> respond(int id, {required String action, String? note}) async =>
      _resignation(await _call(() => _dio.post<Map<String, dynamic>>('$_root/$id/respond', data: {'action': action, 'note': ?note})));

  Future<Map<String, dynamic>> _call(Future<Response<Map<String, dynamic>>> Function() send) async {
    try {
      return (await send()).data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  static Resignation _resignation(Map<String, dynamic> r) => Resignation(
        id: r['id'] as int,
        employeeId: r['employeeId'] as String,
        name: r['name'] as String? ?? r['employeeId'] as String,
        lastDay: DateTime.parse(r['lastDay'] as String),
        reason: r['reason'] as String? ?? '',
        status: r['status'] as String,
        createdAt: DateTime.tryParse('${r['createdAt']}')?.toLocal() ?? DateTime.now(),
        decidedBy: r['decidedBy'] as String?,
        note: r['note'] as String?,
        letterName: r['letterName'] as String?,
        aiAnalysis: r['aiAnalysis'] as Map<String, dynamic>?,
      );
}
