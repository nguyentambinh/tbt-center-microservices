/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/employee_repository.dart';
import 'package:hr_service/src/domain/employee.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/employees/[id].dart' as detail_route;
import '../../routes/employees/index.dart' as list_route;
import '../../routes/internal/employees.dart' as hire_route;

class _MockContext extends Mock implements RequestContext {}

class _MockRepository extends Mock implements EmployeeRepository {}

class _FakeHire extends Fake implements NewHire {}

const _lena = EmployeeSummary(
  id: 'LEN60001BER',
  familyName: 'Koch',
  givenName: 'Lena',
  position: 'Projektleiter',
);

void main() {
  late _MockContext context;
  late _MockRepository repository;

  setUpAll(() => registerFallbackValue(_FakeHire()));

  setUp(() {
    context = _MockContext();
    repository = _MockRepository();
    when(() => context.read<EmployeeRepository>()).thenReturn(repository);
  });

  void request(String path, {HttpMethod method = HttpMethod.get}) {
    when(() => context.request).thenReturn(
      Request(method.value, Uri.parse('http://localhost$path')),
    );
  }

  group('GET /employees', () {
    test('trả trang kết quả, truyền đúng tham số tìm kiếm', () async {
      request('/employees?q=lena&page=2&size=10');
      when(
        () => repository.search(
          query: 'lena',
          page: 2,
          size: 10,
        ),
      ).thenAnswer(
        (_) async => const Page([_lena], total: 11, page: 2, size: 10),
      );

      final response = await list_route.onRequest(context);

      expect(response.statusCode, HttpStatus.ok);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['total'], 11);
      final first = (body['items'] as List).first as Map<String, dynamic>;
      expect(first['givenName'], 'Lena');
    });

    test('size quá lớn thì báo 400', () async {
      request('/employees?size=1000');
      final response = await list_route.onRequest(context);
      expect(response.statusCode, HttpStatus.badRequest);
      expect((await response.json() as Map)['code'], 'invalid_paging');
    });

    test('không phải GET thì 405', () async {
      request('/employees', method: HttpMethod.post);
      final response = await list_route.onRequest(context);
      expect(response.statusCode, HttpStatus.methodNotAllowed);
    });
  });

  group('GET /employees/{id}', () {
    test('không có thì 404', () async {
      request('/employees/KHONGCO');
      when(() => repository.find('KHONGCO')).thenAnswer((_) async => null);
      final response = await detail_route.onRequest(context, 'KHONGCO');
      expect(response.statusCode, HttpStatus.notFound);
    });

    test('có thì trả hồ sơ đầy đủ', () async {
      request('/employees/LEN60001BER');
      when(() => repository.find('LEN60001BER')).thenAnswer(
        (_) async => const EmployeeDetail(
          summary: _lena,
          work: {'birthYear': 1990},
          relatives: [
            {'fullName': 'Anna Koch'},
          ],
        ),
      );
      final response = await detail_route.onRequest(context, 'LEN60001BER');
      final body = await response.json() as Map<String, dynamic>;
      expect(body['work'], {'birthYear': 1990});
      expect((body['relatives'] as List).length, 1);
    });
  });
  group('POST /internal/employees', () {
    void post(Map<String, Object?> body) {
      when(() => context.request).thenReturn(
        Request.post(
          Uri.parse('http://localhost/internal/employees'),
          body: jsonEncode(body),
        ),
      );
    }

    test('tạo nhân viên từ ứng viên, trả 201', () async {
      post({
        'id': 'TBT1A2B3C4D',
        'countryCode': 'DE',
        'familyName': 'Koch',
        'givenName': 'Lena',
        'email': 'lena@gmail.com',
        'position': 'Projektleiter',
      });
      when(() => repository.hire(any())).thenAnswer((_) async => _lena);

      final response = await hire_route.onRequest(context);

      expect(response.statusCode, HttpStatus.created);
      final captured = verify(() => repository.hire(captureAny())).captured;
      final hire = captured.single as NewHire;
      expect(hire.email, 'lena@gmail.com');
      expect(hire.positionName, 'Projektleiter');
    });

    test('thiếu email thì 400, không ghi gì', () async {
      post({'id': 'X', 'countryCode': 'DE', 'givenName': 'Lena'});

      final response = await hire_route.onRequest(context);

      expect(response.statusCode, HttpStatus.badRequest);
      verifyNever(() => repository.hire(any()));
    });
  });
}
