/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/core/theme/role_gem.dart';
import 'package:tbtcenter/core/widgets/isometric_bars.dart';
import 'package:tbtcenter/features/audit/domain/entities/audit.dart';
import 'package:tbtcenter/features/audit/domain/repositories/audit_repository.dart';
import 'package:tbtcenter/features/audit/presentation/providers/audit_providers.dart';

import 'helpers.dart';

class FakeAuditRepository implements AuditRepository {
  final regionsAsked = <String?>[];
  final queries = <AuditQuery>[];

  @override
  Future<List<AuditEvent>> events(AuditQuery query) async {
    regionsAsked.add(query.region);
    queries.add(query);
    return [
      AuditEvent(
        id: 20,
        region: 'de',
        sourceService: 'finance',
        eventType: 'FinancePeriodClosed',
        aggregateId: '2025-05',
        occurredAt: DateTime(2026, 10, 15, 11),
        hash: 'ab' * 32,
        anomalies: const ['after_hours'],
      ),
    ];
  }

  @override
  Future<AuditStats> stats(AuditQuery query) async => AuditStats(
        total: 40,
        afterHours: 3,
        failures: 2,
        byType: const [(key: 'FinancePeriodClosed', count: 12)],
        byRegion: const [(key: 'vn', count: 30), (key: 'de', count: 10)],
        byService: const [(key: 'finance', count: 40)],
        byDay: const [(key: '2026-10-14', count: 15), (key: '2026-10-15', count: 25)],
        byLocalHour: List.filled(24, 1),
      );

  @override
  Future<ChainCheck> verify() async => const ChainCheck(checked: 26);

  @override
  Future<AnomalyExplanation> explain(int id, {required String language}) async => (
        summary: 'Chốt sổ tháng 5 lúc nửa đêm',
        whyFlagged: 'Thao tác ngoài giờ làm việc',
        risk: 'medium',
        checks: const ['Ai đã chốt sổ', 'Có ủy quyền không'],
        likelyBenign: 'Kế toán làm thêm cuối kỳ',
      );

  @override
  Future<AuditExport> export(AuditQuery query) async =>
      AuditExport(rowCount: 23, checksum: '9fffd22d' * 8, csv: 'id,region\n');

  @override
  Future<List<AccessEntry>> accessLog() async => [
        AccessEntry(username: 'auditor.ext', action: 'export', accessedAt: DateTime(2026, 10, 15, 12), rowCount: 23),
      ];
}

Future<FakeAuditRepository> _pump(WidgetTester tester, List<String> roles) async {
  final audit = FakeAuditRepository();
  final overrides = await testOverrides(
    language: 'vi',
    store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles))),
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [...overrides, auditRepositoryProvider.overrideWithValue(audit)],
    child: const TbtApp(),
  ));
  await tester.pumpAndSettle();
  return audit;
}

void main() {
  testWidgets('kiểm toán viên chỉ thấy sổ kiểm toán, không thấy chấm công, phiếu lương', (tester) async {
    await _pump(tester, ['auditor']);
    expect(find.text('Sổ kiểm toán'), findsOneWidget);
    expect(find.text('Chấm công & nghỉ phép'), findsNothing);
    expect(find.text('Phiếu lương'), findsNothing);
    expect(RoleGem.forRole('auditor'), RoleGem.amethyst);
  });

  testWidgets('kiểm chuỗi băm, xuất có mã SHA-256, lọc theo khu vực', (tester) async {
    final audit = await _pump(tester, ['auditor']);
    await openHomeCard(tester, 'Sổ kiểm toán');
    // Tên sự kiện dễ đọc thay cho tên kỹ thuật
    expect(find.text('Chốt sổ tài chính tháng'), findsOneWidget);
    // Kiểm toán viên không có tab "Ai đã truy cập".
    expect(find.text('Ai đã truy cập'), findsNothing);

    await tester.tap(find.byTooltip('Kiểm chuỗi băm'));
    await tester.pumpAndSettle();
    expect(find.text('Sổ còn nguyên vẹn, không dòng nào bị sửa'), findsOneWidget);
    expect(find.text('Đã kiểm 26 dòng'), findsOneWidget);
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Xuất CSV có mã SHA-256'));
    await tester.pumpAndSettle();
    // Lọc trước khi xuất
    await tester.tap(find.text('Xuất báo cáo'));
    await tester.pumpAndSettle();
    expect(find.text('Đã xuất 23 dòng'), findsOneWidget);
    expect(find.text('9fffd22d' * 8), findsOneWidget);
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đức'));
    await tester.pumpAndSettle();
    expect(audit.regionsAsked, [null, 'de']);
  });

  testWidgets('bấm một dòng xem chi tiết, AI giải thích điểm bất thường', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await _pump(tester, ['auditor']);
    await openHomeCard(tester, 'Sổ kiểm toán');
    await tester.tap(find.text('Chốt sổ tài chính tháng'));
    await tester.pumpAndSettle();
    expect(find.text('Vì sao bị đánh dấu bất thường'), findsOneWidget);
    await tester.ensureVisible(find.text('AI phân tích điểm bất thường'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AI phân tích điểm bất thường'));
    await tester.pumpAndSettle();
    expect(find.text('Chốt sổ tháng 5 lúc nửa đêm'), findsOneWidget);
    expect(find.text('Rủi ro vừa'), findsOneWidget);
    expect(find.text('• Có ủy quyền không'), findsOneWidget);
  });

  testWidgets('lọc bất thường, xem biểu đồ 2D rồi 3D', (tester) async {
    final audit = await _pump(tester, ['auditor']);
    await openHomeCard(tester, 'Sổ kiểm toán');
    await tester.tap(find.text('Ngoài giờ (22h–6h)'));
    await tester.pumpAndSettle();
    expect(audit.queries.last.anomaly, 'after_hours');
    expect(find.byIcon(Icons.nightlight_outlined), findsOneWidget);
    await tester.tap(find.text('Biểu đồ'));
    await tester.pumpAndSettle();
    expect(find.text('Tổng sự kiện'), findsOneWidget);
    expect(find.text('40'), findsOneWidget);
    expect(find.byType(BarChart), findsWidgets);
    await tester.tap(find.text('3D'));
    await tester.pumpAndSettle();
    expect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is IsometricBarsPainter), findsWidgets);
  });

  testWidgets('lãnh đạo xem được ai đã truy cập sổ', (tester) async {
    await _pump(tester, ['executive']);
    await openHomeCard(tester, 'Sổ kiểm toán');
    await tester.tap(find.text('Ai đã truy cập'));
    await tester.pumpAndSettle();
    expect(find.text('auditor.ext · Xuất cho kiểm toán'), findsOneWidget);
  });
}
