/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:recruitment_service/src/ai/ai_error.dart';
import 'package:recruitment_service/src/positions.dart';

/// Bản tóm tắt kèm tên model đã viết nó (lưu vào `cv_summaries.model`).
typedef CvSummary = ({Map<String, dynamic> summary, String model});

/// Một nhà cung cấp AI đã bọc Circuit Breaker riêng.
class AiProvider {
  const AiProvider({
    required this.model,
    required this.configured,
    required this.summarize,
  });

  final String model;
  final bool configured;
  final Future<Map<String, dynamic>> Function(
    Uint8List pdf,
    String language,
    List<PositionBrief> positions,
  )
  summarize;
}

/// Tóm tắt CV bằng nhà cung cấp chính (Claude); nhà cung cấp chính lỗi phía
/// họ (hết credit, quá tải, mất mạng, mạch đang ngắt) thì chuyển sang dự
/// phòng (Gemini) thay vì báo lỗi. Cả hai đều lỗi thì ném lỗi của bên dự
/// phòng để bộ phân tích quyết định tạm dừng hay thử lại sau.
class FallbackSummarizer {
  FallbackSummarizer({required this.primary, required this.fallback});

  final AiProvider primary;
  final AiProvider fallback;

  bool get configured => primary.configured || fallback.configured;

  Future<CvSummary> call(
    Uint8List pdf,
    String language, [
    List<PositionBrief> positions = const [],
  ]) async {
    if (!primary.configured) return _run(fallback, pdf, language, positions);
    try {
      return await _run(primary, pdf, language, positions);
    } on Exception catch (e) {
      if (!fallback.configured || !isProviderOutage(e)) rethrow;
      stderr.writeln(
        '${primary.model} lỗi ($e), chuyển sang ${fallback.model}',
      );
      return _run(fallback, pdf, language, positions);
    }
  }

  Future<CvSummary> _run(
    AiProvider provider,
    Uint8List pdf,
    String language,
    List<PositionBrief> positions,
  ) async => (
    summary: await provider.summarize(pdf, language, positions),
    model: provider.model,
  );
}
