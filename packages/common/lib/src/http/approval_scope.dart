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

/// Người duyệt cùng vai trò, cùng cấp (hoặc thấp hơn) với người gửi thì phải
/// để cấp trên duyệt: cấp tập đoàn duyệt được đơn của cấp nước, không ngược lại
bool isPeerApprover(String? requesterRoles, Claims decider) {
  if (requesterRoles == null || requesterRoles.isEmpty) return false;
  final roles = requesterRoles.split(',');
  if (decider.isGroup && !roles.contains(groupRole)) return false;
  return roles.any((r) => r != groupRole && decider.hasAnyRole({r}));
}
