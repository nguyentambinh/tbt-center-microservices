/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:payroll_service/src/raise_requests.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /raise-requests?status=: nhân viên xem đề xuất của mình; HR, quản trị,
/// Ban điều hành xem cả khu vực. POST {requested, reason}: nhân viên gửi
Future<Response> onRequest(RequestContext context) async {
  final claims = context.read<Claims>();
  final repository = context.read<RaiseRequestRepository>();
  final reviewer = claims.hasAnyRole({'hr', ...raiseApproverRoles});
  switch (context.request.method) {
    case HttpMethod.get:
      if (!reviewer && claims.employeeId == null) {
        return apiError(403, 'no_employee', 'Account is not an employee');
      }
      return Response.json(
        body: {
          'items': await repository.list(
            employeeId: reviewer ? null : claims.employeeId,
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
      final requested = (body['requested'] as num?)?.toDouble();
      final reason = (body['reason'] as String?)?.trim() ?? '';
      if (requested == null || reason.isEmpty) {
        return apiError(400, 'invalid_raise', 'requested and reason required');
      }
      try {
        return Response.json(
          statusCode: 201,
          body: await repository.create(
            employee,
            requested: requested,
            reason: reason,
            skipHr: claims.hasAnyRole(const {'hr'}),
          ),
        );
      } on RaiseRuleViolation catch (e) {
        return apiError(e.code == 'not_higher' ? 400 : 409, e.code, e.message);
      }
    case HttpMethod.put ||
        HttpMethod.patch ||
        HttpMethod.delete ||
        HttpMethod.head ||
        HttpMethod.options:
      return apiError(405, 'method_not_allowed', 'GET, POST only');
  }
}
