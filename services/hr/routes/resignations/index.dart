/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/resignation_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// Ai xử lý đơn xin thôi việc
const resignationHandlerRoles = {'hr', 'executive'};

/// GET /resignations?status=: nhân viên xem đơn của mình, HR xem cả khu vực.
/// POST {lastDay, reason}: nhân viên gửi, báo trước ít nhất 30 ngày
Future<Response> onRequest(RequestContext context) async {
  final claims = context.read<Claims>();
  final repository = context.read<ResignationRepository>();
  final handler = claims.hasAnyRole(resignationHandlerRoles);
  switch (context.request.method) {
    case HttpMethod.get:
      if (!handler && claims.employeeId == null) {
        return apiError(403, 'no_employee', 'Account is not an employee');
      }
      return Response.json(
        body: {
          'items': await repository.list(
            employeeId: handler ? null : claims.employeeId,
            status: context.request.uri.queryParameters['status'],
          ),
        },
      );
    case HttpMethod.post:
      final employee = claims.employeeId;
      if (employee == null) {
        return apiError(403, 'no_employee', 'Account is not an employee');
      }
      final Map<String, dynamic> body;
      try {
        body = await context.request.json() as Map<String, dynamic>;
      } on Object {
        return apiError(400, 'invalid_json', 'Body must be a JSON object');
      }
      final lastDay = DateTime.tryParse('${body['lastDay']}');
      final reason = (body['reason'] as String?)?.trim() ?? '';
      if (lastDay == null || reason.isEmpty) {
        return apiError(400, 'invalid_resignation', 'lastDay, reason needed');
      }
      try {
        return Response.json(
          statusCode: 201,
          body: await repository.create(
            employee,
            lastDay: lastDay,
            reason: reason,
          ),
        );
      } on ResignationViolation catch (e) {
        return apiError(
          e.code == 'notice_too_short' ? 400 : 409,
          e.code,
          e.message,
        );
      }
    case HttpMethod.put ||
        HttpMethod.patch ||
        HttpMethod.delete ||
        HttpMethod.head ||
        HttpMethod.options:
      return apiError(405, 'method_not_allowed', 'GET, POST only');
  }
}
