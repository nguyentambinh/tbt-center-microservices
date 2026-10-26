/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';

import 'package:recruitment_service/src/ai/ai_error.dart';
import 'package:recruitment_service/src/ai/claude_client.dart';
import 'package:recruitment_service/src/positions.dart';

class GeminiError implements AiProviderError {
  const GeminiError(this.message, {this.statusCode});

  final String message;

  @override
  final int? statusCode;

  /// Sai key, key bị chặn, chưa bật Gemini API, hoặc tên model không còn
  /// (404): lỗi cấu hình, gửi CV khác cũng lỗi y vậy.
  @override
  bool get isAccountProblem =>
      statusCode == 401 || statusCode == 403 || statusCode == 404;

  @override
  String toString() => 'GeminiError: $message';
}

/// Gọi Gemini qua REST (generateContent) làm dự phòng khi Claude không dùng
/// được. CV gửi dạng PDF nhúng, yêu cầu trả JSON cùng cấu trúc với Claude.
class GeminiClient {
  GeminiClient(this._apiKey, {required this.model, HttpClient? http})
    : _http =
          http ??
          (HttpClient()..connectionTimeout = const Duration(seconds: 20));

  final String _apiKey;

  /// Tên model lấy từ `GEMINI_MODEL`; đổi model không phải sửa code.
  final String model;
  final HttpClient _http;

  bool get configured => _apiKey.isNotEmpty;

  Future<Map<String, dynamic>> summarizeCv(
    List<int> pdf, {
    required String language,
    List<PositionBrief> positions = const [],
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$model:generateContent',
    );
    final request = await _http.postUrl(url);
    request
      ..headers.contentType = ContentType.json
      ..headers.set('x-goog-api-key', _apiKey)
      ..add(
        utf8.encode(
          jsonEncode({
            'systemInstruction': {
              'parts': [
                {
                  'text':
                      'You help HR teams of a construction company review job '
                      'applications. Summarise only what the CV states; never '
                      'guess missing facts (use an empty string, 0 or an empty '
                      'list). Do not judge age, gender, ethnicity, religion or '
                      'marital status. Write every text value in $language. '
                      'Answer with one JSON object that has exactly these '
                      'keys: ${cvSummaryFields.join(', ')}. education is a '
                      'list of {school, degree, period}; experience is a list '
                      'of {company, role, period, highlights}; '
                      'yearsOfExperience is a number; positionMatches is a '
                      'list of {positionId (integer), score (integer 0-100), '
                      'verdict, strengths, gaps}; the other list fields are '
                      'lists of strings.',
                },
              ],
            },
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {
                    'inline_data': {
                      'mime_type': 'application/pdf',
                      'data': base64Encode(pdf),
                    },
                  },
                  {
                    'text':
                        'Summarise this CV for the HR team. suitablePositions '
                        'lists roles in a construction company that fit this '
                        'person; questionsForInterview lists points HR should '
                        'clarify. ${positionPrompt(positions)}',
                  },
                ],
              },
            ],
            'generationConfig': {'responseMimeType': 'application/json'},
          }),
        ),
      );

    final response = await request.close().timeout(const Duration(minutes: 3));
    final body = await utf8.decodeStream(response);
    if (response.statusCode != 200) {
      throw GeminiError(
        'HTTP ${response.statusCode}: $body',
        statusCode: response.statusCode,
      );
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List? ?? const [];
    if (candidates.isEmpty) {
      throw const GeminiError('No answer (blocked or empty)', statusCode: 200);
    }
    final parts =
        ((candidates.first as Map<String, dynamic>)['content']
                as Map<String, dynamic>?)?['parts']
            as List? ??
        const [];
    final text = parts
        .cast<Map<String, dynamic>>()
        .map((p) => p['text'] as String? ?? '')
        .join();
    return normalizeCvSummary(jsonDecode(text) as Map<String, dynamic>);
  }
}
