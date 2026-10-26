/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/core/export/table_export.dart';
import 'package:tbtcenter/features/payroll/domain/entities/payroll.dart';
import 'package:tbtcenter/features/payroll/domain/repositories/payroll_repository.dart';
import 'package:tbtcenter/features/payroll/presentation/pages/payroll_runs_page.dart';
import 'package:tbtcenter/features/payroll/presentation/providers/payroll_providers.dart';

import 'helpers.dart';

class FakePayrollRepository implements PayrollRepository {
  String raiseStatus = 'awaiting_hr';
  final actions = <String>[];
  final requested = <double>[];

  @override
  Future<PayrollSummary> myPayroll() async => PayrollSummary(
        baseSalary: 3710,
        currency: 'EUR',
        payslips: [
          Payslip(period: '2026-08', gross: 3710, net: 2300.2, currency: 'EUR'),
          Payslip(
            period: '2026-09',
            gross: 3896.5,
            net: 2415.83,
            currency: 'EUR',
            netUsd: 2809.1,
            paidOn: DateTime(2026, 10, 5),
            base: 3710,
            overtime: 186.5,
            bonus: 0,
            insurance: 779.3,
            tax: 701.37,
          ),
        ],
        bonusesPenalties: [BonusPenalty(date: DateTime(2026, 9, 12), isBonus: true, total: 444, currency: 'EUR')],
      );

  RaiseRequest get _request => RaiseRequest(
        id: 1,
        employeeId: 'E1',
        currentSalary: 3710,
        requested: 4000,
        proposed: 4000,
        currency: 'EUR',
        reason: 'Phụ trách thêm công trường Bình Dương',
        status: raiseStatus,
        updatedAt: DateTime(2026, 10, 25),
      );

  @override
  Future<List<RaiseRequest>> raiseRequests({String? status}) async => [_request];

  @override
  Future<RaiseRequest> requestRaise({required double amount, required String reason}) async {
    requested.add(amount);
    return _request;
  }

  @override
  Future<RaiseRequest> respondRaise(int id, {required String action, double? amount, String? note}) async {
    actions.add('$action:${amount ?? ''}');
    return _request;
  }
}

