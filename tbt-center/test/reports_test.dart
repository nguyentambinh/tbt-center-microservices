/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/features/reports/data/report_repository.dart';
import 'package:tbtcenter/features/reports/domain/report_submission.dart';
import 'package:tbtcenter/features/reports/presentation/report_submissions_page.dart';

import 'helpers.dart';

class FakeReportRepository extends ReportRepository {
  FakeReportRepository() : super(Dio(), baseUrl: '');

  String status = 'submitted';
  final reviews = <String>[];

  ReportSubmission _report(String kind) => ReportSubmission(
        id: 1,
        kind: kind,
        period: '2026-09',
        status: status,
        data: kind == 'hr'
            ? const {'headcount': 65, 'departments': 23, 'unassigned': 12, 'nominations': {'pending': 1, 'approved': 2}}
            : const {'currency': 'VND', 'revenue': 1200000000, 'material': 400000000, 'payroll': 250000000, 'profit': 550000000},
        submittedBy: 'hr.vn',
        createdAt: DateTime(2026, 10, 2, 9),
        note: 'Tháng 9 tuyển thêm 5 kỹ sư',
      );

  @override
  Future<List<ReportSubmission>> list(String kind) async => [_report(kind)];

  @override
  Future<ReportSubmission> submit(String kind, {required String period, String? note}) async => _report(kind);

  @override
  Future<ReportSubmission> review(String kind, int id, {required String action, String? note}) async {
    reviews.add('$kind:$action');
    return _report(kind);
  }
}

Future<FakeReportRepository> _pump(WidgetTester tester, List<String> roles) async {
  final repository = FakeReportRepository();
  final overrides = await testOverrides(language: 'vi', store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles))));
  await tester.pumpWidget(ProviderScope(
    overrides: [...overrides, reportRepositoryProvider.overrideWith((ref, region) => repository)],
    child: const TbtApp(),
  ));
  await tester.pumpAndSettle();
  await openHomeCard(tester, 'Báo cáo gửi cấp trên');
  return repository;
}

void main() {
  testWidgets('HR thấy báo cáo đang chờ, chưa gửi được bản mới', (tester) async {
    await _pump(tester, ['hr']);
    expect(find.text('65 nhân viên, 23 phòng ban'), findsOneWidget);
    expect(find.text('Chờ xác nhận'), findsOneWidget);
    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.onPressed, isNull);
    // HR chỉ thấy tab nhân sự
    expect(find.text('Tài chính'), findsNothing);
  });

  testWidgets('Ban lãnh đạo xác nhận báo cáo tài chính', (tester) async {
    final repository = await _pump(tester, ['executive']);
    await tester.tap(find.text('Tài chính'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Lợi nhuận'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    expect(repository.reviews, ['finance:acknowledge']);
  });
}
