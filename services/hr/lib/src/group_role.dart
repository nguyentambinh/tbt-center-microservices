/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:io';

import 'package:tbt_common/tbt_common.dart';

/// Cấp vai trò tập đoàn cho tài khoản gắn với nhân viên; `false` nếu chưa có
/// tài khoản hoặc Keycloak lỗi (chức vụ vẫn đã đổi, cấp lại được ở màn
/// quản trị)
Future<bool> grantGroupRole(
  KeycloakUsers keycloak,
  String employeeId,
  String role,
) async {
  try {
    final user = await keycloak.byEmployeeId(employeeId);
    if (user == null) return false;
    await keycloak.addRoles(user.id, [role, groupRole]);
    return true;
  } on KeycloakException catch (e) {
    stderr.writeln('Không cấp được vai trò tập đoàn: $e');
    return false;
  }
}
