/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/cache.dart';
import 'package:hr_service/src/data/employee_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /internal/employees: tạo nhân viên mới tuyển
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }

  String? text(String key) {
    final value = body[key];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  final id = text('id');
  final country = text('countryCode');
  final given = text('givenName');
  final email = text('email');
  if (id == null || country == null || given == null || email == null) {
    return apiError(
      400,
      'invalid_employee',
      'id, countryCode, givenName, email are required',
    );
  }

  final employee = await context.read<EmployeeRepository>().hire(
    NewHire(
      id: id,
      countryCode: country,
      familyName: text('familyName') ?? '',
      givenName: given,
      email: email,
      phone: text('phone'),
      positionName: text('position'),
      departmentId: text('departmentId'),
    ),
  );
  // Có nhân viên mới thì danh sách cũ trong cache hết đúng
  await invalidateCache(cache, employeesCache);
  return Response.json(statusCode: 201, body: employee.toJson());
}
