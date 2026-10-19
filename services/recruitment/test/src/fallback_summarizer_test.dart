/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:recruitment_service/src/ai/ai_summarizer.dart';
import 'package:recruitment_service/src/ai/claude_client.dart';
import 'package:recruitment_service/src/ai/gemini_client.dart';
import 'package:tbt_common/tbt_common.dart';
import 'package:test/test.dart';

final _pdf = Uint8List.fromList([1, 2, 3]);

AiProvider _provider(
  String model, {
  bool configured = true,
  Exception? error,
  List<String>? calls,
}) => AiProvider(
  model: model,
  configured: configured,
  summarize: (pdf, language) async {
    calls?.add(model);
    if (error != null) throw error;
    return {'fullName': 'Lê Minh Thư', 'by': model};
  },
);

void main() {
  test('Claude chạy được thì không gọi Gemini', () async {
    final calls = <String>[];
    final result = await FallbackSummarizer(
      primary: _provider('claude', calls: calls),
      fallback: _provider('gemini', calls: calls),
    ).call(_pdf, 'Vietnamese');
    expect(result.model, 'claude');
    expect(calls, ['claude']);
  });

  for (final (name, error) in [
    (
      'hết credit',
      const ClaudeError('HTTP 400: credit balance is too low', statusCode: 400),
    ),
    ('quá tải', const ClaudeError('HTTP 529', statusCode: 529)),
    ('mất mạng', const SocketException('no route')),
    ('mạch đang ngắt', const CircuitOpenException('claude', Duration.zero)),
  ]) {
    test('Claude $name thì chuyển sang Gemini, ghi đúng tên model', () async {
      final result = await FallbackSummarizer(
        primary: _provider('claude', error: error),
        fallback: _provider('gemini-4-argon'),
      ).call(_pdf, 'Vietnamese');
      expect(result.model, 'gemini-4-argon');
      expect(result.summary['by'], 'gemini-4-argon');
    });
  }

  test('lỗi do chính CV (400 thường) thì không chuyển, dự phòng cũng lỗi', () {
    final calls = <String>[];
    expect(
      FallbackSummarizer(
        primary: _provider(
          'claude',
          error: const ClaudeError('HTTP 400: bad pdf', statusCode: 400),
          calls: calls,
        ),
        fallback: _provider('gemini', calls: calls),
      ).call(_pdf, 'Vietnamese'),
      throwsA(isA<ClaudeError>()),
    );
  });

  test('chưa có key Claude thì dùng thẳng Gemini', () async {
    final result = await FallbackSummarizer(
      primary: _provider('claude', configured: false),
      fallback: _provider('gemini'),
    ).call(_pdf, 'English');
    expect(result.model, 'gemini');
  });

  test('cả hai đều lỗi tài khoản thì ném lỗi của Gemini để tạm dừng', () {
    expect(
      FallbackSummarizer(
        primary: _provider(
          'claude',
          error: const ClaudeError('HTTP 401', statusCode: 401),
        ),
        fallback: _provider(
          'gemini',
          error: const GeminiError('HTTP 403', statusCode: 403),
        ),
      ).call(_pdf, 'English'),
      throwsA(
        isA<GeminiError>().having((e) => e.isAccountProblem, 'account', true),
      ),
    );
  });

  test('bản tóm tắt thiếu trường thì được điền giá trị rỗng', () {
    final summary = normalizeCvSummary({'fullName': 'An', 'extra': 1});
    expect(summary.keys, cvSummaryFields);
    expect(summary['skills'], isEmpty);
    expect(summary['yearsOfExperience'], 0);
    expect(summary.containsKey('extra'), isFalse);
  });
}
