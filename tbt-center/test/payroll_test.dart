/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/features/payroll/domain/entities/payroll.dart';
import 'package:tbtcenter/features/payroll/domain/repositories/payroll_repository.dart';
import 'package:tbtcenter/features/payroll/presentation/providers/payroll_providers.dart';

import 'helpers.dart';

class FakePayrollRepository implements PayrollRepository {
  @override
  Future<PayrollSummary> myPayroll() async => PayrollSummary(
        baseSalary: 3710,
        currency: 'EUR',
        payslips: [
          Payslip(period: '2026-09', gross: 3896.5, net: 2415.83, currency: 'EUR', netUsd: 2809.1, paidOn: DateTime(2026, 10, 5)),
        ],
        bonusesPenalties: [BonusPenalty(date: DateTime(2026, 9, 12), isBonus: true, total: 444, currency: 'EUR')],
      );
}

void main() {
  testWidgets('nhân viên ở Đức xem phiếu lương bằng tiếng Đức, tiền EUR', (tester) async {
    final overrides = await testOverrides(
      language: 'de',
      store: MemorySessionStore(fakeSession(token: fakeJwt(roles: ['employee'], region: 'de'))),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [...overrides, payrollRepositoryProvider.overrideWithValue(FakePayrollRepository())],
      child: const TbtApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gehaltsabrechnungen'));
    await tester.pumpAndSettle();

    expect(find.text('September 2026'), findsOneWidget);
    expect(find.textContaining('2.415,83'), findsOneWidget);
    expect(find.textContaining('€'), findsWidgets);
    expect(find.text('Prämie'), findsOneWidget);
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
