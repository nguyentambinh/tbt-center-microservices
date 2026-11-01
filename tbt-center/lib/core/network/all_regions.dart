/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-11-01
 */

import 'package:dio/dio.dart';

import '../config/env.dart';
import '../error/app_failure.dart';

/// Dữ liệu của chính người dùng: chỉ nằm ở khu vực của họ
final _personalPath = RegExp(r'/(me|clock|calendar|timesheets)(/|$)');

bool isAllRegionsRequest(RequestOptions options) => options.path.startsWith(Env.allRegionsUrl);

const pickRegionFailure = AppFailure(FailureKind.validation, statusCode: 400, serverCode: 'pick_region');

/// Ghép câu trả lời các khu vực: danh sách gộp lại, mỗi dòng ghi `region`, số
/// tổng cộng dồn; bản ghi lẻ chỉ có ở một nước. Số liệu riêng từng nước thì
/// không cộng được (khác tiền tệ, khác kỳ), trả `null` để app yêu cầu chọn nước
Map<String, dynamic>? mergeRegions(Map<String, Map<String, dynamic>> answers) {
  if (answers.length == 1) return answers.values.first;
  if (!answers.values.every((a) => a['items'] is List)) return null;
  final merged = <String, dynamic>{...answers.values.first};
  merged['items'] = [
    for (final MapEntry(key: region, value: answer) in answers.entries)
      for (final item in answer['items'] as List)
        if (item is Map<String, dynamic>) {...item, 'region': region} else item,
  ];
  if (merged['total'] is int) {
    merged['total'] = answers.values.fold<int>(0, (sum, a) => sum + (a['total'] as int? ?? 0));
  }
  return merged;
}

/// Gửi một GET tới khu vực [region]
Future<Map<String, dynamic>?> _ask(Dio dio, RequestOptions options, String region) async {
  try {
    final copy = options.copyWith(path: options.path.replaceFirst(Env.allRegionsUrl, Env.kongUrl(region)), headers: {...options.headers});
    final response = await dio.fetch<dynamic>(copy);
    return response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : null;
  } on DioException {
    return null;
  }
}

/// Chế độ xem tất cả: gọi song song 6 khu vực rồi ghép; thao tác ghi phải chọn
/// một nước. Nước không trả lời được thì bỏ qua, phần còn lại vẫn hiện
Future<Response<dynamic>> fetchAllRegions(Dio dio, RequestOptions options, {required String homeRegion}) async {
  if (options.method != 'GET') throw DioException(requestOptions: options, error: pickRegionFailure);
  if (_personalPath.hasMatch(options.uri.path)) {
    return dio.fetch<dynamic>(options.copyWith(path: options.path.replaceFirst(Env.allRegionsUrl, Env.kongUrl(homeRegion)), headers: {...options.headers}));
  }
  final answers = await Future.wait(Env.regions.map((region) => _ask(dio, options, region)));
  final found = {
    for (final (i, answer) in answers.indexed)
      Env.regions[i]: ?answer,
  };
  if (found.isEmpty) throw DioException(requestOptions: options, error: const AppFailure(FailureKind.notFound));
  final merged = mergeRegions(found);
  if (merged == null) throw DioException(requestOptions: options, error: pickRegionFailure);
  return Response<dynamic>(requestOptions: options, data: merged, statusCode: 200);
}
