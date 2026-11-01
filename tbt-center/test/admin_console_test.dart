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

}
