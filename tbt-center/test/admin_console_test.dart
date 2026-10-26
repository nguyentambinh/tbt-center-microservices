/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/core/error/app_failure.dart';
import 'package:tbtcenter/features/admin/admin_repository.dart';

import 'helpers.dart';

/// Server quản trị giả: thống kê cố định, câu SQL ghi bị từ chối như giao dịch chỉ đọc
class FakeAdminRepository extends AdminRepository {
  FakeAdminRepository() : super(Dio(), baseUrl: '');

  @override
  Future<DataOverview> overview() async => (
        databases: [
          (
            name: 'hr_db',
            sizeBytes: 9 * 1024 * 1024,
            tables: [(name: 'employees', rows: 77), (name: 'departments', rows: 23)],
            activity: [(day: '2026-10-25', events: 12), (day: '2026-10-26', events: 30)],
            available: true,
          ),
        ],
        accounts: {'total': 5, 'hr': 1, 'employee': 3, 'admin': 1},
      );

  @override
  Future<List<Backup>> backups() async => const [];

  @override
  Future<SqlResult> runSql(String database, String sql, {required bool write}) async {
    if (sql.toLowerCase().startsWith('delete')) {
      throw const AppFailure(FailureKind.validation, statusCode: 400, serverCode: 'read_only', serverMessage: 'cannot execute DELETE in a read-only transaction');
    }
    return (columns: ['id', 'name'], rows: [['E1', 'Lê Minh Thư']], affected: 1, truncated: false);
  }
}

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await pumpApp(
    tester,
    language: 'vi',
    store: MemorySessionStore(fakeSession(token: fakeJwt(username: 'admin.vn', roles: ['admin']))),
    extraOverrides: [adminRepositoryProvider.overrideWithValue(FakeAdminRepository())],
  );
  await openHomeCard(tester, 'Quản trị dữ liệu');
}

void main() {
  testWidgets('quản trị: tổng quan có tài khoản theo vai trò và cơ sở dữ liệu', (tester) async {
    await _pump(tester);
    expect(find.text('5 tài khoản'), findsOneWidget);
    expect(find.text('hr_db'), findsOneWidget);
    expect(find.text('2 bảng · 100 dòng · 9.0 MB'), findsOneWidget);
  });

  testWidgets('SQL chỉ đọc: câu ghi báo lỗi dễ hiểu, có chi tiết kỹ thuật', (tester) async {
    await _pump(tester);
    await tester.ensureVisible(find.widgetWithText(Tab, 'Dữ liệu'));
    await tester.tap(find.widgetWithText(Tab, 'Dữ liệu'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('admin-sql')), 'delete from employees');
    await tester.ensureVisible(find.text('Chạy'));
    await tester.tap(find.text('Chạy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('bật Cho phép ghi'), findsOneWidget);
    await tester.ensureVisible(find.text('Chi tiết kỹ thuật'));
    await tester.tap(find.text('Chi tiết kỹ thuật'));
    await tester.pumpAndSettle();
    expect(find.textContaining('read-only transaction'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('admin-sql')), 'select id, name from employees');
    await tester.ensureVisible(find.text('Chạy'));
    await tester.tap(find.text('Chạy'));
    await tester.pumpAndSettle();
    expect(find.text('1 dòng'), findsOneWidget);
    expect(find.text('Lê Minh Thư'), findsOneWidget);
  });
}
