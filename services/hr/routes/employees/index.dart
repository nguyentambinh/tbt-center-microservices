/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/employee_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /employees?q=&department=&position=&company=&status=active&page=1&size=30
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(
      HttpStatus.methodNotAllowed,
      'method_not_allowed',
      'GET only',
    );
  }

  final query = context.request.uri.queryParameters;
  final page = int.tryParse(query['page'] ?? '') ?? 1;
  final size = int.tryParse(query['size'] ?? '') ?? 30;
  if (page < 1 || size < 1 || size > 100) {
    return apiError(
      HttpStatus.badRequest,
      'invalid_paging',
      'page >= 1, 1 <= size <= 100',
    );
  }

  final result = await context.read<EmployeeRepository>().search(
    query: query['q']?.trim(),
    departmentId: query['department'],
    positionId: query['position'],
    companyId: query['company'],
    status: query['status'] == 'archived' ? 'archived' : 'active',
    page: page,
    size: size,
  );
  return Response.json(body: result.toJson((e) => e.toJson()));
}
