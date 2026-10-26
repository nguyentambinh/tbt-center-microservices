/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/ai/cv_analyzer.dart';
import 'package:recruitment_service/src/dependencies.dart';
import 'package:recruitment_service/src/mail_sender.dart';

/// dart_frog gọi hàm này thay cho serve mặc định: khởi động bộ phân tích CV
/// chạy nền rồi mới mở HTTP server.
Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  if (cvSummarizer.configured) {
    CvAnalyzer(
      repository: candidateRepository,
      readPdf: cvStorage.read,
      summarize: cvSummarizer.call,
      language: summaryLanguage(),
    ).start();
  } else {
    stderr.writeln(
      'Chưa có ANTHROPIC_API_KEY lẫn GEMINI_API_KEY, bỏ qua bước AI tóm tắt CV',
    );
  }
  if (smtp case final send?) {
    MailSender(database, send: send).start();
  } else {
    stderr.writeln('Chưa có SMTP_USER/SMTP_PASSWORD, email phỏng vấn nằm chờ');
  }
  return serve(handler, ip, port);
}
