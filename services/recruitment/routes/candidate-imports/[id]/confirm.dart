/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/imports/import_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /candidate-imports/{id}/confirm
///   {"all": true}            xác nhận mọi dòng hợp lệ còn chờ
///   {"rowIds": ["...", ...]} chỉ xác nhận các dòng đã tick
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(recruiterRoles)) {
    return apiError(403, 'forbidden', 'HR only');
  }

  final List<String>? rowIds;
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    rowIds = body['all'] == true
        ? null
        : [for (final r in body['rowIds'] as List) r as String];
  } on Object {
    return apiError(
      400,
      'invalid_json',
      'Body must be {"all": true} or {"rowIds": [...]}',
    );
  }
  if (rowIds != null && rowIds.isEmpty) {
    return apiError(400, 'no_rows', 'Pick at least one row');
  }

  final result = await context.read<ImportRepository>().confirm(
    id,
    // Hồ sơ nhập ở khu vực nào mang mã nước của khu vực đó.
    countryCode: Platform.environment['COUNTRY_CODE'] ?? 'VN',
    confirmedBy: claims.username,
    rowIds: rowIds,
  );
  if (result == null) return apiError(404, 'not_found', 'No import $id');
  return Response.json(body: result);
}
