/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:recruitment_service/src/ai/ai_error.dart';
import 'package:recruitment_service/src/ai/ai_summarizer.dart';
import 'package:recruitment_service/src/ai/claude_client.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:tbt_common/tbt_common.dart';

typedef PdfReader = Future<Uint8List?> Function(String key);
typedef Summarizer = Future<CvSummary> Function(Uint8List pdf, String language);

/// Chạy nền trong service recruitment: lấy từng hồ sơ có CV và đồng ý cho AI,
/// gửi AI tóm tắt (Claude, dự phòng Gemini), lưu kết quả. Ứng viên nộp xong
/// không phải chờ bước này.
class CvAnalyzer {
  CvAnalyzer({
    required this.repository,
    required this.readPdf,
    required this.summarize,
    required this.language,
  });

  final CandidateRepository repository;
  final PdfReader readPdf;
  final Summarizer summarize;
  final String language;
  bool _running = false;
  DateTime? _pausedUntil;

  /// Tài khoản API lỗi thì nghỉ một lúc rồi thử lại, không trừ lượt của hồ sơ.
  static const accountPause = Duration(minutes: 10);

  /// Xử lý một hồ sơ; trả `true` nếu nên xử lý tiếp hồ sơ sau ngay.
  Future<bool> analyzeNext() async {
    final paused = _pausedUntil;
    if (paused != null && DateTime.now().isBefore(paused)) return false;
    final next = await repository.nextForAnalysis();
    if (next == null) return false;
    try {
      final pdf = await readPdf(next.cvKey);
      if (pdf == null) throw const ClaudeError('CV file not found in storage');
      final result = await summarize(pdf, language);
      await repository.saveSummary(
        next.id,
        result.summary,
        model: result.model,
      );
      stdout.writeln('Đã tóm tắt CV của ứng viên ${next.id} (${result.model})');
      return true;
    } on Exception catch (e) {
      if (e is CircuitOpenException) {
        // Mạch đang ngắt: chưa gọi được AI nên không trừ lượt của hồ sơ.
        return false;
      }
      if (e is AiProviderError && e.isAccountProblem) {
        _pausedUntil = DateTime.now().add(accountPause);
        stderr.writeln(
          'Tài khoản AI lỗi (đã thử cả dự phòng nếu có), tạm dừng 10 phút: $e',
        );
        return false;
      }
      // Lỗi riêng của hồ sơ này: ghi lại, lượt sau mới thử tiếp (tối đa 3 lần).
      await repository.recordAiFailure(next.id, e.toString());
      stderr.writeln('Tóm tắt CV ${next.id} lỗi: $e');
      return false;
    }
  }

  /// Kiểm tra định kỳ; một lượt chỉ chạy một lần để không gọi AI song song.
  Timer start({Duration every = const Duration(seconds: 15)}) {
    return Timer.periodic(every, (_) async {
      if (_running) return;
      _running = true;
      try {
        while (await analyzeNext()) {}
      } on Exception catch (e) {
        stderr.writeln('Bộ phân tích CV lỗi: $e');
      } finally {
        _running = false;
      }
    });
  }
}
