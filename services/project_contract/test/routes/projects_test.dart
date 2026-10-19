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
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => (items: [_project()], total: 1));
    request('/projects?q=nha', _claims(['finance']));

    final body = await (await list.onRequest(context)).json() as Map;
    expect(body['total'], 1);
    verify(() => repository.projects(search: 'nha')).called(1);
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

  test('tài khoản chưa gắn nhân viên thì 403', () async {
    request('/me/projects', _claims(['finance'], employeeId: null));
    expect((await mine.onRequest(context)).statusCode, 403);
  });
}
