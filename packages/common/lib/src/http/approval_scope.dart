/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-27
 */

import 'claims.dart';

/// Vai trò có quyền duyệt; người gửi mang vai trò nào thì người cùng vai trò
/// cùng cấp không duyệt đơn đó
const approvalRoles = ['hr', 'finance', 'executive'];

/// Vai trò của người gửi lưu kèm đơn, ví dụ `hr` hoặc `executive,group`;
/// `null` với nhân viên thường
String? requesterRolesOf(Claims claims) {
  final roles = [
    for (final r in approvalRoles)
      if (claims.hasAnyRole({r})) r,
  ];
  if (roles.isEmpty) return null;
  return [...roles, if (claims.isGroup) groupRole].join(',');
}

/// `true` nếu [decider] không được duyệt đơn của người có [requesterRoles].
/// Đơn của hr, finance do văn phòng quản lý hoặc cấp tập đoàn duyệt; đơn của
/// executive do hr hoặc cấp tập đoàn duyệt; cấp tập đoàn chỉ cấp tập đoàn duyệt
bool isPeerApprover(String? requesterRoles, Claims decider) {
  if (requesterRoles == null || requesterRoles.isEmpty) return false;
  final roles = requesterRoles.split(',');
  final fromGroup = roles.contains(groupRole);
  if (fromGroup && !decider.isGroup) return true;
  if (!fromGroup && decider.isGroup) return false;
  if (roles.contains('executive')) return decider.hasAnyRole({'executive'});
  return !decider.hasAnyRole({'executive'});
}
