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
import 'package:tbtcenter/core/error/app_failure.dart';
import 'package:tbtcenter/features/payroll/domain/entities/payroll_run.dart';
import 'package:tbtcenter/features/payroll/domain/repositories/payroll_run_repository.dart';
import 'package:tbtcenter/features/payroll/presentation/providers/payroll_run_providers.dart';
import 'package:tbtcenter/features/report/domain/entities/group_report.dart';
import 'package:tbtcenter/features/report/domain/repositories/report_repository.dart';
import 'package:tbtcenter/features/report/presentation/providers/report_providers.dart';

import 'helpers.dart';

final _failedRun = PayrollRun(
  id: 'R1',
  period: '2026-11',
  status: 'failed',
  steps: [
    SagaStep(step: 'pay', status: 'failed', detail: 'Bank 503', at: DateTime(2026, 10, 15)),
    SagaStep(step: 'compensate', status: 'done', detail: 'Đã hủy 65 phiếu', at: DateTime(2026, 10, 15)),
  ],
);

class FakeRunRepository implements PayrollRunRepository {
  final retried = <String>[];

  @override
  Future<List<PayrollRun>> runs() async => [_failedRun];

  @override
  Future<PayrollRun> run(String id) async => _failedRun;

  @override
  Future<PayrollRun> start(String period) async =>
      throw const AppFailure(FailureKind.validation, serverCode: 'run_exists');

  @override
  Future<PayrollRun> retry(String id) async {
    retried.add(id);
    return _failedRun;
  }
}

class FakeReportRepository implements ReportRepository {
  @override
  Future<GroupReport> overview() async => const GroupReport(
        projectedUntilEvent: 14,
        work: [RegionWork(region: 'vn', period: '2026-10', employees: 1, hours: 8.75, overtimeHours: 2.5)],
        payroll: [
          RegionPayroll(region: 'vn', period: '2026-10', employees: 65, totalUsd: 31180.18),
          RegionPayroll(region: 'de', period: '2026-10', employees: 40, totalUsd: 120376.26),
        ],
      );
}

Future<FakeRunRepository> pumpFinance(WidgetTester tester, List<String> roles) async {
  final runs = FakeRunRepository();
  final overrides = await testOverrides(
    language: 'vi',
    store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles))),
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...overrides,
      payrollRunRepositoryProvider.overrideWithValue(runs),
      reportRepositoryProvider.overrideWithValue(FakeReportRepository()),
    ],
    child: const TbtApp(),
  ));
  await tester.pumpAndSettle();
  return runs;
}

void main() {
  testWidgets('tài chính xem đợt chốt lỗi, thấy bước bù trừ và chạy lại', (tester) async {
    final runs = await pumpFinance(tester, ['finance']);
    await openHomeCard(tester, 'Chốt lương');
    expect(find.text('Lỗi, đã hoàn tác'), findsOneWidget);

    await tester.tap(find.text('2026-11'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Hoàn tác phần chưa chi'), findsOneWidget);
    await tester.tap(find.text('Chạy lại'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(runs.retried, ['R1']);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('lãnh đạo xem báo cáo tập đoàn, cộng tổng USD theo kỳ', (tester) async {
    await pumpFinance(tester, ['executive']);
    await openHomeCard(tester, 'Báo cáo tập đoàn');
    expect(find.text('Đức'), findsOneWidget);
    expect(find.textContaining('151.556,44'), findsOneWidget);
    expect(find.text('Số liệu tới sự kiện #14'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('8,75 giờ · tăng ca 2,5 giờ'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Điều kiện làm việc'), findsOneWidget);
  });

  testWidgets('nhân viên thường không thấy chốt lương, báo cáo tập đoàn', (tester) async {
    await pumpFinance(tester, ['employee']);
    expect(find.text('Chốt lương'), findsNothing);
    expect(find.text('Báo cáo tập đoàn'), findsNothing);
  });
}
