/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/core/widgets/isometric_bars.dart';
import 'package:tbtcenter/features/approvals/approval_inbox_page.dart';
import 'package:tbtcenter/features/payroll/data/repositories/payroll_repository_impl.dart';
import 'package:tbtcenter/features/payroll/domain/entities/payroll.dart';
import 'package:tbtcenter/features/payroll/presentation/providers/payroll_providers.dart';

import 'helpers.dart';

class FakeRaiseRepository extends PayrollRepositoryImpl {
  FakeRaiseRepository() : super(Dio(), baseUrl: '');

  final actions = <String>[];

  @override
  Future<RaiseRequest> respondRaise(int id, {required String action, double? amount, String? note}) async {
    actions.add('$id:$action:$note');
    throw StateError('not needed');
  }
}

final _inbox = (
  items: [
    ApprovalItem(kind: ApprovalKind.project, region: 'vn', id: '7', title: 'Nhà xưởng Bình Dương', detail: 'Công ty An Phát · 2.000.000.000 VND', updatedAt: DateTime(2026, 10, 24)),
    ApprovalItem(kind: ApprovalKind.promotion, region: 'de', id: '3', title: 'Anna Weber', detail: 'Teamleiterin|10', updatedAt: DateTime(2026, 10, 23)),
    ApprovalItem(kind: ApprovalKind.raise, region: 'vn', id: '5', title: 'NV001', detail: '15.000.000 → 17.000.000 VND', updatedAt: DateTime(2026, 10, 22)),
  ],
  unreachable: ['za'],
);

Future<FakeRaiseRepository> _pump(WidgetTester tester) async {
  final payroll = FakeRaiseRepository();
  final overrides = await testOverrides(language: 'vi', store: MemorySessionStore(fakeSession(token: fakeJwt(roles: ['executive', 'group']))));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...overrides,
      approvalInboxProvider.overrideWith((ref) async => _inbox),
      regionPayrollRepositoryProvider.overrideWith((ref, region) => payroll),
    ],
    child: const TbtApp(),
  ));
  await tester.pumpAndSettle();
  await openHomeCard(tester, 'Hộp duyệt chung');
  return payroll;
}

void main() {
  testWidgets('gom đề xuất mọi khu vực, lọc theo loại, báo khu vực không phản hồi', (tester) async {
    await _pump(tester);
    expect(find.text('Chưa lấy được dữ liệu của: Nam Phi'), findsOneWidget);
    await tester.dragUntilVisible(find.text('3 đề xuất chờ duyệt'), find.byType(ListView).first, const Offset(0, -200));
    await tester.dragUntilVisible(find.text('Lên Teamleiterin, tăng 10% lương'), find.byType(ListView).first, const Offset(0, -200));
    await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.byType(BarChart), findsOneWidget);
    await tester.tap(find.text('3D'));
    await tester.pumpAndSettle();
    expect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is IsometricBarsPainter), findsOneWidget);
    await tester.tap(find.text('Tăng lương (1)'));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(find.text('1 đề xuất chờ duyệt'), find.byType(ListView).first, const Offset(0, -200));
    expect(find.text('Nhà xưởng Bình Dương'), findsNothing);
  });

  testWidgets('duyệt tăng lương ngay trong hộp, kèm ghi chú', (tester) async {
    final payroll = await _pump(tester);
    await tester.tap(find.text('Tăng lương (1)'));
    await tester.pumpAndSettle();
    final approve = find.widgetWithText(FilledButton, 'Duyệt');
    await tester.dragUntilVisible(approve, find.byType(ListView).first, const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(approve);
    await tester.pumpAndSettle();
    expect(find.text('Duyệt NV001?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Hoàn thành tốt dự án');
    await tester.tap(find.widgetWithText(FilledButton, 'Duyệt').last);
    await tester.pumpAndSettle();
    expect(payroll.actions, ['5:approve:Hoàn thành tốt dự án']);
  });
}
