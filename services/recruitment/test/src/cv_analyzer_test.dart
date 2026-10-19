/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:recruitment_service/src/ai/claude_client.dart';
import 'package:recruitment_service/src/ai/cv_analyzer.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/storage/s3_presigner.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

class _MockRepository extends Mock implements CandidateRepository {}

void main() {
  late _MockRepository repository;

  setUp(() {
    repository = _MockRepository();
    when(
      () => repository.saveSummary(any(), any(), model: any(named: 'model')),
    ).thenAnswer((_) async {});
    when(
      () => repository.recordAiFailure(any(), any()),
    ).thenAnswer((_) async {});
  });

  CvAnalyzer analyzer({Uint8List? pdf, Exception? error}) => CvAnalyzer(
    repository: repository,
    readPdf: (_) async => pdf,
    summarize: (_, language) async {
      if (error != null) throw error;
      return (
        summary: <String, dynamic>{
          'fullName': 'Lê Minh Thư',
          'language': language,
        },
        model: claudeModel,
      );
    },
    language: 'Vietnamese',
  );

  test('không còn hồ sơ chờ thì dừng', () async {
    when(() => repository.nextForAnalysis()).thenAnswer((_) async => null);
    expect(await analyzer().analyzeNext(), isFalse);
  });

  test('tóm tắt xong thì lưu kết quả theo đúng ngôn ngữ', () async {
    when(
      () => repository.nextForAnalysis(),
    ).thenAnswer((_) async => (id: 'C1', cvKey: 'cv/C1/a.pdf'));
    await analyzer(pdf: Uint8List.fromList([1, 2])).analyzeNext();
    final saved =
        verify(
              () => repository.saveSummary(
                'C1',
                captureAny(),
                model: claudeModel,
              ),
            ).captured.single
            as Map;
    expect(saved['language'], 'Vietnamese');
  });

  test('AI lỗi thì ghi lỗi để không gọi lại mãi', () async {
    when(
      () => repository.nextForAnalysis(),
    ).thenAnswer((_) async => (id: 'C1', cvKey: 'cv/C1/a.pdf'));
    await analyzer(
      pdf: Uint8List.fromList([1]),
      error: const ClaudeError('HTTP 529'),
    ).analyzeNext();
    verify(() => repository.recordAiFailure('C1', any())).called(1);
    verifyNever(
      () => repository.saveSummary(any(), any(), model: any(named: 'model')),
    );
  });

  test('tài khoản hết credit thì tạm dừng, không trừ lượt của hồ sơ', () async {
    when(
      () => repository.nextForAnalysis(),
    ).thenAnswer((_) async => (id: 'C1', cvKey: 'cv/C1/a.pdf'));
    final a = analyzer(
      pdf: Uint8List.fromList([1]),
      error: const ClaudeError(
        'HTTP 400: Your credit balance is too low',
        statusCode: 400,
      ),
    );
    expect(await a.analyzeNext(), isFalse);
    verifyNever(() => repository.recordAiFailure(any(), any()));
    // Lượt sau vẫn đang tạm dừng nên không gọi lại.
    expect(await a.analyzeNext(), isFalse);
    verify(() => repository.nextForAnalysis()).called(1);
  });

  test('mạch Claude đang ngắt thì không trừ lượt của hồ sơ', () async {
    when(
      () => repository.nextForAnalysis(),
    ).thenAnswer((_) async => (id: 'C1', cvKey: 'cv/C1/a.pdf'));
    final result = await analyzer(
      pdf: Uint8List.fromList([1]),
      error: const CircuitOpenException('claude', Duration(minutes: 1)),
    ).analyzeNext();
    expect(result, isFalse);
    verifyNever(() => repository.recordAiFailure(any(), any()));
  });

  test('URL ký sẵn có đủ tham số SigV4 và chữ ký 64 ký tự hex', () {
    final url =
        S3Presigner(
          accessKeyId: 'GKtest',
          secretAccessKey: 'secret',
          bucket: 'tbt-cv',
        ).presign(
          'PUT',
          'cv/C1/a b.pdf',
          endpoint: Uri.parse('http://localhost:3900'),
          now: DateTime.utc(2026, 10, 15, 6, 30),
        );
    expect(url.path, '/tbt-cv/cv/C1/a%20b.pdf');
    expect(url.queryParameters['X-Amz-Date'], '20261015T063000Z');
    expect(
      url.queryParameters['X-Amz-Credential'],
      'GKtest/20261015/garage/s3/aws4_request',
    );
    expect(url.queryParameters['X-Amz-Signature'], hasLength(64));
  });
}
