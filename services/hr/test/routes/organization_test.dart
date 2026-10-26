/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:hr_service/src/organization.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/archives/[id].dart' as archive_route;
import '../../routes/departments/[id]/dissolve.dart' as dissolve_route;
import '../../routes/departments/[id]/index.dart' as department_route;
import '../../routes/departments/[id]/members.dart' as members_route;
import '../../routes/employees/[id]/position.dart' as position_route;
import '../../routes/nominations/[id]/decision.dart' as decision_route;
import '../../routes/nominations/index.dart' as nominations_route;
import '../../routes/rankings/index.dart' as rankings_route;

class _MockContext extends Mock implements RequestContext {}

class _MockOrganization extends Mock implements OrganizationRepository {}

class _MockKeycloak extends Mock implements KeycloakUsers {}

Claims _claims(List<String> roles) => Claims({
  'sub': 'u1',
  'employee_id': 'HR1',
  'realm_access': {'roles': roles},
});

void main() {
  late _MockContext context;
  late _MockOrganization organization;
  final hours = <String, ({double work, double overtime, int days})>{
    'E1': (work: 10, overtime: 0, days: 2),
    'E2': (work: 100, overtime: 10, days: 12),
    'E3': (work: 50, overtime: 0, days: 6),
  };

  setUp(() {
    context = _MockContext();
    organization = _MockOrganization();
    when(() => context.read<OrganizationRepository>()).thenReturn(organization);
    when(() => context.read<HoursLookup>()).thenReturn(
      ({required from, required to}) async => hours,
    );
  });

  void request(
    String method,
    String path, {
    Object? body,
    List<String> roles = const ['hr'],
  }) {
    when(() => context.request).thenReturn(
      Request(
        method,
        Uri.parse('http://localhost$path'),
        body: body == null ? null : jsonEncode(body),
      ),
    );
    when(() => context.read<Claims>()).thenReturn(_claims(roles));
  }

  test('trưởng phòng đứng đầu, còn lại theo tổng giờ làm', () async {
    when(() => organization.department('PB1')).thenAnswer(
      (_) async => {
        'id': 'PB1',
        'headId': 'E1',
        'memberList': [
          {'id': 'E3'},
          {'id': 'E1'},
          {'id': 'E2'},
        ],
      },
    );
    request('GET', '/departments/PB1');
    final response = await department_route.onRequest(context, 'PB1');
    final body = await response.json() as Map<String, dynamic>;
    final order = [
      for (final m in (body['memberList'] as List).cast<Map<String, dynamic>>())
        m['id'],
    ];
    expect(order, ['E1', 'E2', 'E3']);
  });

  test('điều chuyển trưởng phòng đi thì 409', () async {
    when(
      () => organization.transfer(
        'E1',
        toDepartment: 'PB2',
        by: any(named: 'by'),
      ),
    ).thenThrow(const OrganizationViolation('is_head', 'Head cannot move'));
    request('POST', '/departments/PB2/members', body: {'employeeId': 'E1'});
    final response = await members_route.onRequest(context, 'PB2');
    expect(response.statusCode, HttpStatus.conflict);
  });

  test('giải thể sai lý do thì 400', () async {
    when(
      () => organization.dissolve(
        'PB1',
        reasonCode: 'x',
        dissolvedBy: any(named: 'dissolvedBy'),
      ),
    ).thenThrow(const OrganizationViolation('invalid_reason', 'Unknown'));
    request('POST', '/departments/PB1/dissolve', body: {'reasonCode': 'x'});
    final response = await dissolve_route.onRequest(context, 'PB1');
    expect(response.statusCode, HttpStatus.badRequest);
  });

  test('xếp hạng theo điểm giờ làm, tăng ca, ngày công', () async {
    when(() => organization.activeEmployees()).thenAnswer(
      (_) async => [
        {'id': 'E1'},
        {'id': 'E2'},
        {'id': 'E3'},
      ],
    );
    request('GET', '/rankings');
    final response = await rankings_route.onRequest(context);
    final items = ((await response.json() as Map)['items'] as List)
        .cast<Map<String, dynamic>>();
    expect(items.first['id'], 'E2');
    expect(items.first['rank'], 1);
  });

  test('bảo lưu: rút khỏi dự án sau khi đổi trạng thái', () async {
    var removed = false;
    when(() => context.read<RemoveFromProjects>()).thenReturn((_) async {
      removed = true;
      return 2;
    });
    when(
      () => organization.archive('E3', reason: 'Nghỉ dài hạn', by: 'HR1'),
    ).thenAnswer((_) async {});
    request('POST', '/archives/E3', body: {'reason': 'Nghỉ dài hạn'});
    final response = await archive_route.onRequest(context, 'E3');
    expect(response.statusCode, HttpStatus.ok);
    expect(removed, isTrue);
    expect(await response.json(), containsPair('projectsLeft', 2));
  });

  test('Ban lãnh đạo không tự gửi đề cử', () async {
    request(
      'POST',
      '/nominations',
      body: {'employeeId': 'E2'},
      roles: ['executive'],
    );
    final response = await nominations_route.onRequest(context);
    expect(response.statusCode, HttpStatus.forbidden);
  });

  test('chỉ Ban lãnh đạo duyệt, duyệt thì tăng lương', () async {
    request('POST', '/nominations/1/decision', body: {'approve': true});
    expect(
      (await decision_route.onRequest(context, '1')).statusCode,
      HttpStatus.forbidden,
    );

    double? raised;
    when(() => context.read<RaiseSalary>()).thenReturn((id, percent, _) async {
      raised = percent;
    });
    when(
      () => organization.decideNomination(
        1,
        approve: true,
        decidedBy: 'HR1',
      ),
    ).thenAnswer(
      (_) async => {
        'id': 1,
        'employeeId': 'E2',
        'proposedPosition': 'Trưởng nhóm',
        'raisePercent': 10.0,
        'status': 'approved',
      },
    );
    request(
      'POST',
      '/nominations/1/decision',
      body: {'approve': true},
      roles: ['executive'],
    );
    final response = await decision_route.onRequest(context, '1');
    expect(response.statusCode, HttpStatus.ok);
    expect(raised, 10.0);
    expect(await response.json(), containsPair('salaryRaised', true));
  });

  test('lên cấp tập đoàn: chỉ văn phòng tập đoàn duyệt, cấp vai trò', () async {
    when(
      () => context.read<RaiseSalary>(),
    ).thenReturn((id, percent, _) async {});
    when(
      () => organization.decideNomination(
        2,
        approve: true,
        decidedBy: 'HR1',
      ),
    ).thenThrow(const OrganizationViolation('group_only', 'Group only'));
    request(
      'POST',
      '/nominations/2/decision',
      body: {'approve': true},
      roles: ['executive'],
    );
    final refused = await decision_route.onRequest(context, '2');
    expect((await refused.json() as Map)['code'], 'group_only');

    final keycloak = _MockKeycloak();
    when(() => context.read<KeycloakUsers>()).thenReturn(keycloak);
    when(() => keycloak.byEmployeeId('E2')).thenAnswer(
      (_) async =>
          const KeycloakUser(id: 'u-e2', username: 'e2', enabled: true),
    );
    when(
      () => keycloak.addRoles('u-e2', ['hr', 'group']),
    ).thenAnswer((_) async {});
    when(
      () => organization.decideNomination(
        2,
        approve: true,
        decidedBy: 'HR1',
        groupDecider: true,
      ),
    ).thenAnswer(
      (_) async => {
        'id': 2,
        'employeeId': 'E2',
        'proposedPosition': 'Nhân sự tập đoàn',
        'raisePercent': 15.0,
        'status': 'approved',
        'scope': 'group',
        'groupRole': 'hr',
      },
    );
    request(
      'POST',
      '/nominations/2/decision',
      body: {'approve': true},
      roles: ['executive', 'group'],
    );
    final response = await decision_route.onRequest(context, '2');
    expect(await response.json(), containsPair('accountUpdated', true));
    verify(() => keycloak.addRoles('u-e2', ['hr', 'group'])).called(1);
  });

  group('văn phòng quản lý đổi chức vụ làm thẳng', () {
    test('HR không được làm thẳng, phải đề cử', () async {
      request('POST', '/employees/E2/position', body: {'positionId': 'LV4-HEAD'});
      final response = await position_route.onRequest(context, 'E2');
      expect(response.statusCode, HttpStatus.forbidden);
    });

    test('không tự đổi chức vụ của mình', () async {
      request(
        'POST',
        '/employees/HR1/position',
        body: {'positionId': 'LV4-HEAD'},
        roles: ['executive'],
      );
      final response = await position_route.onRequest(context, 'HR1');
      expect((await response.json() as Map)['code'], 'self_approval');
    });

    test('thăng chức có hiệu lực ngay, chức vụ thấp hơn thì báo lỗi', () async {
      when(
        () => organization.changePosition(
          'E2',
          positionId: 'LV4-HEAD',
          promote: true,
          by: 'HR1',
          reason: 'Hoàn thành tốt dự án',
        ),
      ).thenAnswer((_) async => {'employeeId': 'E2', 'level': 4});
      request(
        'POST',
        '/employees/E2/position',
        body: {'positionId': 'LV4-HEAD', 'reason': 'Hoàn thành tốt dự án'},
        roles: ['executive'],
      );
      expect(
        (await position_route.onRequest(context, 'E2')).statusCode,
        HttpStatus.ok,
      );

      when(
        () => organization.changePosition(
          'E3',
          positionId: 'NV',
          promote: true,
          by: 'HR1',
        ),
      ).thenThrow(
        const OrganizationViolation('not_higher_position', 'Higher only'),
      );
      request(
        'POST',
        '/employees/E3/position',
        body: {'positionId': 'NV'},
        roles: ['executive'],
      );
      final response = await position_route.onRequest(context, 'E3');
      expect(response.statusCode, HttpStatus.conflict);
    });
  });
}
