/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:audit_service/src/audit_access.dart';
import 'package:audit_service/src/audit_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/audit-log/access.dart' as access_route;
import '../../routes/audit-log/export.dart' as export_route;
import '../../routes/audit-log/index.dart' as search_route;

class _MockContext extends Mock implements RequestContext {}

class _MockRepository extends Mock implements AuditRepository {}

Claims _claims(List<String> roles, {String? until}) => Claims({
  'sub': 'sub-1',
  'preferred_username': 'auditor.ext',
  'access_until': ?until,
  'realm_access': {'roles': roles},
});

final _row = {
  'id': 1,
  'region': 'vn',
  'source_service': 'payroll',
  'event_type': 'PayrollRunCompleted',
  'aggregate_id': 'R1',
  'occurred_at': DateTime.utc(2026, 10, 15, 7),
  'received_at': DateTime.utc(2026, 10, 15, 7, 0, 5),
  'payload': {'period': '2026-10', 'note': 'có "ngoặc", dấu phẩy'},
  'prev_hash': '0' * 64,
  'hash': 'a' * 64,
};

void main() {
  group('quyền kiểm toán có thời hạn (R88)', () {
    final now = DateTime.utc(2026, 10, 15, 12);

    test('kiểm toán viên còn hạn thì được, tính tới hết ngày cuối', () {
      expect(
        auditorAccessDenied(_claims(['auditor'], until: '2026-10-15'), now),
        isNull,
      );
    });

    test('quá hạn hoặc không có hạn thì bị từ chối', () {
      expect(
        auditorAccessDenied(_claims(['auditor'], until: '2026-10-14'), now),
        'access_expired',
      );
      expect(auditorAccessDenied(_claims(['auditor']), now), 'access_expired');
    });

    test('lãnh đạo, quản trị không cần hạn; vai trò khác không được', () {
      expect(auditorAccessDenied(_claims(['executive']), now), isNull);
      expect(auditorAccessDenied(_claims(['hr']), now), 'forbidden');
    });
  });

  test('tệp xuất có mã SHA-256 đúng nội dung, ô có dấu phẩy được bọc', () {
    final export = exportCsv([_row]);
    expect(export.csv, startsWith('id,region,source_service,'));
    expect(export.csv, contains('"{""period"":""2026-10""'));
    expect(
      export.checksum,
      sha256.convert(utf8.encode(export.csv)).toString(),
    );
    // Sửa một chữ trong tệp thì mã khác hẳn.
    final edited = export.csv.replaceFirst('PayrollRunCompleted', 'Payroll');
    expect(
      sha256.convert(utf8.encode(edited)).toString(),
      isNot(export.checksum),
    );
  });

  group('route', () {
    late _MockContext context;
    late _MockRepository repository;

    setUpAll(() {
      registerFallbackValue(const AuditFilter());
      registerFallbackValue(
        const AccessRecord(
          userSub: '',
          username: '',
          roles: {},
          action: '',
        ),
      );
    });

    setUp(() {
      context = _MockContext();
      repository = _MockRepository();
      when(() => context.read<AuditRepository>()).thenReturn(repository);
      when(() => repository.logAccess(any())).thenAnswer((_) async {});
    });

    void request(String path, Claims claims) {
      when(
        () => context.request,
      ).thenReturn(Request('GET', Uri.parse('http://localhost$path')));
      when(() => context.read<Claims>()).thenReturn(claims);
    }

    test('tra cứu được ghi vào nhật ký truy cập (R90)', () async {
      when(
        () => repository.search(any(), limit: any(named: 'limit')),
      ).thenAnswer(
        (_) async => [
          {'id': 1},
        ],
      );
      request(
        '/audit-log?region=vn&from=2026-10-01',
        _claims(['auditor'], until: '2099-12-31'),
      );

      final response = await search_route.onRequest(context);
      expect(response.statusCode, 200);
      final record =
          verify(() => repository.logAccess(captureAny())).captured.single
              as AccessRecord;
      expect(record.action, 'search');
      expect(record.username, 'auditor.ext');
      expect(record.filter.region, 'vn');
      expect(record.rowCount, 1);
    });

    test('kiểm toán viên hết hạn thì 403 và không đọc sổ', () async {
      request('/audit-log', _claims(['auditor'], until: '2020-01-01'));
      final body = await (await search_route.onRequest(context)).json() as Map;
      expect(body['code'], 'access_expired');
      verifyNever(() => repository.search(any(), limit: any(named: 'limit')));
    });

    test('xuất CSV trả mã SHA-256 ở header và ghi mã đó vào nhật ký', () async {
      when(
        () => repository.search(any(), exportAll: true),
      ).thenAnswer((_) async => [_row]);
      request('/audit-log/export', _claims(['executive']));

      final response = await export_route.onRequest(context);
      final checksum = response.headers['x-checksum-sha256'];
      expect(
        checksum,
        sha256.convert(utf8.encode(await response.body())).toString(),
      );
      final record =
          verify(() => repository.logAccess(captureAny())).captured.single
              as AccessRecord;
      expect(record.checksum, checksum);
    });

    test('kiểm toán viên không xem được nhật ký truy cập', () async {
      request('/audit-log/access', _claims(['auditor'], until: '2099-12-31'));
      expect((await access_route.onRequest(context)).statusCode, 403);
    });
  });
}
