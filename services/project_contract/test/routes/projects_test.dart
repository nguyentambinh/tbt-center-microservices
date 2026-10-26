/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_contract_service/src/data/project_repository.dart';
import 'package:project_contract_service/src/project_view.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/me/projects.dart' as mine;
import '../../routes/projects/[id].dart' as detail;
import '../../routes/projects/index.dart' as list;

class _MockContext extends Mock implements RequestContext {}

class _MockRepository extends Mock implements ProjectRepository {}

Claims _claims(List<String> roles, {String? employeeId = 'E1'}) => Claims({
  'employee_id': ?employeeId,
  'realm_access': {'roles': roles},
});

Map<String, dynamic> _project() => {
  'id': 'P1',
  'name': 'Xây nhà nhỏ',
  'customer': {
    'id': 'C1',
    'name': 'Nguyễn Văn An',
    'type': 'individual',
    'contact': '0901234567',
    'address': 'Hà Nội',
  },
  'contracts': <Object>[],
  'members': <Object>[],
};

void main() {
  late _MockContext context;
  late _MockRepository repository;

  setUp(() {
    context = _MockContext();
    repository = _MockRepository();
    when(() => context.read<ProjectRepository>()).thenReturn(repository);
    when(() => context.read<RateLookup>()).thenReturn((_) async => 25000);
    when(
      () => context.read<EmployeeNames>(),
    ).thenReturn(() async => {'E1': 'Lê Minh Thư', 'E2': 'Trần Văn An'});
  });

  void request(String path, Claims claims) {
    when(
      () => context.request,
    ).thenReturn(Request('GET', Uri.parse('http://localhost$path')));
    when(() => context.read<Claims>()).thenReturn(claims);
  }

  test('tài chính xem danh sách dự án', () async {
    when(
      () => repository.projects(
        search: any(named: 'search'),
        tier: any(named: 'tier'),
        rateToUsd: any(named: 'rateToUsd'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer(
      (_) async => (
        items: [
          {
            ..._project(),
            'status': 'in_progress',
            'expectedAcceptance': '5000000000',
            'startDate': '2020-01-01',
            'endDate': '2099-01-01',
          },
        ],
        total: 1,
      ),
    );
    request('/projects?q=nha&tier=2', _claims(['finance']));

    final body = await (await list.onRequest(context)).json() as Map;
    expect(body['total'], 1);
    final item = (body['items'] as List).single as Map;
    expect(item['tier'], 2);
    expect(item['warning'], 'normal');
    verify(
      () => repository.projects(search: 'nha', tier: 2, rateToUsd: 25000),
    ).called(1);
  });

  test('nhân viên thường không xem được danh sách dự án', () async {
    request('/projects', _claims(['employee']));
    expect((await list.onRequest(context)).statusCode, 403);
  });

  test('HR không thấy liên hệ của khách hàng', () async {
    when(() => repository.project('P1')).thenAnswer((_) async => _project());
    request('/projects/P1', _claims(['hr']));

    final body = await (await detail.onRequest(context, 'P1')).json() as Map;
    final customer = body['customer'] as Map;
    expect(customer['name'], 'Nguyễn Văn An');
    expect(customer.containsKey('contact'), isFalse);
  });

  test('tài chính thấy liên hệ của khách hàng', () async {
    when(() => repository.project('P1')).thenAnswer((_) async => _project());
    request('/projects/P1', _claims(['finance']));

    final body = await (await detail.onRequest(context, 'P1')).json() as Map;
    expect((body['customer'] as Map)['contact'], '0901234567');
  });

  test('không có dự án thì 404', () async {
    when(() => repository.project('X')).thenAnswer((_) async => null);
    request('/projects/X', _claims(['finance']));
    expect((await detail.onRequest(context, 'X')).statusCode, 404);
  });

  test('nhân viên xem dự án mình tham gia', () async {
    when(() => repository.projectsOf('E1')).thenAnswer(
      (_) async => [
        {'projectId': 'P1', 'hours': 180.0},
      ],
    );
    request('/me/projects', _claims(['employee']));

    final body = await (await mine.onRequest(context)).json() as Map;
    expect((body['items'] as List).single, containsPair('hours', 180.0));
  });

  test('nhân viên xem dự án: không thấy tiền, mã đồng nghiệp; dòng của mình '
      'có tiền dự án', () async {
    when(() => repository.isMember('P1', 'E1')).thenAnswer((_) async => true);
    when(() => repository.project('P1')).thenAnswer(
      (_) async => {
        ..._project(),
        'deposit': '50000000',
        'expectedAcceptance': '900000000',
        'imageUrl': 'https://s3/p1.jpg',
        'members': [
          {'employeeId': 'E1', 'hours': 8.0, 'projectSalary': '1000'},
          {'employeeId': 'E2', 'hours': 6.0, 'projectSalary': '900'},
        ],
      },
    );
    request('/projects/P1', _claims(['employee']));

    final response = await detail.onRequest(context, 'P1');
    final body = await response.json() as Map;
    expect(response.statusCode, 200);
    expect(body['imageUrl'], 'https://s3/p1.jpg');
    expect(body.containsKey('deposit'), isFalse);
    expect(body.containsKey('expectedAcceptance'), isFalse);
    final members = (body['members'] as List).cast<Map<String, dynamic>>();
    expect(members.first, containsPair('isMe', true));
    expect(members.first, containsPair('projectSalary', '1000'));
    expect(members.last, containsPair('name', 'Trần Văn An'));
    expect(members.last, isNot(contains('employeeId')));
    expect(members.last, isNot(contains('projectSalary')));
    expect(body['customer'], isNot(contains('contact')));
  });

  test('nhân viên không tham gia dự án thì 403', () async {
    when(() => repository.isMember('P1', 'E1')).thenAnswer((_) async => false);
    request('/projects/P1', _claims(['employee']));
    expect((await detail.onRequest(context, 'P1')).statusCode, 403);
    verifyNever(() => repository.project(any()));
  });

  test('tài khoản chưa gắn nhân viên thì 403', () async {
    request('/me/projects', _claims(['finance'], employeeId: null));
    expect((await mine.onRequest(context)).statusCode, 403);
  });
}
