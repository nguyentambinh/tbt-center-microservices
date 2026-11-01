/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:tbt_common/tbt_common.dart';

/// Vai trò quản trị một nước được gán, gỡ
const regionAssignableRoles = {'employee', 'hr', 'finance', 'auditor'};

/// Quản trị tập đoàn gán thêm được vai trò quản lý và cấp tập đoàn
const groupAssignableRoles = {
  ...regionAssignableRoles,
  'executive',
  'admin',
  groupRole,
};

/// Lý do không cho đổi tài khoản; `null` là được
String? accountChangeRefusal({
  required Claims actor,
  required KeycloakUser target,
  required String serviceRegion,
  Set<String> add = const {},
  Set<String> remove = const {},
}) {
  if (target.id == actor.subject) return 'self_change';
  if (!actor.isGroup && target.region != serviceRegion) return 'other_region';
  final allowed = actor.isGroup ? groupAssignableRoles : regionAssignableRoles;
  if (!{...add, ...remove}.every(allowed.contains)) return 'role_not_allowed';
  // Thăng lên cấp tập đoàn là một chiều
  if (remove.contains(groupRole)) return 'group_demotion';
  return null;
}

/// Lý do không cho vào thay tài khoản; `null` là được. Chỉ vào được cấp dưới:
/// quản trị nước vào nhân sự trong nước, quản trị tập đoàn vào thêm văn phòng
/// và quản trị từng nước
String? impersonationRefusal({
  required Claims actor,
  required KeycloakUser target,
  required List<String> targetRoles,
  required String serviceRegion,
}) {
  if (target.id == actor.subject) return 'self_change';
  if (!target.enabled) return 'account_disabled';
  if (!actor.isGroup && target.region != serviceRegion) return 'other_region';
  if (targetRoles.contains(groupRole)) return 'higher_account';
  if (!actor.isGroup &&
      (targetRoles.contains('admin') || targetRoles.contains('executive'))) {
    return 'higher_account';
  }
  return null;
}
