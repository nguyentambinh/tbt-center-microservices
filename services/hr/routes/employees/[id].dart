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

/// GET /employees/{id}
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(
      HttpStatus.methodNotAllowed,
      'method_not_allowed',
      'GET only',
    );
  }

  final employee = await context.read<EmployeeRepository>().find(id);
  if (employee == null) {
    return apiError(HttpStatus.notFound, 'not_found', 'Employee $id not found');
  }
  return Response.json(body: employee.toJson());
}
