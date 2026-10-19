/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:mocktail/mocktail.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/identity/hiring.dart';
import 'package:recruitment_service/src/identity/keycloak_admin.dart';
import 'package:test/test.dart';

class _MockRepository extends Mock implements CandidateRepository {}

class _MockIdentity extends Mock implements IdentityAdmin {}

class _FakeAccount extends Fake implements StaffAccount {}

const _id = '1a2b3c4d-0000-4000-8000-000000000001';

Map<String, dynamic> _candidate({
  String status = 'offered',
  String? email = 'thu.le@gmail.com',
}) => {
  'id': _id,
  'countryCode': 'VN',
  'fullName': 'Lê Minh Thư',
  'email': email,
  'phone': '0909000111',
  'appliedPosition': 'Kế toán',
  'status': status,
};

void main() {
  late _MockRepository repository;
  late _MockIdentity identity;
  late List<Map<String, Object?>> employeeCalls;
  late Hiring hiring;

  setUpAll(() => registerFallbackValue(_FakeAccount()));

  setUp(() {
    repository = _MockRepository();
    identity = _MockIdentity();
    employeeCalls = [];
    hiring = Hiring(
      candidates: repository,
      identity: identity,
      createEmployee: (body) async {
        employeeCalls.add(body);
        return body['id']! as String;
      },
      region: 'vn',
    );
    when(() => identity.configured).thenReturn(true);
    when(() => repository.subjectOf(_id)).thenAnswer((_) async => 'sub-thu');
    when(
      () => repository.markHired(
        _id,
        employeeId: any(named: 'employeeId'),
        changedBy: any(named: 'changedBy'),
        subject: any(named: 'subject'),
      ),
    ).thenAnswer((_) async => _candidate(status: 'hired'));
  });

  test('ứng viên có tài khoản: giữ mật khẩu, đăng nhập bằng email', () async {
    when(() => repository.findById(_id)).thenAnswer((_) async => _candidate());
    when(
      () => identity.grantEmployee(any(), subject: 'sub-thu'),
    ).thenAnswer((_) async => (subject: 'sub-thu', temporaryPassword: null));

    final result = await hiring.hire(_id, hiredBy: 'hr.vn');

    expect(result!.login, 'thu.le@gmail.com');
    expect(result.temporaryPassword, isNull);
    expect(result.employeeId, 'TBT1A2B3C4D');
    expect(employeeCalls.single['givenName'], 'Thư');
    expect(employeeCalls.single['familyName'], 'Lê Minh');
    final account =
        verify(
              () => identity.grantEmployee(captureAny(), subject: 'sub-thu'),
            ).captured.single
            as StaffAccount;
    expect(account.employeeId, 'TBT1A2B3C4D');
    expect(account.region, 'vn');
  });

  test('hồ sơ HR nhập (chưa có tài khoản) thì trả mật khẩu tạm', () async {
    when(() => repository.findById(_id)).thenAnswer((_) async => _candidate());
    when(() => repository.subjectOf(_id)).thenAnswer((_) async => null);
    when(
      () => identity.grantEmployee(any()),
    ).thenAnswer((_) async => (subject: 'sub-new', temporaryPassword: 'Tmp'));

    final result = await hiring.hire(_id, hiredBy: 'hr.vn');

    expect(result!.temporaryPassword, 'Tmp');
    verify(
      () => repository.markHired(
        _id,
        employeeId: 'TBT1A2B3C4D',
        changedBy: 'hr.vn',
        subject: 'sub-new',
      ),
    ).called(1);
  });

  test('chưa tới bước offered thì không nhận, không tạo gì', () async {
    when(
      () => repository.findById(_id),
    ).thenAnswer((_) async => _candidate(status: 'interview'));

    await expectLater(
      hiring.hire(_id, hiredBy: 'hr.vn'),
      throwsA(
        isA<HiringRuleViolation>().having((e) => e.code, 'code', 'not_offered'),
      ),
    );
    expect(employeeCalls, isEmpty);
  });

  test('không có email thì báo email_required', () async {
    when(
      () => repository.findById(_id),
    ).thenAnswer((_) async => _candidate(email: null));

    await expectLater(
      hiring.hire(_id, hiredBy: 'hr.vn'),
      throwsA(
        isA<HiringRuleViolation>().having((e) => e.statusCode, 'status', 422),
      ),
    );
  });

  test('Keycloak lỗi thì 502, chưa đổi bước để HR bấm lại', () async {
    when(() => repository.findById(_id)).thenAnswer((_) async => _candidate());
    when(
      () => identity.grantEmployee(any(), subject: any(named: 'subject')),
    ).thenThrow(const IdentityException('down'));

    await expectLater(
      hiring.hire(_id, hiredBy: 'hr.vn'),
      throwsA(
        isA<HiringRuleViolation>().having((e) => e.statusCode, 'status', 502),
      ),
    );
    verifyNever(
      () => repository.markHired(
        any(),
        employeeId: any(named: 'employeeId'),
        changedBy: any(named: 'changedBy'),
        subject: any(named: 'subject'),
      ),
    );
  });

  test('tách tên theo nước', () {
    expect(splitName('Lena Koch', 'DE'), (family: 'Koch', given: 'Lena'));
    expect(splitName('Nguyễn Văn An', 'VN'), (
      family: 'Nguyễn Văn',
      given: 'An',
    ));
    expect(splitName('Madonna', 'US'), (family: '', given: 'Madonna'));
  });
}
