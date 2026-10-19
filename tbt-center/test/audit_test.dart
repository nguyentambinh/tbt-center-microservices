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
import 'package:tbtcenter/core/theme/role_gem.dart';
import 'package:tbtcenter/features/audit/domain/entities/audit.dart';
import 'package:tbtcenter/features/audit/domain/repositories/audit_repository.dart';
import 'package:tbtcenter/features/audit/presentation/providers/audit_providers.dart';

import 'helpers.dart';

class FakeAuditRepository implements AuditRepository {
  final regionsAsked = <String?>[];

  @override
  Future<List<AuditEvent>> events({String? region}) async {
    regionsAsked.add(region);
    return [
      AuditEvent(
        id: 20,
        region: 'de',
        sourceService: 'finance',
        eventType: 'FinancePeriodClosed',
        aggregateId: '2025-05',
        occurredAt: DateTime(2026, 10, 15, 11),
        hash: 'ab' * 32,
      ),
    ];
  }

  @override
  Future<ChainCheck> verify() async => const ChainCheck(checked: 26);

  @override
  Future<AuditExport> export({String? region}) async =>
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
    expect(find.text('FinancePeriodClosed'), findsOneWidget);
    // Kiểm toán viên không có tab "Ai đã truy cập".
    expect(find.text('Ai đã truy cập'), findsNothing);

    await tester.tap(find.byTooltip('Kiểm chuỗi băm'));
    await tester.pumpAndSettle();
    expect(find.text('Sổ còn nguyên vẹn, không dòng nào bị sửa'), findsOneWidget);
    expect(find.text('Đã kiểm 26 dòng'), findsOneWidget);
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Xuất cho kiểm toán'));
    await tester.pumpAndSettle();
    expect(find.text('Đã xuất 23 dòng'), findsOneWidget);
    expect(find.text('9fffd22d' * 8), findsOneWidget);
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đức'));
    await tester.pumpAndSettle();
    expect(audit.regionsAsked, [null, 'de']);
  });

  testWidgets('lãnh đạo xem được ai đã truy cập sổ', (tester) async {
    await _pump(tester, ['executive']);
    await openHomeCard(tester, 'Sổ kiểm toán');
    await tester.tap(find.text('Ai đã truy cập'));
    await tester.pumpAndSettle();
    expect(find.text('auditor.ext · Xuất cho kiểm toán'), findsOneWidget);
  });
}
