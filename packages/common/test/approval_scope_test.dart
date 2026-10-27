/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-27
 */

import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

Claims _as(List<String> roles) => Claims({
  'realm_access': {'roles': roles},
});

void main() {
  test('nhân viên thường không lưu vai trò, ai có quyền đều duyệt được', () {
    expect(requesterRolesOf(_as(['employee'])), isNull);
    expect(isPeerApprover(null, _as(['hr'])), isFalse);
  });

  test('đơn của HR nước: HR cùng nước không duyệt, cấp trên duyệt', () {
    final roles = requesterRolesOf(_as(['employee', 'hr']));
    expect(roles, 'hr');
    expect(isPeerApprover(roles, _as(['hr'])), isTrue);
    expect(isPeerApprover(roles, _as(['hr', 'group'])), isFalse);
    expect(isPeerApprover(roles, _as(['executive'])), isFalse);
  });

  test('đơn của finance chỉ cấp trên hoặc bộ phận khác duyệt', () {
    final roles = requesterRolesOf(_as(['finance']));
    expect(isPeerApprover(roles, _as(['finance'])), isTrue);
    expect(isPeerApprover(roles, _as(['finance', 'group'])), isFalse);
    expect(isPeerApprover(roles, _as(['hr'])), isFalse);
  });

  test('văn phòng quản lý nước: HR hoặc văn phòng tập đoàn duyệt', () {
    final roles = requesterRolesOf(_as(['executive']));
    expect(isPeerApprover(roles, _as(['executive'])), isTrue);
    expect(isPeerApprover(roles, _as(['hr'])), isFalse);
    expect(isPeerApprover(roles, _as(['executive', 'group'])), isFalse);
  });

  test('đơn cấp tập đoàn không để người cùng vai trò cấp tập đoàn duyệt', () {
    final roles = requesterRolesOf(_as(['hr', 'group']));
    expect(roles, 'hr,group');
    expect(isPeerApprover(roles, _as(['hr', 'group'])), isTrue);
    expect(isPeerApprover(roles, _as(['hr'])), isTrue);
    expect(isPeerApprover(roles, _as(['executive', 'group'])), isFalse);
  });
}
