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
import 'package:tbtcenter/features/project_contract/domain/entities/proposal.dart';
import 'package:tbtcenter/features/project_contract/domain/repositories/project_repository.dart';
import 'package:tbtcenter/features/project_contract/presentation/pages/project_charts_page.dart';
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
  Future<FinanceSeries> analytics(String granularity) async => FinanceSeries(
        granularity: granularity,
        currency: 'VND',
        points: const [
          FinancePoint(bucket: '2026-08', revenue: 900000000, material: 300000000, payroll: 200000000, profit: 400000000),
          FinancePoint(bucket: '2026-09', revenue: 1200000000, material: 400000000, payroll: 250000000, profit: 550000000),
        ],
      );

  @override
  Future<List<ProjectFinance>> projectRanking() async => const [
        ProjectFinance(projectId: '1XNN01', rank: 1, revenue: 123870000, cost: 50000000, profit: 73870000, margin: 0.596),
      ];

  @override
  Future<ProjectFinanceDetail> projectFinance(String projectId) async => ProjectFinanceDetail(
        projectId: projectId,
        currency: 'VND',
        revenue: 123870000,
        cost: 50000000,
        revenues: [(date: DateTime(2024, 6, 10), amount: 123870000, kind: 'acceptance')],
        materials: [(name: 'Thép phi 16', date: DateTime(2024, 2, 1), supplier: 'Công ty CP Thép Minh An', amount: 50000000)],
      );

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
  static final _summary = ProjectSummary(
    id: '1XNN01',
    name: 'Xây nhà nhỏ',
    customerName: 'Công ty ABC',
    currency: 'VND',
    expectedAcceptance: 123870000,
    members: 4,
    tier: 1,
    warning: 'red',
    progress: 0.8,
    startDate: DateTime(2026),
    endDate: DateTime(2026, 11, 20),
  );

  final tiers = <int?>[];

  @override
  Future<List<ProjectSummary>> projects({String? search, int? tier, DateTimeRange? range}) async {
    tiers.add(tier);
    return [_summary];
  }

  String proposalStatus = 'awaiting_executive';
  final responses = <String>[];

  ProjectProposal get _proposal => ProjectProposal(
        id: 7,
        status: proposalStatus,
        version: 2,
        createdBy: 'hr.vn',
        updatedAt: DateTime(2026, 10, 25),
        data: ProposalData(
          name: 'Cầu Rạch Chiếc',
          customerName: 'Sở Giao thông',
          value: 2500000000,
          currency: 'VND',
          startDate: DateTime(2026, 11),
          endDate: DateTime(2027, 6),
          memberIds: const ['E1', 'E2', 'E3'],
        ),
        events: [ProposalEvent(action: 'submitted', actor: 'hr.vn', at: DateTime(2026, 10, 25))],
      );

  @override
  Future<List<ProjectProposal>> proposals({String? status}) async => [_proposal];

  @override
  Future<ProjectProposal> proposal(int id) async => _proposal;

  @override
  Future<String> uploadFile({required String kind, required String fileName, required List<int> bytes}) async => 'proposals/$kind/x';

  @override
  Future<({ProposalData fields, String source})> extract({required String objectKey, required String fileName}) async =>
      (fields: const ProposalData(name: 'Cầu'), source: 'gemini');

  @override
  Future<MemberSuggestion> suggestMembers(ProposalData data, {required String language}) async =>
      const MemberSuggestion(tier: 1, minMembers: 2, memberIds: ['E1', 'E2'], employees: [StaffOption(id: 'E1', name: 'An'), StaffOption(id: 'E2', name: 'Bình')]);

  @override
  Future<ProjectProposal> propose(ProposalData data, {String? contractKey, String? contractName, String? imageKey}) async {
    responses.add('propose');
    return _proposal;
  }

  @override
  Future<ProjectProposal> respond(int id, {required String action, ProposalData? data, String? note}) async {
    responses.add(action);
    if (action == 'approve') proposalStatus = 'approved';
    return _proposal;
  }

  @override
  Future<ProjectDetail> project(String id) async => ProjectDetail(
        summary: _summary,
        customer: const Customer(name: 'Công ty ABC'),
        members: const [ProjectMember(employeeId: 'ANH98191KH', hours: 165)],
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
      regionProjectRepositoryProvider.overrideWith((ref, region) => projects ?? FakeProjectRepository()),
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
    // Ô số tiền chỉ nhận số: gõ dấu trừ hay chữ đều bị bỏ
    await tester.enterText(find.widgetWithText(TextFormField, 'Số tiền'), '-5abc');
    expect(find.widgetWithText(TextFormField, '5'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Số tiền'), '0');
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
    // Ảnh công trình ở đầu trang đẩy nội dung xuống, cuộn tới phần cần xem
    await tester.scrollUntilVisible(find.text('Liên hệ của khách hàng chỉ bộ phận tài chính xem được'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Liên hệ của khách hàng chỉ bộ phận tài chính xem được'), findsOneWidget);
    // Quản lý thấy mã nhân viên của người tham gia
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.textContaining('ANH98191KH'), findsWidgets);
  });

  testWidgets('tài chính nghiệm thu dự án sau khi xác nhận; HR không thấy nút', (tester) async {
    final projects = FakeProjectRepository();
    await _pump(tester, ['finance'], projects: projects);
    await openHomeCard(tester, 'Dự án và hợp đồng');
    await tester.tap(find.text('Xây nhà nhỏ'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Đang thi công'), 200);
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

  testWidgets('nhân viên bấm vào dự án của mình để xem chi tiết, không thấy tiền dự án', (tester) async {
    await _pump(tester, ['employee'], projects: _EmployeeProjects());
    await openHomeCard(tester, 'Dự án của tôi');
    await tester.tap(find.text('Xây cầu bê tông'));
    await tester.pumpAndSettle();
    expect(find.text('3XCC19'), findsOneWidget);
    expect(find.text('Giá trị dự án'), findsNothing);
    // Dòng của chính mình hiện "Tôi"
    await tester.scrollUntilVisible(find.text('Tôi'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Tôi'), findsOneWidget);
  });
  testWidgets('tài chính xem phân tích: lợi nhuận theo tháng, xếp hạng dự án, vật liệu', (tester) async {
    await _pump(tester, ['finance']);
    await openHomeCard(tester, 'Tài chính');
    await tester.tap(find.text('Phân tích'));
    await tester.pumpAndSettle();
    expect(find.text('Xếp hạng dự án theo lợi nhuận'), findsOneWidget);
    expect(find.text('Xây nhà nhỏ'), findsOneWidget);
    await tester.tap(find.text('Năm'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xây nhà nhỏ'));
    await tester.pumpAndSettle();
    expect(find.text('Thép phi 16'), findsOneWidget);
    expect(find.text('Vật liệu đã dùng'), findsOneWidget);
  });

  testWidgets('danh sách dự án có phân cấp, màu cảnh báo, tiến độ và lọc theo cấp', (tester) async {
    final projects = FakeProjectRepository();
    await _pump(tester, ['finance'], projects: projects);
    await openHomeCard(tester, 'Dự án và hợp đồng');
    expect(find.text('Cấp 1 · Nhỏ'), findsOneWidget);
    expect(find.text('Còn ≤ 1 tháng'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('Tạo dự án'), findsOneWidget);

    await tester.tap(find.text('Phân cấp'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cấp 3 · Lớn').last);
    await tester.pumpAndSettle();
    expect(projects.tiers.last, 3);
  });

  testWidgets('biểu đồ dự án: thanh ngang theo mã dự án, không còn 3D', (tester) async {
    await _pump(tester, ['executive']);
    await openHomeCard(tester, 'Dự án và hợp đồng');
    expect(find.text('Tạo dự án'), findsNothing);
    await tester.tap(find.byTooltip('Biểu đồ dự án'));
    await tester.pumpAndSettle();
    expect(find.text('1XNN01'), findsWidgets);
    await tester.tap(find.text('Tiến độ'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectBars), findsOneWidget);
    expect(find.text('1XNN01'), findsWidgets);
    expect(find.text('3D'), findsNothing);
  });

  testWidgets('tạo dự án: thiếu thông tin thì chưa sang bước kế', (tester) async {
    await _pump(tester, ['hr']);
    await openHomeCard(tester, 'Dự án và hợp đồng');
    await tester.tap(find.text('Tạo dự án'));
    await tester.pumpAndSettle();
    expect(find.text('Tải hợp đồng lên'), findsOneWidget);
    // Chưa tải hợp đồng thì chưa sang bước 2, chạm vào bước sau cũng không nhảy
    expect(find.text('Bắt buộc tải hợp đồng (PDF, Word) để AI đọc ra thông tin dự án'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Tiếp').first).onPressed, isNull);
    await tester.tap(find.text('Gửi Ban lãnh đạo').first);
    await tester.pumpAndSettle();
    expect(find.text('Tải hợp đồng lên'), findsOneWidget);
  });

  testWidgets('Ban lãnh đạo duyệt đề xuất dự án', (tester) async {
    final projects = FakeProjectRepository();
    await _pump(tester, ['executive'], projects: projects);
    await openHomeCard(tester, 'Dự án và hợp đồng');
    await tester.tap(find.byTooltip('Đề xuất dự án'));
    await tester.pumpAndSettle();
    expect(find.text('Chờ Ban lãnh đạo'), findsOneWidget);
    await tester.tap(find.text('Cầu Rạch Chiếc'));
    await tester.pumpAndSettle();
    expect(find.text('Sửa đề xuất'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Duyệt'));
    await tester.pumpAndSettle();
    expect(projects.responses, ['approve']);
  });

  testWidgets('đề xuất đang chờ lãnh đạo thì bên lập chỉ xem, không duyệt được', (tester) async {
    await _pump(tester, ['hr']);
    await openHomeCard(tester, 'Dự án và hợp đồng');
    await tester.tap(find.byTooltip('Đề xuất dự án'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cầu Rạch Chiếc'));
    await tester.pumpAndSettle();
    expect(find.text('Đang chờ bên kia trả lời'), findsOneWidget);
    expect(find.text('Đồng ý bản sửa'), findsNothing);
  });

  test('luật đề xuất ở app khớp server: phân cấp, thời gian, số người', () {
    final today = DateTime(2026, 10, 25);
    final base = ProposalData(name: 'A', customerName: 'B', value: 2500000000, currency: 'VND', startDate: DateTime(2026, 11), endDate: DateTime(2027, 6), memberIds: const ['1', '2', '3']);
    expect(base.errors(rateToUsd: 25000, today: today), isEmpty);
    expect(base.withMembers(const ['1']).errors(rateToUsd: 25000, today: today), contains('too_few_members'));
    expect(projectTier(2500000000 / 25000), 2);
    expect(projectTier(900000), 4);
  });
}

/// Server trả chi tiết dự án cho nhân viên tham gia nhưng bỏ tiền dự án
class _EmployeeProjects extends FakeProjectRepository {
  @override
  Future<ProjectDetail> project(String id) async => ProjectDetail(
    summary: ProjectSummary(id: '3XCC19', name: 'Xây cầu bê tông', currency: 'VND', members: 1),
    members: [ProjectMember(employeeId: 'Anh8715OP', name: 'Nguyễn Văn Anh', isMe: true, hours: 154)],
  );
}
