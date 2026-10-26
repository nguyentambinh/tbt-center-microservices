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
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/features/recruitment/data/repositories/job_position_repository.dart';
import 'package:tbtcenter/features/recruitment/domain/entities/candidate.dart';
import 'package:tbtcenter/features/recruitment/domain/entities/job_position.dart';
import 'package:tbtcenter/features/recruitment/presentation/providers/candidate_providers.dart';

import 'package:tbtcenter/features/recruitment/presentation/pages/my_application_page.dart';

import 'helpers.dart';
import 'recruitment_test.dart' show FakeCandidateRepository;

class FakePositionRepository extends JobPositionRepository {
  FakePositionRepository() : super(Dio(), baseUrl: '');

  final created = <JobPositionInput>[];

  static const _positions = [
    JobPosition(id: 1, title: 'Kỹ sư kết cấu', department: 'Kỹ thuật', headcount: 3, status: 'open', hired: 1, applicants: 2, requirements: 'SAP2000, 3 năm'),
    JobPosition(id: 2, title: 'Kế toán công trình', department: 'Tài chính', headcount: 1, status: 'open'),
  ];

  @override
  Future<List<JobPosition>> list({bool all = false}) async => _positions;

  @override
  Future<JobPosition> find(int id) async => const JobPosition(
        id: 1,
        title: 'Kỹ sư kết cấu',
        department: 'Kỹ thuật',
        headcount: 3,
        status: 'open',
        hired: 1,
        applicants: 2,
        requirements: 'SAP2000, 3 năm',
        candidates: [
          PositionApplicant(id: 'C1', fullName: 'Lê Minh Thư', status: 'analyzed', matchScore: 86, matchVerdict: 'Đủ kinh nghiệm kết cấu thép', matched: true),
          PositionApplicant(id: 'C2', fullName: 'Phạm Quốc Huy', status: 'submitted'),
        ],
      );

  @override
  Future<JobPosition> create(JobPositionInput input) async {
    created.add(input);
    return _positions.first;
  }
}

class CapturingCandidateRepository extends FakeCandidateRepository {
  CandidateInput? saved;

  @override
  Future<Candidate> saveMyApplication(CandidateInput input) {
    saved = input;
    return super.saveMyApplication(input);
  }

  @override
  Future<Candidate> candidate(String id) async => const Candidate(
        id: 'C1',
        fullName: 'Lê Minh Thư',
        status: 'analyzed',
        hasCv: true,
        consentAi: true,
        positions: [
          PositionMatch(id: 1, title: 'Kỹ sư kết cấu', score: 86, verdict: 'Đủ kinh nghiệm kết cấu thép', strengths: 'SAP2000, 6 năm', gaps: 'Chưa có chứng chỉ hành nghề', matched: true),
          PositionMatch(id: 2, title: 'Kế toán công trình'),
        ],
      );
}

Future<(CapturingCandidateRepository, FakePositionRepository)> _pump(WidgetTester tester, List<String> roles) async {
  final candidates = CapturingCandidateRepository();
  final positions = FakePositionRepository();
  final overrides = await testOverrides(language: 'vi', store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles))));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...overrides,
      candidateRepositoryProvider.overrideWithValue(candidates),
      jobPositionRepositoryProvider.overrideWithValue(positions),
      pickPdfProvider.overrideWithValue(() async => (name: 'CV.pdf', bytes: const [37, 80, 68, 70])),
    ],
    child: const TbtApp(),
  ));
  await tester.pumpAndSettle();
  return (candidates, positions);
}

void main() {
  testWidgets('ứng viên sổ danh sách, tick hai vị trí rồi nộp', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final (candidates, _) = await _pump(tester, ['candidate']);
    await openHomeCard(tester, 'Hồ sơ ứng tuyển của tôi');
    await tester.tap(find.text('Đính kèm CV (PDF, tối đa 10 MB)'));
    await tester.pumpAndSettle();

    // Chưa chọn vị trí thì báo ngay trên ô chọn
    await tester.ensureVisible(find.text('Nộp hồ sơ'));
    await tester.tap(find.text('Nộp hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.text('Chọn ít nhất một vị trí ứng tuyển'), findsOneWidget);
    expect(candidates.saved, isNull);

    await tester.tap(find.text('Bấm để chọn'));
    await tester.pumpAndSettle();
    expect(find.text('Kỹ thuật · Còn 2 chỗ'), findsOneWidget);
    await tester.tap(find.text('Kỹ sư kết cấu'));
    await tester.tap(find.text('Kế toán công trình'));
    await tester.pump();
    await tester.tap(find.text('Xong (2 vị trí)'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'Kỹ sư kết cấu'), findsOneWidget);

    await tester.ensureVisible(find.text('Nộp hồ sơ'));
    await tester.tap(find.text('Nộp hồ sơ'));
    await tester.pumpAndSettle();
    expect(candidates.saved?.positionIds, unorderedEquals([1, 2]));
    expect(candidates.saved?.appliedPosition, isNull);
  });

  testWidgets('HR mở vị trí mới với số người cần tuyển', (tester) async {
    final (_, positions) = await _pump(tester, ['hr']);
    await openHomeCard(tester, 'Vị trí tuyển dụng');
    expect(find.text('Đã tuyển 1/3 · 2 ứng viên'), findsOneWidget);
    await tester.tap(find.text('Mở vị trí'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Tên vị trí'), 'Giám sát an toàn');
    await tester.enterText(find.widgetWithText(TextField, 'Số người cần tuyển'), '0');
    await tester.pump();
    expect(find.text('Số người cần tuyển từ 1 đến 500'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Số người cần tuyển'), '2');
    await tester.enterText(find.widgetWithText(TextField, 'Yêu cầu'), 'Chứng chỉ an toàn lao động');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
    await tester.pumpAndSettle();
    expect(positions.created.single.headcount, 2);
    expect(positions.created.single.requirements, 'Chứng chỉ an toàn lao động');
  });

  testWidgets('HR xem ứng viên của vị trí theo điểm AI', (tester) async {
    await _pump(tester, ['hr']);
    await openHomeCard(tester, 'Vị trí tuyển dụng');
    await tester.tap(find.text('Kỹ sư kết cấu'));
    await tester.pumpAndSettle();
    expect(find.text('86'), findsOneWidget);
    expect(find.text('Đủ kinh nghiệm kết cấu thép'), findsOneWidget);
    expect(find.text('–'), findsOneWidget);

  });

  testWidgets('hồ sơ ứng viên hiện điểm phù hợp từng vị trí', (tester) async {
    await _pump(tester, ['hr']);
    await openHomeCard(tester, 'Ứng viên');
    await tester.tap(find.text('Lê Minh Thư').first);
    await tester.pumpAndSettle();
    expect(find.text('Mức phù hợp với vị trí (AI)'), findsOneWidget);
    expect(find.text('86%'), findsOneWidget);
    expect(find.text('Còn thiếu: Chưa có chứng chỉ hành nghề'), findsOneWidget);
    expect(find.text('AI đang so khớp'), findsOneWidget);
  });
}
