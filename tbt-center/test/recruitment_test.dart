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

  @override
  Future<HireResult> hire(String id) async {
    hired.add(id);
    return const HireResult(employeeId: 'TBTC1', login: 'thu@gmail.com', temporaryPassword: 'Tam123');
  }

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
    overrides: [...overrides, candidateRepositoryProvider.overrideWithValue(repository)],
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

    await tester.enterText(find.widgetWithText(TextField, 'Họ và tên'), 'Lê Minh Thư');
    await tester.pump();
    await tester.tap(find.text('Nộp hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.text('Tiến trình'), findsOneWidget);
    expect(find.text('Sửa hồ sơ'), findsOneWidget);
    expect(find.text('Chưa có CV'), findsOneWidget);
    expect(find.text('Tải CV lên (PDF)'), findsOneWidget);
  });

  testWidgets('HR xem ứng viên và chuyển sang phỏng vấn', (tester) async {
    final repository = await pumpWithRoles(tester, ['hr']);
    await openHomeCard(tester, 'Ứng viên');
    await tester.tap(find.text('Lê Minh Thư'));
    await tester.pumpAndSettle();

    expect(find.text('Tóm tắt của AI'), findsOneWidget);
    expect(find.text('SAP2000'), findsOneWidget);
    expect(find.text('Mở CV'), findsOneWidget);

    final interviewButton = find.widgetWithText(OutlinedButton, 'Phỏng vấn');
    await tester.scrollUntilVisible(interviewButton, 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(interviewButton);
    await tester.pumpAndSettle();
    expect(repository.moves, ['interview']);
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

  testWidgets('HR nhận ứng viên đã có offer, thấy email đăng nhập và mật khẩu tạm', (tester) async {
    final repository = await pumpWithRoles(tester, ['hr']);
    repository.detailStatus = 'offered';
    await openHomeCard(tester, 'Ứng viên');
    await tester.tap(find.text('Lê Minh Thư'));
    await tester.pumpAndSettle();

    final hireButton = find.widgetWithText(FilledButton, 'Nhận vào làm');
    await tester.scrollUntilVisible(hireButton, 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(hireButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Nhận vào làm').last);
    await tester.pumpAndSettle();

    expect(repository.hired, ['C1']);
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
    expect(find.text('Chuyển sang'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Nhận vào làm'), findsNothing);
  });
}
