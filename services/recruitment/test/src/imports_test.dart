/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

// Chuỗi XML của tệp Excel mẫu được nối liền, không cần dấu cách giữa các thẻ.
// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recruitment_service/src/imports/draft_rows.dart';
import 'package:recruitment_service/src/imports/import_repository.dart';
import 'package:recruitment_service/src/imports/sheet_reader.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

import '../../routes/candidate-imports/index.dart' as route;

class _MockContext extends Mock implements RequestContext {}

class _MockImports extends Mock implements ImportRepository {}

/// Một tệp .xlsx tối thiểu: chữ nằm ở sharedStrings, có một ô trống ở giữa.
List<int> _xlsx() {
  const shared =
      '<sst><si><t>Họ và tên</t></si><si><t>Email</t></si>'
      '<si><t>Vị trí ứng tuyển</t></si><si><t>Trần Văn Nam</t></si>'
      '<si><t>nam.tran@example.com</t></si><si><t>Kỹ sư cầu đường</t></si></sst>';
  const sheet =
      '<worksheet><sheetData>'
      '<row r="1"><c r="A1" t="s"><v>0</v></c><c r="B1" t="s"><v>1</v></c>'
      '<c r="C1" t="s"><v>2</v></c></row>'
      '<row r="2"><c r="A2" t="s"><v>3</v></c><c r="B2" t="s"><v>4</v></c>'
      '<c r="C2" t="s"><v>5</v></c></row>'
      '<row r="3"><c r="A3" t="inlineStr"><is><t>Lê Thị Hoa</t></is></c>'
      '<c r="C3" t="s"><v>5</v></c></row>'
      '</sheetData></worksheet>';
  final zip = Archive()
    ..addFile(ArchiveFile.string('xl/sharedStrings.xml', shared))
    ..addFile(ArchiveFile.string('xl/worksheets/sheet1.xml', sheet));
  return ZipEncoder().encode(zip);
}

void main() {
  group('đọc tệp', () {
    test('CSV dấu chấm phẩy, có BOM và ô có ngoặc kép', () {
      final rows = readCsv(
        '﻿Họ tên;Email;Vị trí\r\n'
        '"Nguyễn Văn ""Tèo"" An";an@example.com;"Kỹ sư; giám sát"\r\n',
      );
      expect(rows, [
        ['Họ tên', 'Email', 'Vị trí'],
        ['Nguyễn Văn "Tèo" An', 'an@example.com', 'Kỹ sư; giám sát'],
      ]);
    });

    test(
      'Excel: đọc chữ dùng chung, chữ trong ô, giữ đúng cột khi ô trống',
      () {
        final rows = readXlsx(_xlsx());
        expect(rows[1], [
          'Trần Văn Nam',
          'nam.tran@example.com',
          'Kỹ sư cầu đường',
        ]);
        expect(rows[2], ['Lê Thị Hoa', '', 'Kỹ sư cầu đường']);
      },
    );

    test('đuôi tệp khác thì báo không hỗ trợ', () {
      expect(
        () => readSheet('cv.pdf', [1, 2, 3]),
        throwsA(isA<SheetFormatException>()),
      );
    });
  });

  group('dòng nháp', () {
    test('nhận tên cột tiếng Đức, báo lỗi từng dòng', () {
      final drafts = draftRows([
        ['Vollständiger Name', 'E-Mail', 'Telefon', 'Stelle'],
        ['Anna Schmidt', 'ANNA@example.de', '', 'Bauleiterin'],
        ['', 'x@example.de', '', ''],
        ['Max Weber', '', '', ''],
        ['Lena Koch', 'lena-at-example', '', ''],
      ]);
      expect(drafts[0].email, 'anna@example.de');
      expect(drafts[0].appliedPosition, 'Bauleiterin');
      expect(drafts[0].error, isNull);
      expect(drafts[0].rowNumber, 2);
      expect(
        [for (final d in drafts.skip(1)) d.error],
        [
          'missing_name',
          'missing_contact',
          'invalid_email',
        ],
      );
    });

    test('không có cột họ tên thì không đọc được', () {
      expect(
        () => draftRows([
          ['Email'],
          ['a@b.vn'],
        ]),
        throwsA(isA<MissingNameColumn>()),
      );
    });
  });

  group('POST /candidate-imports', () {
    late _MockContext context;
    late _MockImports imports;

    setUp(() {
      context = _MockContext();
      imports = _MockImports();
      when(() => context.read<ImportRepository>()).thenReturn(imports);
    });

    void request(List<String> roles, Map<String, Object?> body) {
      when(() => context.request).thenReturn(
        Request(
          'POST',
          Uri.parse('http://localhost/candidate-imports'),
          body: jsonEncode(body),
        ),
      );
      when(() => context.read<Claims>()).thenReturn(
        Claims({
          'preferred_username': 'hr.vn',
          'realm_access': {'roles': roles},
        }),
      );
    }

    test('HR tải Excel lên thì thành danh sách nháp', () async {
      when(
        () => imports.createDraft(
          sourceType: 'xlsx',
          sourceRef: 'dot-1.xlsx',
          importedBy: 'hr.vn',
          rows: any(named: 'rows'),
        ),
      ).thenAnswer((_) async => {'id': 'I1', 'rows': <Object>[]});
      request(
        ['hr'],
        {
          'fileName': 'dot-1.xlsx',
          'content': base64Encode(_xlsx()),
        },
      );
      final response = await route.onRequest(context);
      expect(response.statusCode, 201);
      final rows =
          verify(
                () => imports.createDraft(
                  sourceType: 'xlsx',
                  sourceRef: 'dot-1.xlsx',
                  importedBy: 'hr.vn',
                  rows: captureAny(named: 'rows'),
                ),
              ).captured.single
              as List<DraftRow>;
      expect(rows, hasLength(2));
    });

    test('nhân viên thường không nhập được', () async {
      request(['employee'], {'fileName': 'a.csv', 'content': ''});
      expect((await route.onRequest(context)).statusCode, 403);
    });

    test('tệp PDF thì 400 unsupported_file', () async {
      request(
        ['hr'],
        {
          'fileName': 'a.pdf',
          'content': base64Encode([1]),
        },
      );
      final body = await (await route.onRequest(context)).json() as Map;
      expect(body['code'], 'unsupported_file');
    });
  });
}
