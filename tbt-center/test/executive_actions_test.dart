/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/features/hr/data/direct_actions_repository.dart';
import 'package:tbtcenter/features/hr/presentation/widgets/executive_actions.dart';
import 'package:tbtcenter/l10n/app_localizations.dart';

/// Ghi lại lời gọi làm thẳng thay cho server
class FakeDirectActions extends DirectActionsRepository {
  FakeDirectActions() : super(Dio(), baseUrl: '');

  final calls = <String>[];

  @override
  Future<({double? baseSalary, String? currency})> salary(String employeeId) async => (baseSalary: 15000000.0, currency: 'VND');

  @override
  Future<void> setBaseSalary(String employeeId, {required double amount, String? reason}) async => calls.add('salary:$employeeId:${amount.toInt()}:$reason');

  @override
  Future<void> addBonusPenalty(String employeeId, {required bool bonus, required double amount, String? reason}) async =>
      calls.add('${bonus ? 'bonus' : 'penalty'}:$employeeId:${amount.toInt()}:$reason');
}

Future<FakeDirectActions> _pump(WidgetTester tester) async {
  final fake = FakeDirectActions();
  await tester.pumpWidget(ProviderScope(
    overrides: [directActionsProvider.overrideWithValue(fake)],
    child: MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(actions: [ExecutiveActionsMenu(employeeId: 'E2', name: 'Lê Minh Thư', onDone: () {})]),
      ),
    ),
  ));
  return fake;
}

void main() {
  testWidgets('đổi lương cơ bản: hiện lương hiện tại, áp dụng ngay', (tester) async {
    final fake = await _pump(tester);
    await tester.tap(find.byTooltip('Làm thẳng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đổi lương cơ bản'));
    await tester.pumpAndSettle();
    expect(find.text('Lương cơ bản hiện tại: 15.000.000 VND'), findsOneWidget);
    expect(find.textContaining('không qua ai duyệt'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Lương cơ bản mới'), '18000000');
    await tester.enterText(find.widgetWithText(TextField, 'Lý do (ghi vào sổ kiểm toán)'), 'Điều chỉnh theo thị trường');
    await tester.tap(find.text('Áp dụng ngay'));
    await tester.pumpAndSettle();
    expect(fake.calls, ['salary:E2:18000000:Điều chỉnh theo thị trường']);
  });

  testWidgets('phạt phải có lý do mới áp dụng được', (tester) async {
    final fake = await _pump(tester);
    await tester.tap(find.byTooltip('Làm thẳng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thưởng, phạt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Phạt'));
    await tester.enterText(find.widgetWithText(TextField, 'Số tiền (theo tiền lương của nhân viên)'), '500000');
    await tester.pumpAndSettle();
    final apply = find.widgetWithText(FilledButton, 'Áp dụng ngay');
    expect(tester.widget<FilledButton>(apply).onPressed, isNull);
    await tester.enterText(find.widgetWithText(TextField, 'Lý do (bắt buộc)'), 'Đi trễ nhiều lần');
    await tester.pumpAndSettle();
    await tester.tap(apply);
    await tester.pumpAndSettle();
    expect(fake.calls, ['penalty:E2:500000:Đi trễ nhiều lần']);
  });
}
