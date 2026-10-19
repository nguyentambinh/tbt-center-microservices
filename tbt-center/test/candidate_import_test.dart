/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/core/router/app_router.dart';
import 'package:tbtcenter/features/recruitment/domain/entities/candidate_import.dart';
import 'package:tbtcenter/features/recruitment/domain/repositories/candidate_import_repository.dart';
import 'package:tbtcenter/features/recruitment/presentation/providers/candidate_providers.dart';

import 'helpers.dart';

/// Giả lập server: dòng được xác nhận chuyển sang `accepted`.
class FakeImportRepository implements CandidateImportRepository {
  final confirmed = <List<String>?>[];
  var rows = const [
    ImportRow(id: 'R2', rowNumber: 2, fullName: 'Phạm Quốc Huy', email: 'huy.pham@example.com', isUpdate: false, status: 'pending'),
    ImportRow(id: 'R3', rowNumber: 3, fullName: 'Lê Minh Thư', email: 'thu.le@example.com', isUpdate: true, status: 'pending'),
    ImportRow(id: 'R4', rowNumber: 4, fullName: '', isUpdate: false, status: 'invalid', error: 'missing_name'),
  ];

  CandidateImport get _draft => CandidateImport(id: 'I1', fileName: 'ung-vien-dot-1.csv', rows: rows);

  @override
  Future<CandidateImport> upload(String fileName, List<int> bytes) async => _draft;

  @override
  Future<CandidateImport> find(String id) async => _draft;

  @override
  Future<({int accepted, CandidateImport draft})> confirm(String id, {List<String>? rowIds}) async {
    confirmed.add(rowIds);
    var accepted = 0;
    rows = [
      for (final r in rows)
        if (r.pending && (rowIds == null || rowIds.contains(r.id)))
          (() {
            accepted++;
            return ImportRow(id: r.id, rowNumber: r.rowNumber, fullName: r.fullName, isUpdate: r.isUpdate, status: 'accepted');
          })()
        else
          r,
    ];
    return (accepted: accepted, draft: _draft);
  }
}

void main() {
  testWidgets('HR tick một người, xác nhận đã chọn, rồi xác nhận tất cả phần còn lại', (tester) async {
    final imports = FakeImportRepository();
    final overrides = await testOverrides(
      language: 'vi',
      store: MemorySessionStore(fakeSession(token: fakeJwt(roles: ['hr']))),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [...overrides, candidateImportRepositoryProvider.overrideWithValue(imports)],
      child: const TbtApp(),
    ));
    await tester.pumpAndSettle();
    ProviderScope.containerOf(tester.element(find.byType(TbtApp))).read(appRouterProvider).push('/candidates/imports/I1');
    await tester.pumpAndSettle();

    expect(find.text('3 dòng, còn 2 dòng chờ xác nhận'), findsOneWidget);
    expect(find.text('Thêm mới'), findsOneWidget);
    expect(find.text('Cập nhật'), findsOneWidget);
    expect(find.text('Thiếu họ tên'), findsOneWidget);

    // Dòng lỗi không tick được.
    final invalid = tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, '—'));
    expect(invalid.onChanged, isNull);

    await tester.tap(find.text('Phạm Quốc Huy'));
    await tester.pump();
    await tester.tap(find.text('Xác nhận đã chọn (1)'));
    await tester.pumpAndSettle();
    expect(imports.confirmed.single, ['R2']);
    expect(find.text('Đã ghi 1 hồ sơ'), findsOneWidget);

    await tester.tap(find.text('Xác nhận tất cả'));
    await tester.pumpAndSettle();
    expect(imports.confirmed.last, isNull);
    expect(find.text('Xác nhận tất cả'), findsNothing);
  });
}
