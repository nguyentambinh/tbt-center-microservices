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

/// POST /raise-requests/{id}/respond  {action, amount, note}
/// nhân viên: edit, withdraw; HR: forward, return, reject; quản trị, Ban điều
/// hành: approve, return, reject. Mức đề xuất chỉ giữ hoặc tăng
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final action = body['action'];
  final number = int.tryParse(id);
  if (action is! String || number == null) {
    return apiError(400, 'invalid_action', 'Unknown action');
  }
  // Ai làm hành động nào: duyệt là việc của quản trị, Ban điều hành
  final side = switch (action) {
    'approve' =>
      claims.hasAnyRole(raiseApproverRoles) ? RaiseSide.approver : null,
    'forward' => claims.hasAnyRole(const {'hr'}) ? RaiseSide.hr : null,
    'edit' || 'withdraw' => RaiseSide.employee,
    'return' || 'reject' =>
      claims.hasAnyRole(raiseApproverRoles)
          ? RaiseSide.approver
          : (claims.hasAnyRole(const {'hr'}) ? RaiseSide.hr : null),
    _ => null,
  };
  if (side == null) return apiError(403, 'forbidden', 'Not allowed to $action');
  try {
    final updated = await context.read<RaiseRequestRepository>().respond(
      number,
      side: side,
      action: action,
      by: claims.username,
      employeeId: claims.employeeId,
      amount: (body['amount'] as num?)?.toDouble(),
      note: (body['note'] as String?)?.trim(),
    );
    if (updated == null) {
      return apiError(404, 'not_found', 'No raise request $id');
    }
    return Response.json(body: updated);
  } on RaiseRuleViolation catch (e) {
    return apiError(
      switch (e.code) {
        'not_found' => 404,
        'amount_lowered' => 400,
        _ => 409,
      },
      e.code,
      e.message,
    );
  }
}
