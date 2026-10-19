/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:payroll_service/src/payroll_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /payslips?employee=  phiếu lương, lương cơ bản, thưởng phạt (R37).
/// Mặc định của chính mình; tài chính, HR, quản lý xem được người khác.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final claims = context.read<Claims>();
  final requested = context.request.uri.queryParameters['employee'];
  final own = claims.employeeId;

  final String employee;
  if (requested == null || requested == own) {
    if (own == null) {
      return apiError(
        403,
        'no_employee',
        'Account is not linked to an employee',
      );
    }
    employee = own;
  } else if (claims.hasAnyRole(payrollViewerRoles)) {
    employee = requested;
  } else {
    return apiError(403, 'forbidden', 'You can only view your own payslips');
  }

  final repository = context.read<PayrollRepository>();
  return Response.json(
    body: {
      'employeeId': employee,
      'salary': await repository.salary(employee),
      'payslips': await repository.payslips(employee),
      'bonusesPenalties': await repository.bonusesPenalties(employee),
    },
  );
}
