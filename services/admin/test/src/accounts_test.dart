/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:admin_service/src/accounts.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

Claims _admin({bool group = false}) => Claims({
  'sub': 'admin-1',
  'region': 'vn',
  'realm_access': {
    'roles': ['admin', if (group) 'group'],
  },
});

const _hrVn = KeycloakUser(
  id: 'u-hr',
  username: 'hr.vn',
  enabled: true,
  attributes: {'region': 'vn'},
);
const _hrDe = KeycloakUser(
  id: 'u-de',
  username: 'hr.de',
  enabled: true,
  attributes: {'region': 'de'},
);

void main() {
  test('quản trị một nước gán được vai trò nghiệp vụ trong nước mình', () {
    expect(
      accountChangeRefusal(
        actor: _admin(),
        target: _hrVn,
        serviceRegion: 'vn',
        add: {'finance'},
      ),
      isNull,
    );
  });

  test('quản trị một nước không gán vai trò quản lý, không sửa nước khác', () {
    expect(
      accountChangeRefusal(
        actor: _admin(),
        target: _hrVn,
        serviceRegion: 'vn',
        add: {'executive'},
      ),
      'role_not_allowed',
    );
    expect(
      accountChangeRefusal(actor: _admin(), target: _hrDe, serviceRegion: 'vn'),
      'other_region',
    );
  });

  test('quản trị tập đoàn gán vai trò tập đoàn, không tự sửa mình', () {
    expect(
      accountChangeRefusal(
        actor: _admin(group: true),
        target: _hrDe,
        serviceRegion: 'de',
        add: {'group', 'hr'},
      ),
      isNull,
    );
    const me = KeycloakUser(id: 'admin-1', username: 'admin', enabled: true);
    expect(
      accountChangeRefusal(
        actor: _admin(group: true),
        target: me,
        serviceRegion: 'vn',
        remove: {'admin'},
      ),
      'self_change',
    );
  });
}
