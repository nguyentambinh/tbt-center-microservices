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
import 'package:tbtcenter/features/recruitment/domain/entities/candidate.dart';
import 'package:tbtcenter/features/recruitment/domain/repositories/candidate_repository.dart';
import 'package:tbtcenter/features/recruitment/presentation/providers/candidate_providers.dart';

import 'package:tbtcenter/features/recruitment/presentation/pages/my_application_page.dart';

import 'helpers.dart';

class FakeCandidateRepository implements CandidateRepository {
  Candidate? mine;
  final moves = <String>[];
  String? detailStatus;

  Candidate _candidate(String status) => Candidate(
        id: 'C1',
        fullName: 'Lê Minh Thư',
        status: status,
        appliedPosition: 'Kỹ sư xây dựng',
        history: [StageChange(status: status, changedAt: DateTime(2026, 10, 15))],
      );

  final hired = <String>[];
  final offers = <HireOffer?>[];
  final responses = <String>[];
  Interview? detailInterview;

  @override
  Future<HireResult> hire(String id, {HireOffer? offer}) async {
    hired.add(id);
    offers.add(offer);
    return const HireResult(employeeId: 'TBTC1', login: 'thu@gmail.com', temporaryPassword: 'Tam123');
  }

  @override
  Future<Candidate> reconsider(String id) async {
    moves.add('reconsider');
    return _candidate('screening');
  }

  @override
  Future<Candidate> scheduleInterview(String id, {required DateTime at, String? location, String? note}) async {
    responses.add('schedule');
    return _candidate('interview');
  }

  @override
  Future<Candidate> respondInterview(String id, {required String action, DateTime? at, String? note}) async {
    responses.add('hr:$action');
    return _candidate('interview');
  }

  @override
  Future<Candidate> respondMyInterview({required String action, DateTime? at, String? note}) async {
    responses.add('me:$action');
    return mine!;
  }

  @override
  Future<Candidate> uploadMinutes(String id, {required String fileName, required List<int> bytes}) async => _candidate('interviewed');

  @override
  Future<Uri> minutesUrl(String id) async => Uri.parse('http://localhost:3900/minutes.docx');

  @override
  Future<OfferSuggestion> offerSuggestion(String id, {required String language}) async => const OfferSuggestion(
        departments: [(id: 'PB1', name: 'Phòng Kỹ thuật', company: null), (id: 'PB2', name: 'Phòng Kế toán', company: null)],
        departmentId: 'PB1',
        baseSalary: 15000000,
        currency: 'VND',
        reason: 'Hợp với phòng Kỹ thuật',
        source: 'gemini',
      );

  @override
  Future<Candidate?> myApplication() async => mine;

  @override
  Future<Candidate> saveMyApplication(CandidateInput input) async =>
      mine = _candidate('submitted');

  @override
  Future<Candidate> uploadCv(List<int> pdf) async => mine = _candidate('submitted');

  @override
  Future<Uri> cvDownloadUrl(String candidateId) async => Uri.parse('http://localhost:3900/cv.pdf');

  @override
  Future<List<Candidate>> candidates({String? status}) async => [_candidate('submitted')];

  @override
  Future<Candidate> candidate(String id) async => Candidate(
        id: 'C1',
        fullName: 'Lê Minh Thư',
        status: detailStatus ?? (moves.isEmpty ? 'analyzed' : moves.last),
        email: 'thu@gmail.com',
        interview: detailInterview,
        hasCv: true,
        aiSummary: const {
          'headline': 'Kỹ sư kết cấu 6 năm kinh nghiệm',
          'yearsOfExperience': 6,
          'skills': ['AutoCAD', 'SAP2000'],
          'suitablePositions': ['Kỹ sư kết cấu'],
          'strengths': <String>[],
          'questionsForInterview': ['Kinh nghiệm thiết kế cầu thép'],
        },
      );

  @override
  Future<Candidate> changeStage(String id, {required String status, String? note}) async {
    moves.add(status);
    return _candidate(status);
  }
}

