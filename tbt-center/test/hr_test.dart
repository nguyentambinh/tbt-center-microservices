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
import 'package:go_router/go_router.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/core/error/app_failure.dart';
import 'package:tbtcenter/core/router/app_router.dart';
import 'package:tbtcenter/features/hr/data/models/employee_models.dart';
import 'package:tbtcenter/features/hr/domain/entities/employee.dart';
import 'package:tbtcenter/features/hr/domain/repositories/employee_repository.dart';
import 'package:tbtcenter/features/hr/presentation/providers/employee_providers.dart';

import 'helpers.dart';

const _an = EmployeeSummary(id: 'AN001', familyName: 'Nguyễn Văn', givenName: 'An', position: 'Kỹ sư', department: 'Thi công');
const _binh = EmployeeSummary(id: 'BIN002', familyName: 'Trần Thị', givenName: 'Bình', position: 'Kế toán');

class FakeEmployeeRepository implements EmployeeRepository {
  final queries = <String>[];
  bool failDetail = false;

  @override
  Future<EmployeePage> search({String query = '', int page = 1, EmployeeFilter filter = const EmployeeFilter()}) async {
    queries.add(query);
    final items = [_an, _binh].where((e) => query.isEmpty || e.givenName.contains(query)).toList();
    return EmployeePage(items: items, total: items.length, page: page);
  }

  @override
  Future<EmployeeDetail> find(String id) async {
    if (failDetail) throw const AppFailure(FailureKind.server);
    return const EmployeeDetail(
      summary: _an,
      birthYear: 1995,
      gender: 1,
      insurance: {'type': 'BHXH', 'number': 'BH2025000001'},
      relatives: [Relative(fullName: 'Lê Thị Hoa', relationship: 'Mẹ')],
    );
  }
}

Future<FakeEmployeeRepository> pumpSignedIn(WidgetTester tester, {List<String> roles = const ['hr']}) async {
  final repository = FakeEmployeeRepository();
  final overrides = await testOverrides(
    language: 'vi',
    store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles))),
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [...overrides, employeeRepositoryProvider.overrideWithValue(repository)],
    child: const TbtApp(),
  ));
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('HR mở danh sách, tìm kiếm, xem hồ sơ', (tester) async {
    final repository = await pumpSignedIn(tester);

    await openHomeCard(tester, 'Hồ sơ nhân viên');
    expect(find.text('2 nhân viên'), findsOneWidget);
    expect(find.text('Nguyễn Văn An'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Bình');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(repository.queries.last, 'Bình');
    expect(find.text('Nguyễn Văn An'), findsNothing);
    expect(find.text('Trần Thị Bình'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nguyễn Văn An'));
    await tester.pumpAndSettle();
    expect(find.text('Nam'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('BH2025000001'), 200);
    expect(find.text('Bảo hiểm'), findsOneWidget);
  });

  testWidgets('lỗi tải hồ sơ thì hiện câu báo và nút Thử lại', (tester) async {
    final repository = await pumpSignedIn(tester)..failDetail = true;
    final container = ProviderScope.containerOf(tester.element(find.byType(TbtApp)));
    container.read(appRouterProvider).push('/employees/AN001');
    await tester.pumpAndSettle();
    expect(find.text('Máy chủ đang gặp sự cố, vui lòng thử lại sau.'), findsOneWidget);

    repository.failDetail = false;
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Công việc'), findsOneWidget);
  });

  testWidgets('nhân viên thường không thấy thẻ Nhân sự và không vào được bằng đường dẫn', (tester) async {
    await pumpSignedIn(tester, roles: const ['employee']);
    expect(find.text('Hồ sơ nhân viên'), findsNothing);

    final context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).go('/employees');
    await tester.pumpAndSettle();
    expect(find.text('Xin chào, Nhan'), findsOneWidget);
  });

  test('đọc JSON danh sách từ service hr', () {
    final page = employeePageFromJson({
      'items': [
        {'id': 'X1', 'familyName': 'Koch', 'givenName': 'Lena', 'position': 'Projektleiter'},
      ],
      'total': 41,
      'page': 1,
    });
    expect(page.items.single.fullName(familyFirst: false), 'Lena Koch');
    expect(page.total, 41);
  });
}
