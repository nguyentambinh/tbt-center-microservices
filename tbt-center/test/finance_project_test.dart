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
import 'package:tbtcenter/core/widgets/bar_chart.dart';
import 'package:tbtcenter/features/finance/domain/entities/finance.dart';
import 'package:tbtcenter/features/finance/domain/repositories/finance_repository.dart';
import 'package:tbtcenter/features/finance/presentation/providers/finance_providers.dart';
import 'package:tbtcenter/features/project_contract/domain/entities/project.dart';
import 'package:tbtcenter/features/project_contract/domain/repositories/project_repository.dart';
import 'package:tbtcenter/features/project_contract/presentation/providers/project_providers.dart';

import 'helpers.dart';

/// Tháng trước so với hôm nay, để luôn là tháng đã kết thúc, chốt sổ được.
final _lastMonth = () {
  final now = DateTime.now();
  return DateTime(now.year, now.month - 1).toIso8601String().substring(0, 7);
}();

class FakeFinanceRepository implements FinanceRepository {
  final closed = <String>[];
  final payments = <String>[];

  static const _supplier = Supplier(id: 'NCC02', name: 'Công ty CP Thép Minh An', purchased: 25080000, paid: 0, balance: 25080000);

  @override
  Future<FinanceYear> year(int year) async => FinanceYear(
        year: year,
        currency: 'VND',
        months: [
          if (year == DateTime.parse('$_lastMonth-01').year)
            MonthFigures(period: _lastMonth, revenue: 120000000, revenueUsd: 4800, cost: 20000000, costUsd: 800),
        ],
      );

  @override
  Future<List<Supplier>> suppliers() async => [_supplier];

  @override
  Future<SupplierDetail> supplier(String id) async => SupplierDetail(
        supplier: _supplier,
        imports: [LedgerEntry(date: DateTime(2025, 4, 14), amount: 25080000, currency: 'VND', label: 'Thép hộp 40x40')],
      );

  @override
  Future<void> recordPurchase({
    required String supplierId,
    required String materialName,
    required DateTime date,
    required String amount,
  }) async {}

  @override
  Future<void> recordPayment({required String supplierId, required DateTime date, required String amount, String? note}) async =>
      payments.add('$supplierId:$amount');

  @override
  Future<void> closePeriod(String period) async => closed.add(period);
}

class FakeProjectRepository implements ProjectRepository {
  static const _summary = ProjectSummary(
    id: '1XNN01',
    name: 'Xây nhà nhỏ',
    customerName: 'Công ty ABC',
    currency: 'VND',
    expectedAcceptance: 123870000,
    members: 4,
  );

  @override
  Future<List<ProjectSummary>> projects({String? search}) async => [_summary];

  @override
  Future<ProjectDetail> project(String id) async => const ProjectDetail(
        summary: _summary,
        customer: Customer(name: 'Công ty ABC'),
        members: [ProjectMember(employeeId: 'ANH98191KH', hours: 165)],
      );

  @override
  Future<List<MyProject>> myProjects() async => const [MyProject(projectId: '3XCC19', name: 'Xây cầu bê tông', hours: 154)];

  final accepted = <String>[];

  @override
  Future<ProjectDetail> accept(String id) async {
    accepted.add(id);
    return project(id);
  }
}

Future<FakeFinanceRepository> _pump(WidgetTester tester, List<String> roles, {FakeProjectRepository? projects}) async {
  final finance = FakeFinanceRepository();
  final overrides = await testOverrides(
    language: 'vi',
    store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles))),
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...overrides,
      financeRepositoryProvider.overrideWithValue(finance),
      projectRepositoryProvider.overrideWithValue(projects ?? FakeProjectRepository()),
    ],
    child: const TbtApp(),
  ));
  await tester.pumpAndSettle();
  return finance;
}

void main() {
  testWidgets('tài chính xem thu chi theo tháng và chốt sổ tháng trước', (tester) async {
    final finance = await _pump(tester, ['finance']);
    final year = DateTime.parse('$_lastMonth-01').year;
    await openHomeCard(tester, 'Tài chính');
    // Tháng 1 thì tháng trước nằm ở năm ngoái.
    if (year != DateTime.now().year) {
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
    }

    expect(find.text('Lợi nhuận'), findsOneWidget);
    // Biểu đồ cả năm (R25) có nhãn tháng và chú thích hai loại cột.
    expect(find.byType(GroupedBarChart), findsOneWidget);
    expect(find.descendant(of: find.byType(GroupedBarChart), matching: find.text('Doanh thu')), findsOneWidget);
    expect(find.textContaining('100.000.000'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Chốt sổ'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Chốt sổ'));
    await tester.pumpAndSettle();
    expect(finance.closed, [_lastMonth]);
  });

  testWidgets('đối chiếu công nợ nhà cung cấp, số tiền sai thì báo ngay', (tester) async {
    final finance = await _pump(tester, ['finance']);
    await openHomeCard(tester, 'Tài chính');
    await tester.tap(find.text('Nhà cung cấp'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Công ty CP Thép Minh An'));
    await tester.pumpAndSettle();
    expect(find.text('Thép hộp 40x40'), findsOneWidget);

    await tester.tap(find.text('Trả tiền'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Số tiền'), '-5');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Số tiền không hợp lệ'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Số tiền'), '3000000');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(finance.payments, ['NCC02:3000000']);
  });

  testWidgets('HR xem dự án nhưng không thấy tài chính, không thấy liên hệ khách', (tester) async {
    await _pump(tester, ['hr']);
    expect(find.text('Tài chính'), findsNothing);
    await openHomeCard(tester, 'Dự án và hợp đồng');
    await tester.tap(find.text('Xây nhà nhỏ'));
    await tester.pumpAndSettle();
    expect(find.text('ANH98191KH'), findsOneWidget);
    expect(find.text('Liên hệ của khách hàng chỉ bộ phận tài chính xem được'), findsOneWidget);
  });

  testWidgets('tài chính nghiệm thu dự án sau khi xác nhận; HR không thấy nút', (tester) async {
    final projects = FakeProjectRepository();
    await _pump(tester, ['finance'], projects: projects);
    await openHomeCard(tester, 'Dự án và hợp đồng');
    await tester.tap(find.text('Xây nhà nhỏ'));
    await tester.pumpAndSettle();
    expect(find.text('Đang thi công'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Nghiệm thu'));
    await tester.pumpAndSettle();
    expect(find.textContaining('123.870.000'), findsWidgets);
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();
    expect(projects.accepted, ['1XNN01']);
  });

  testWidgets('nhân viên xem dự án mình tham gia và số giờ', (tester) async {
    await _pump(tester, ['employee']);
    expect(find.text('Dự án và hợp đồng'), findsNothing);
    await openHomeCard(tester, 'Dự án của tôi');
    expect(find.text('Xây cầu bê tông'), findsOneWidget);
    expect(find.text('154 giờ'), findsOneWidget);
  });
}
