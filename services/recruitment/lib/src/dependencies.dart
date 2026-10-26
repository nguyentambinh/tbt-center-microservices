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
import 'package:recruitment_service/src/identity/signup.dart';
import 'package:recruitment_service/src/imports/import_repository.dart';
import 'package:recruitment_service/src/interviews.dart';
import 'package:recruitment_service/src/mail_sender.dart';
import 'package:recruitment_service/src/offer.dart';
import 'package:recruitment_service/src/positions.dart';
import 'package:recruitment_service/src/storage/cv_storage.dart';
import 'package:tbt_common/tbt_common.dart';

/// Các đối tượng dùng chung cho cả route và bộ phân tích chạy nền,
/// tạo một lần cho cả tiến trình.
final database = Database.fromEnvironment();
final candidateRepository = PostgresCandidateRepository(database);
final positionRepository = PostgresPositionRepository(database);
final importRepository = PostgresImportRepository(database);
final cvStorage = CvStorage.fromEnvironment();
final interviewRepository = PostgresInterviewRepository(
  database,
  candidateRepository,
);

final _hr = InternalClient(
  'hr',
  Uri.parse(Platform.environment['HR_URL'] ?? 'http://hr:8080'),
);
final _payroll = InternalClient(
  'payroll',
  Uri.parse(Platform.environment['PAYROLL_URL'] ?? 'http://payroll:8080'),
);

final hiring = Hiring(
  candidates: candidateRepository,
  identity: KeycloakAdmin.fromEnvironment(),
  createEmployee: hrEmployees(_hr),
  region: Platform.environment['REGION'] ?? 'vn',
  setSalary: payrollSetSalary(_payroll),
  mail: queueMail(database),
);

final signup = Signup(
  database,
  identity: KeycloakAdmin.fromEnvironment(),
  send: smtp,
);

final offerAdvisor = OfferAdvisor(
  placement: hrPlacement(_hr),
  salaries: payrollSalaries(_payroll),
  ai: StructuredAi.fromEnvironment(),
);

/// Gửi email phỏng vấn; null khi chưa có `deploy/secrets/smtp.env`
final smtp = smtpFromEnvironment();
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
    summarize: (pdf, language, positions) => claudeBreaker.call(
      () => claudeClient.summarizeCv(
        pdf,
        language: language,
        positions: positions,
      ),
      isFailure: isAiOutage,
    ),
  ),
  fallback: AiProvider(
    model: geminiClient.model,
    configured: geminiClient.configured,
    summarize: (pdf, language, positions) => geminiBreaker.call(
      () => geminiClient.summarizeCv(
        pdf,
        language: language,
        positions: positions,
      ),
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
