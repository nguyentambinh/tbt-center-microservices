/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:async';
import 'dart:io';

import 'package:knowledge_service/src/knowledge_repository.dart';
import 'package:knowledge_service/src/qa/embedder.dart';
import 'package:knowledge_service/src/qa/vectors.dart';

/// Chạy nền: bài mới hoặc vừa sửa thì tính lại vector, mỗi lần tối đa 50 bài
class EmbeddingIndexer {
  EmbeddingIndexer(this._articles, this._embedder);

  final KnowledgeRepository _articles;
  final GeminiEmbedder _embedder;
  Timer? _timer;
  bool _running = false;

  void start({Duration every = const Duration(minutes: 10)}) {
    unawaited(runOnce());
    _timer = Timer.periodic(every, (_) => unawaited(runOnce()));
  }

  void stop() => _timer?.cancel();

  /// Trả về số bài đã tính lại vector
  Future<int> runOnce() async {
    if (_running || !_embedder.configured) return 0;
    _running = true;
    try {
      final rows = await _articles.embeddingStatus();
      // Dấu băm gồm cả tên model: đổi model là tính lại toàn bộ
      final stale = [
        for (final r in rows)
          if (r['stored'] != '${r['hash']}:${_embedder.model}') r,
      ].take(50).toList();
      if (stale.isEmpty) return 0;
      final vectors = await _embedder.embed(
        [for (final r in stale) r['text'] as String],
        query: false,
      );
      for (var i = 0; i < stale.length; i++) {
        await _articles.saveEmbedding(
          stale[i]['id'] as String,
          stale[i]['lang'] as String,
          _embedder.model,
          '${stale[i]['hash']}:${_embedder.model}',
          encodeVector(vectors[i]),
        );
      }
      stdout.writeln('Đã tính vector cho ${stale.length} bài');
      return stale.length;
    } on Object catch (error) {
      stderr.writeln('Tính vector lỗi, thử lại lần sau: $error');
      return 0;
    } finally {
      _running = false;
    }
  }
}
