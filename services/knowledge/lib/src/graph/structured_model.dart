/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'dart:convert';
import 'dart:io';

import 'package:knowledge_service/src/qa/answer_models.dart';

/// AI trả về JSON đúng khuôn schema, dùng cho việc chạy nền
abstract interface class StructuredModel {
  String get provider;
  String get model;
  bool get configured;

  Future<Map<String, dynamic>> generate({
    required String system,
    required String user,
    required Map<String, dynamic> schema,
  });
}

class ClaudeStructured implements StructuredModel {
  ClaudeStructured(
    this._apiKey, {
    this.model = 'claude-sonnet-5-5',
    HttpClient? http,
  }) : _http =
           http ??
           (HttpClient()..connectionTimeout = const Duration(seconds: 10));

  final String _apiKey;
  @override
  final String model;
  final HttpClient _http;

  @override
  String get provider => 'claude';

  @override
  bool get configured => _apiKey.isNotEmpty;

  @override
  Future<Map<String, dynamic>> generate({
    required String system,
    required String user,
    required Map<String, dynamic> schema,
  }) async {
    final request = await _http.postUrl(
      Uri.parse('https://api.anthropic.com/v1/messages'),
    );
    request
      ..headers.contentType = ContentType.json
      ..headers.set('x-api-key', _apiKey)
      ..headers.set('anthropic-version', '2023-06-01')
      ..add(
        utf8.encode(
          jsonEncode({
            'model': model,
            'max_tokens': 8000,
            'output_config': {
              'effort': 'medium',
              'format': {'type': 'json_schema', 'schema': schema},
            },
            'system': system,
            'messages': [
              {'role': 'user', 'content': user},
            ],
          }),
        ),
      );
    final response = await request.close().timeout(const Duration(seconds: 90));
    final body = await utf8.decodeStream(response);
    if (response.statusCode != 200) {
      throw AnswerError(
        provider,
        'HTTP ${response.statusCode}: $body',
        statusCode: response.statusCode,
      );
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    final text = (json['content'] as List)
        .cast<Map<String, dynamic>>()
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join();
    return jsonDecode(text) as Map<String, dynamic>;
  }
}

class GeminiStructured implements StructuredModel {
  GeminiStructured(this._apiKey, {required this.model, HttpClient? http})
    : _http =
          http ??
          (HttpClient()..connectionTimeout = const Duration(seconds: 10));

  final String _apiKey;
  @override
  final String model;
  final HttpClient _http;

  @override
  String get provider => 'gemini';

  @override
  bool get configured => _apiKey.isNotEmpty;

  @override
  Future<Map<String, dynamic>> generate({
    required String system,
    required String user,
    required Map<String, dynamic> schema,
  }) async {
    final request = await _http.postUrl(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
      ),
    );
    request
      ..headers.contentType = ContentType.json
      ..headers.set('x-goog-api-key', _apiKey)
      ..add(
        utf8.encode(
          jsonEncode({
            'systemInstruction': {
              'parts': [
                {'text': system},
              ],
            },
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': user},
                ],
              },
            ],
            'generationConfig': {
              'responseMimeType': 'application/json',
              'responseJsonSchema': schema,
              'temperature': 0.1,
              'thinkingConfig': model.startsWith('gemini-2')
                  ? {'thinkingBudget': 1024}
                  : {'thinkingLevel': 'medium'},
            },
          }),
        ),
      );
    final response = await request.close().timeout(const Duration(seconds: 90));
    final body = await utf8.decodeStream(response);
    if (response.statusCode != 200) {
      throw AnswerError(
        provider,
        'HTTP ${response.statusCode}: $body',
        statusCode: response.statusCode,
      );
    }
    final candidates =
        (jsonDecode(body) as Map<String, dynamic>)['candidates'] as List? ??
        const [];
    if (candidates.isEmpty) {
      throw AnswerError(provider, 'no answer', statusCode: 200);
    }
    final parts =
        ((candidates.first as Map<String, dynamic>)['content']
                as Map<String, dynamic>?)?['parts']
            as List? ??
        const [];
    final text = parts
        .cast<Map<String, dynamic>>()
        .where((p) => p['thought'] != true)
        .map((p) => p['text'] as String? ?? '')
        .join();
    return jsonDecode(text) as Map<String, dynamic>;
  }
}
