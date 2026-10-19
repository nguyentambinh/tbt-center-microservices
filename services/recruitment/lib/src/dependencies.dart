/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:recruitment_service/src/ai/ai_error.dart';
import 'package:recruitment_service/src/ai/ai_summarizer.dart';
import 'package:recruitment_service/src/ai/claude_client.dart';
import 'package:recruitment_service/src/ai/gemini_client.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/identity/hiring.dart';
import 'package:recruitment_service/src/identity/keycloak_admin.dart';
import 'package:recruitment_service/src/imports/import_repository.dart';
import 'package:recruitment_service/src/storage/cv_storage.dart';
import 'package:tbt_common/tbt_common.dart';

/// Các đối tượng dùng chung cho cả route và bộ phân tích chạy nền,
/// tạo một lần cho cả tiến trình.
final database = Database.fromEnvironment();
final candidateRepository = PostgresCandidateRepository(database);
final importRepository = PostgresImportRepository(database);
final cvStorage = CvStorage.fromEnvironment();

final hiring = Hiring(
  candidates: candidateRepository,
  identity: KeycloakAdmin.fromEnvironment(),
  createEmployee: hrEmployees(
    InternalClient(
      'hr',
      Uri.parse(Platform.environment['HR_URL'] ?? 'http://hr:8080'),
    ),
  ),
  region: Platform.environment['REGION'] ?? 'vn',
);
final claudeClient = ClaudeClient(
  Platform.environment['ANTHROPIC_API_KEY'] ?? '',
);

/// Claude lỗi phía máy chủ 3 lần liên tiếp thì ngắt 2 phút, không gửi CV
/// tiếp vào một dịch vụ đang hỏng.
final claudeBreaker = CircuitBreaker(
  'claude',
  openFor: const Duration(minutes: 2),
);

/// Gemini là dự phòng khi Claude không dùng được (ADR 0007). Key và tên
/// model ở `deploy/secrets/gemini.env`; để trống key thì không dùng dự phòng.
final geminiClient = GeminiClient(
  Platform.environment['GEMINI_API_KEY'] ?? '',
  model: Platform.environment['GEMINI_MODEL'] ?? 'gemini-4-argon',
);

final geminiBreaker = CircuitBreaker(
  'gemini',
  openFor: const Duration(minutes: 2),
);

/// Lỗi tính là dịch vụ AI hỏng: quá tải, lỗi máy chủ, mất kết nối, lỗi tài
/// khoản. Lỗi do nội dung một CV cụ thể thì không tính.
bool isAiOutage(Object error) => isProviderOutage(error);

final cvSummarizer = FallbackSummarizer(
  primary: AiProvider(
    model: claudeModel,
    configured: claudeClient.configured,
    summarize: (pdf, language) => claudeBreaker.call(
      () => claudeClient.summarizeCv(pdf, language: language),
      isFailure: isAiOutage,
    ),
  ),
  fallback: AiProvider(
    model: geminiClient.model,
    configured: geminiClient.configured,
    summarize: (pdf, language) => geminiBreaker.call(
      () => geminiClient.summarizeCv(pdf, language: language),
      isFailure: isAiOutage,
    ),
  ),
);

/// Ngôn ngữ viết bản tóm tắt: theo nước của khu vực, để HR tại chỗ đọc.
String summaryLanguage([String? countryCode]) =>
    switch (countryCode ?? Platform.environment['COUNTRY_CODE']) {
      'VN' => 'Vietnamese',
      'DE' => 'German',
      'BR' => 'Brazilian Portuguese',
      _ => 'English',
    };
