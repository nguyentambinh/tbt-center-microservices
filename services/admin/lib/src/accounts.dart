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
  return null;
}
