/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/dependencies.dart';
import 'package:knowledge_service/src/qa/embedding_indexer.dart';

/// Bật việc nền (tính vector, xóa nhật ký cũ) rồi mới mở HTTP server
Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  EmbeddingIndexer(articleRepository, embedder).start();
  graphReasoning.startAtBoot();
  graphExtractor.start();
  Timer.periodic(const Duration(hours: 24), (_) async {
    try {
      await articleRepository.purgeLog();
    } on Object catch (error) {
      stderr.writeln('Xóa nhật ký hỏi đáp cũ lỗi: $error');
    }
  });
  return serve(handler, ip, port);
}
