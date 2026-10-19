/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:datastore_service/src/ingestor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../routes/internal/ingest.dart' as ingest_route;

class _MockContext extends Mock implements RequestContext {}

void main() {
  final cipher = FieldCipher({'vn': List.filled(32, 1)}, List.filled(32, 9));
  late List<BucketWrite> written;
  late Ingestor ingestor;

  setUp(() {
    written = [];
    ingestor = Ingestor(
      cipher,
      (buckets) async => written.addAll(buckets),
      clock: () => DateTime.utc(2026, 10, 16, 12),
    );
  });

  test('bảng ngoài danh mục thì từ chối', () {
    expect(
      () => ingestor.ingest('vn', 'outbox', [
        (key: {'id': 1}, data: {}),
      ]),
      throwsA(isA<IngestRejected>()),
    );
  });

  test('khóa không đúng cấu trúc thì từ chối', () {
    expect(
      () => ingestor.ingest('vn', 'employees', [
        (key: {'employee_id': 'E1'}, data: {}),
      ]),
      throwsA(isA<IngestRejected>()),
    );
  });

  test('gom theo ngăn, mã hóa dữ liệu cá nhân, cập nhật mục lục', () async {
    final rows = [
      for (var i = 0; i < 40; i++)
        (
          key: <String, Object?>{'id': 'E$i'},
          data: <String, Object?>{
            'id': 'E$i',
            'given_name': 'Tên $i',
            'company_id': 'C1',
          },
        ),
    ];
    final n = await ingestor.ingest('vn', 'employees', rows);

    expect(n, 40);
    final buckets = written.where(
      (b) => b.path.startsWith('regions/vn/employees/'),
    );
    expect(buckets.length, lessThanOrEqualTo(16));
    expect(buckets.expand((b) => b.rows.values), hasLength(40));
    final row = buckets.first.rows.values.first;
    expect(row['given_name'], startsWith(FieldCipher.prefix));
    expect(row['company_id'], 'C1');
    expect(
      jsonEncode([for (final b in written) b.rows]),
      isNot(contains('Tên 1')),
    );
    final index = written.singleWhere((b) => b.path == 'regions/vn');
    expect(index.top['tables.employees'], '2026-10-16T12:00:00.000Z');
  });

  test('route: nước lấy từ token, không lấy từ body', () async {
    final context = _MockContext();
    when(() => context.request).thenReturn(
      Request.post(
        Uri.parse('http://localhost/internal/ingest'),
        body: jsonEncode({
          'region': 'de',
          'table': 'companies',
          'rows': [
            {
              'key': {'id': 'C1'},
              'data': {'id': 'C1', 'name': 'TBT'},
            },
          ],
        }),
      ),
    );
    when(() => context.read<String>()).thenReturn('vn');
    when(() => context.read<Ingestor>()).thenReturn(ingestor);

    final response = await ingest_route.onRequest(context);

    expect(response.statusCode, 200);
    expect(await response.json(), containsPair('region', 'vn'));
    expect(written.first.path, startsWith('regions/vn/'));
  });
}
