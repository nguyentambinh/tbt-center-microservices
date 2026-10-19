/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:convert';
import 'dart:io';

import 'package:knowledge_service/src/qa/answer_models.dart';

/// Biến đoạn chữ thành vector (Gemini embedding), dùng để tìm theo nghĩa
class GeminiEmbedder {
  GeminiEmbedder(
    this._apiKey, {
    this.model = 'gemini-embedding-2',
    this.dimensions = 768,
    HttpClient? http,
  }) : _http =
           http ??
           (HttpClient()..connectionTimeout = const Duration(seconds: 10));

  final String _apiKey;
  final String model;
  final int dimensions;
  final HttpClient _http;

  bool get configured => _apiKey.isNotEmpty;

  /// [query] true khi vector hóa câu hỏi, false khi vector hóa bài viết
  Future<List<List<double>>> embed(
    List<String> texts, {
    required bool query,
  }) async {
    final request = await _http.postUrl(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$model:batchEmbedContents',
      ),
    );
    request
      ..headers.contentType = ContentType.json
      ..headers.set('x-goog-api-key', _apiKey)
      ..add(
        utf8.encode(
          jsonEncode({
            'requests': [
              for (final t in texts)
                {
                  'model': 'models/$model',
                  'content': {
                    'parts': [
                      {'text': t},
                    ],
                  },
                  'taskType': query ? 'RETRIEVAL_QUERY' : 'RETRIEVAL_DOCUMENT',
                  'outputDimensionality': dimensions,
                },
            ],
          }),
        ),
      );
    final response = await request.close().timeout(const Duration(seconds: 20));
    final body = await utf8.decodeStream(response);
    if (response.statusCode != 200) {
      throw AnswerError(
        'embedding',
        'HTTP ${response.statusCode}: $body',
        statusCode: response.statusCode,
      );
    }
    final embeddings =
        (jsonDecode(body) as Map<String, dynamic>)['embeddings'] as List;
    return [
      for (final e in embeddings.cast<Map<String, dynamic>>())
        [for (final v in e['values'] as List) (v as num).toDouble()],
    ];
  }
}