Future<FakePayrollRepository> _pump(WidgetTester tester, List<String> roles, {String language = 'vi', String region = 'vn', String? employeeId}) async {
  final repository = FakePayrollRepository();
  final overrides = await testOverrides(
    language: language,
    store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles, region: region, employeeId: employeeId))),
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...overrides,
      payrollRepositoryProvider.overrideWithValue(repository),
      regionPayrollRepositoryProvider.overrideWith((ref, region) => repository),
    ],
    child: const TbtApp(),
  ));
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('nhân viên ở Đức xem phiếu lương bằng tiếng Đức, tiền EUR', (tester) async {
    await _pump(tester, ['employee'], language: 'de', region: 'de');
    await tester.tap(find.text('Gehaltsabrechnungen'));
    await tester.pumpAndSettle();

    expect(find.text('September 2026'), findsOneWidget);
    expect(find.textContaining('2.415,83'), findsOneWidget);
    expect(find.textContaining('€'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Prämie'), 300, scrollable: find.byType(Scrollable).last);
    expect(find.text('Prämie'), findsOneWidget);
  });

  testWidgets('phiếu lương chi tiết: tăng ca, bảo hiểm, thuế và biểu đồ qua các kỳ', (tester) async {
    await _pump(tester, ['employee']);
    await openHomeCard(tester, 'Phiếu lương');
    expect(find.text('Lương qua các kỳ'), findsOneWidget);
    expect(find.text('Tăng ca'), findsOneWidget);
    expect(find.text('Bảo hiểm'), findsOneWidget);
    expect(find.text('Thuế thu nhập'), findsOneWidget);
  });

  testWidgets('nhân viên gửi đề xuất tăng lương, mức thấp hơn lương hiện tại bị chặn', (tester) async {
    final repository = await _pump(tester, ['employee'], employeeId: 'E1');
    await openHomeCard(tester, 'Đề xuất tăng lương');
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Đề xuất tăng lương'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Lương cơ bản đề xuất'), '3000');
    await tester.enterText(find.widgetWithText(TextField, 'Lý do (thành tích, trách nhiệm mới...)'), 'Hoàn thành vượt tiến độ');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Gửi')).onPressed, isNull);

    await tester.enterText(find.widgetWithText(TextField, 'Lương cơ bản đề xuất'), '4200');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Gửi'));
    await tester.pumpAndSettle();
    expect(repository.requested, [4200]);
  });

  testWidgets('HR chuyển đề xuất lên, không được hạ mức', (tester) async {
    final repository = await _pump(tester, ['hr']);
    await openHomeCard(tester, 'Đề xuất tăng lương');
    expect(find.text('Chờ HR xem'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Chuyển lên duyệt'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Lương cơ bản đề xuất'), '3900');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Gửi')).onPressed, isNull);
    await tester.enterText(find.widgetWithText(TextField, 'Lương cơ bản đề xuất'), '4100');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Gửi'));
    await tester.pumpAndSettle();
    expect(repository.actions, ['forward:4100.0']);
  });

  testWidgets('quản trị khu vực không duyệt tăng lương, chỉ Ban lãnh đạo duyệt', (tester) async {
    await _pump(tester, ['admin']);
    // Quản trị chỉ lo cấu hình, không có mục tăng lương
    expect(find.text('Đề xuất tăng lương'), findsNothing);
  });

  testWidgets('Ban lãnh đạo duyệt đề xuất đang chờ cấp trên', (tester) async {
    final repository = await _pump(tester, ['executive']);
    repository.raiseStatus = 'awaiting_approver';
    await openHomeCard(tester, 'Đề xuất tăng lương');
    await tester.tap(find.widgetWithText(FilledButton, 'Duyệt'));
    await tester.pumpAndSettle();
    expect(repository.actions, ['approve:']);
  });

  test('chỉ chốt lương các kỳ đã tới hạn: tháng M từ ngày 10 tháng M+1', () {
    expect(payablePeriods(DateTime(2026, 10, 25)), ['2026-09', '2026-08']);
    expect(payablePeriods(DateTime(2026, 11, 9)), ['2026-09', '2026-08']);
    expect(payablePeriods(DateTime(2026, 11, 10)), ['2026-10', '2026-09']);
    expect(nextOpenPeriod(DateTime(2026, 10, 25)), '2026-10');
    expect(payrollOpenDate('2026-12'), DateTime(2027, 1, 10));
  });

  test('tệp Excel có đủ trang tính, chữ tiếng Việt và cột số', () {
    final bytes = buildXlsx(const ExportTable(
      title: 'Phiếu lương',
      headers: ['Kỳ', 'Thực nhận'],
      rows: [
        ['2026-09', 2415.83],
      ],
    ));
    final archive = ZipDecoder().decodeBytes(bytes);
    final sheet = String.fromCharCodes(archive.findFile('xl/worksheets/sheet1.xml')!.content as List<int>);
    expect(archive.findFile('[Content_Types].xml'), isNotNull);
    expect(sheet, contains('<v>2415.83</v>'));
    expect(const ExportTable(title: 'Thu chi năm 2026', headers: [], rows: []).fileStem, 'thu_chi_nam_2026');
  });

  testWidgets('ứng viên không thấy thẻ phiếu lương', (tester) async {
    final overrides = await testOverrides(
      language: 'vi',
      store: MemorySessionStore(fakeSession(token: fakeJwt(roles: ['candidate']))),
    );
    await tester.pumpWidget(ProviderScope(overrides: overrides, child: const TbtApp()));
    await tester.pumpAndSettle();
    expect(find.text('Phiếu lương'), findsNothing);
  });
}