Future<FakeCandidateRepository> pumpWithRoles(WidgetTester tester, List<String> roles) async {
  final repository = FakeCandidateRepository();
  final overrides = await testOverrides(
    language: 'vi',
    store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles))),
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...overrides,
      candidateRepositoryProvider.overrideWithValue(repository),
      pickPdfProvider.overrideWithValue(() async => (name: 'CV_LeMinhThu.pdf', bytes: const [37, 80, 68, 70])),
    ],
    child: const TbtApp(),
  ));
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('ứng viên chưa nộp thì thấy form, nộp xong thấy tiến trình', (tester) async {
    await pumpWithRoles(tester, ['candidate']);
    await openHomeCard(tester, 'Hồ sơ ứng tuyển của tôi');
    expect(find.text('Bạn chưa nộp hồ sơ nào'), findsOneWidget);

    // Họ tên lấy từ tài khoản, chưa có CV thì chưa lưu được
    expect(find.text('Thông tin từ tài khoản đăng ký'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Nộp hồ sơ')).onPressed, isNull);
    await tester.tap(find.text('Đính kèm CV (PDF, tối đa 10 MB)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nộp hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.text('Tiến trình'), findsOneWidget);
    expect(find.text('Sửa hồ sơ'), findsOneWidget);
  });

  testWidgets('HR chỉ chuyển hồ sơ tới bước kế tiếp', (tester) async {
    final repository = await pumpWithRoles(tester, ['hr']);
    await openHomeCard(tester, 'Ứng viên');
    await tester.tap(find.text('Lê Minh Thư'));
    await tester.pumpAndSettle();

    expect(find.text('Tóm tắt của AI'), findsOneWidget);
    expect(find.text('SAP2000'), findsOneWidget);
    expect(find.text('Mở CV'), findsOneWidget);
    // AI đã đọc: chưa hẹn phỏng vấn được, phải sàng lọc trước
    expect(find.text('Hẹn phỏng vấn'), findsNothing);

    final next = find.text('Chuyển sang sàng lọc');
    await tester.scrollUntilVisible(next, 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(repository.moves, ['screening']);
    expect(find.text('Hẹn phỏng vấn'), findsOneWidget);
  });

  testWidgets('ứng viên đề xuất giờ thì HR thấy nút xác nhận', (tester) async {
    final repository = await pumpWithRoles(tester, ['hr']);
    repository
      ..detailStatus = 'interview'
      ..detailInterview = Interview(scheduledAt: DateTime.now().add(const Duration(days: 2)), state: 'awaiting_hr', proposedBy: 'candidate', location: 'Tầng 5');
    await openHomeCard(tester, 'Ứng viên');
    await tester.tap(find.text('Lê Minh Thư'));
    await tester.pumpAndSettle();

    expect(find.text('Chờ HR xác nhận lại'), findsOneWidget);
    expect(find.text('Tải biên bản phỏng vấn'), findsNothing);
    final confirm = find.text('Xác nhận giờ này');
    await tester.ensureVisible(confirm);
    await tester.pumpAndSettle();
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(repository.responses, ['hr:confirm']);
  });

  testWidgets('chưa tới giờ phỏng vấn thì chưa tải biên bản được', (tester) async {
    final repository = await pumpWithRoles(tester, ['hr']);
    repository
      ..detailStatus = 'interview'
      ..detailInterview = Interview(scheduledAt: DateTime.now().add(const Duration(hours: 3)), state: 'confirmed', proposedBy: 'hr');
    await openHomeCard(tester, 'Ứng viên');
    await tester.tap(find.text('Lê Minh Thư'));
    await tester.pumpAndSettle();

    final upload = tester.widget<FilledButton>(find.ancestor(of: find.text('Tải biên bản phỏng vấn'), matching: find.byWidgetPredicate((w) => w is FilledButton)));
    expect(upload.onPressed, isNull);
    expect(find.text('Qua giờ phỏng vấn mới tải được biên bản (Word, Excel)'), findsOneWidget);
    expect(find.text('Nhận vào làm'), findsNothing);
  });

  testWidgets('hồ sơ đã từ chối thì xem xét lại được', (tester) async {
    final repository = await pumpWithRoles(tester, ['hr']);
    repository.detailStatus = 'rejected';
    await openHomeCard(tester, 'Ứng viên');
    await tester.tap(find.text('Lê Minh Thư'));
    await tester.pumpAndSettle();
    final button = find.text('Xem xét lại');
    await tester.scrollUntilVisible(button, 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(repository.moves, ['reconsider']);
  });

  testWidgets('ứng viên xác nhận giờ phỏng vấn HR hẹn', (tester) async {
    final repository = await pumpWithRoles(tester, ['candidate']);
    repository.mine = Candidate(
      id: 'C1',
      fullName: 'Lê Minh Thư',
      status: 'interview',
      interview: Interview(scheduledAt: DateTime.now().add(const Duration(days: 1)), state: 'awaiting_candidate', proposedBy: 'hr', location: 'Tầng 5, 12 Lê Lợi'),
    );
    await openHomeCard(tester, 'Hồ sơ ứng tuyển của tôi');
    expect(find.text('Lịch phỏng vấn'), findsOneWidget);
    expect(find.text('Tầng 5, 12 Lê Lợi'), findsOneWidget);
    expect(find.text('Đề xuất giờ khác'), findsOneWidget);
    await tester.tap(find.text('Xác nhận giờ này'));
    await tester.pumpAndSettle();
    expect(repository.responses, ['me:confirm']);
  });

  testWidgets('lịch đã qua giờ thì ứng viên chỉ đề xuất giờ khác, không xác nhận được', (tester) async {
    final repository = await pumpWithRoles(tester, ['candidate']);
    repository.mine = Candidate(
      id: 'C1',
      fullName: 'Lê Minh Thư',
      status: 'interview',
      interview: Interview(scheduledAt: DateTime.now().subtract(const Duration(hours: 1)), state: 'awaiting_candidate', proposedBy: 'hr'),
    );
    await openHomeCard(tester, 'Hồ sơ ứng tuyển của tôi');
    expect(find.text('Xác nhận giờ này'), findsNothing);
    expect(find.text('Đã qua giờ hẹn, hãy đề xuất giờ khác'), findsOneWidget);
    expect(find.text('Đề xuất giờ khác'), findsOneWidget);
  });

  testWidgets('nhân viên thường không thấy thẻ Ứng viên', (tester) async {
    await pumpWithRoles(tester, ['employee']);
    expect(find.text('Ứng viên'), findsNothing);
    expect(find.text('Hồ sơ ứng tuyển của tôi'), findsNothing);
  });
  testWidgets('HR còn sót role candidate cũng không thấy hồ sơ ứng tuyển', (tester) async {
    await pumpWithRoles(tester, ['hr', 'employee', 'candidate']);
    expect(find.text('Hồ sơ ứng tuyển của tôi'), findsNothing);
    expect(find.text('Ứng viên'), findsOneWidget);
  });

  testWidgets('HR nhận ứng viên đã phỏng vấn theo gợi ý AI, thấy email và mật khẩu tạm', (tester) async {
    final repository = await pumpWithRoles(tester, ['hr']);
    repository.detailStatus = 'interviewed';
    await openHomeCard(tester, 'Ứng viên');
    await tester.tap(find.text('Lê Minh Thư'));
    await tester.pumpAndSettle();

    final hireButton = find.widgetWithText(FilledButton, 'Nhận vào làm');
    await tester.scrollUntilVisible(hireButton, 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(hireButton);
    await tester.pumpAndSettle();
    expect(find.text('AI gợi ý'), findsOneWidget);
    expect(find.text('Hợp với phòng Kỹ thuật'), findsOneWidget);
    expect(find.widgetWithText(TextField, '15000000'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Nhận vào làm').last);
    await tester.pumpAndSettle();

    expect(repository.hired, ['C1']);
    expect(repository.offers.single?.departmentId, 'PB1');
    expect(repository.offers.single?.baseSalary, 15000000);
    expect(repository.offers.single?.currency, 'VND');
    expect(find.text('Đã tạo nhân viên TBTC1'), findsOneWidget);
    expect(find.textContaining('Tên đăng nhập: thu@gmail.com'), findsOneWidget);
    expect(find.textContaining('Mật khẩu tạm: Tam123'), findsOneWidget);
  });

  testWidgets('ứng viên đã nhận thì không còn nút chuyển bước', (tester) async {
    final repository = await pumpWithRoles(tester, ['hr']);
    repository.detailStatus = 'hired';
    await openHomeCard(tester, 'Ứng viên');
    await tester.tap(find.text('Lê Minh Thư'));
    await tester.pumpAndSettle();
    expect(find.text('Từ chối'), findsNothing);
    expect(find.text('Hẹn phỏng vấn'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Nhận vào làm'), findsNothing);
  });
}
