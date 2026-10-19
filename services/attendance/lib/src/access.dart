/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// Nhân viên chỉ xem được của mình; quản lý xem được người khác trong khu vực.
/// Trả về mã nhân viên được phép xem, hoặc Response lỗi.
Object resolveEmployee(RequestContext context, String? requested) {
  final claims = context.read<Claims>();
  final own = claims.employeeId;
  final isManager = claims.hasAnyRole(managerRoles);

  if (requested == null || requested == own) {
    return own ??
        apiError(403, 'no_employee', 'Account is not linked to an employee');
  }
  if (!isManager) {
    return apiError(403, 'forbidden', 'You can only view your own data');
  }
  return requested;
}

Response ruleError(LeaveRuleViolation e) {
  final status = switch (e.code) {
    'overlap' || 'already_decided' || 'period_locked' => 409,
    'self_approval' => 403,
    _ => 400,
  };
  return apiError(status, e.code, e.message);
}
