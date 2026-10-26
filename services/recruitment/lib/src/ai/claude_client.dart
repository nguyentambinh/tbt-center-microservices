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
import 'package:recruitment_service/src/positions.dart';

/// Mô hình tóm tắt CV
const claudeModel = 'claude-sonnet-5-5';

class ClaudeError implements AiProviderError {
  const ClaudeError(this.message, {this.statusCode});

  final String message;

  @override
  final int? statusCode;

  /// Lỗi do tài khoản API (sai key, hết credit, bị khóa), không phải do CV.
  /// Gọi lại hồ sơ khác cũng sẽ lỗi y như vậy.
  @override
  bool get isAccountProblem =>
      statusCode == 401 ||
      statusCode == 403 ||
      (statusCode == 400 && message.contains('credit balance'));

  @override
  String toString() => 'ClaudeError: $message';
}

/// Cấu trúc bản tóm tắt CV; Claude buộc phải trả JSON đúng dạng này.
const cvSummarySchema = {
  'type': 'object',
  'additionalProperties': false,
  'required': [
    'fullName',
    'email',
    'phone',
    'headline',
    'yearsOfExperience',
    'education',
    'experience',
    'skills',
    'languages',
    'suitablePositions',
    'strengths',
    'questionsForInterview',
    'positionMatches',
  ],
  'properties': {
    'fullName': {'type': 'string'},
    'email': {'type': 'string'},
    'phone': {'type': 'string'},
    'headline': {'type': 'string'},
    'yearsOfExperience': {'type': 'number'},
    'education': {
      'type': 'array',
      'items': {
        'type': 'object',
        'additionalProperties': false,
        'required': ['school', 'degree', 'period'],
        'properties': {
          'school': {'type': 'string'},
          'degree': {'type': 'string'},
          'period': {'type': 'string'},
        },
      },
    },
    'experience': {
      'type': 'array',
      'items': {
        'type': 'object',
        'additionalProperties': false,
        'required': ['company', 'role', 'period', 'highlights'],
        'properties': {
          'company': {'type': 'string'},
          'role': {'type': 'string'},
          'period': {'type': 'string'},
          'highlights': {'type': 'string'},
        },
      },
    },
    'skills': {
      'type': 'array',
      'items': {'type': 'string'},
    },
    'languages': {
      'type': 'array',
      'items': {'type': 'string'},
    },
    'suitablePositions': {
      'type': 'array',
      'items': {'type': 'string'},
    },
    'strengths': {
      'type': 'array',
      'items': {'type': 'string'},
    },
    'questionsForInterview': {
      'type': 'array',
      'items': {'type': 'string'},
    },
    'positionMatches': {
      'type': 'array',
      'items': {
        'type': 'object',
        'additionalProperties': false,
        'required': ['positionId', 'score', 'verdict', 'strengths', 'gaps'],
        'properties': {
          'positionId': {'type': 'integer'},
          'score': {'type': 'integer'},
          'verdict': {'type': 'string'},
          'strengths': {'type': 'string'},
          'gaps': {'type': 'string'},
        },
      },
    },
  },
};

/// Đoạn yêu cầu so khớp CV với các vị trí ứng viên đã chọn
String positionPrompt(List<PositionBrief> positions) {
  if (positions.isEmpty) {
    return 'The candidate chose no position: return positionMatches as an '
        'empty list.';
  }
  String line(PositionBrief p) {
    final department = p.department == null ? '' : ' (${p.department})';
    final description = p.description.isEmpty ? '-' : p.description;
    final requirements = p.requirements.isEmpty ? '-' : p.requirements;
    return '- positionId ${p.id}: ${p.title}$department. '
        'Description: $description. Requirements: $requirements';
  }

  final lines = positions.map(line).join('\n');
  return 'The candidate applied for these open positions:\n$lines\n'
      'For each one, add an item to positionMatches with that positionId: '
      'score 0-100 (how well the CV meets the requirements; 80+ strong, '
      '50-79 partial, below 50 weak), a one-sentence verdict, the CV '
      'evidence that fits (strengths) and missing requirements (gaps). Base '
      'the score only on skills, experience, education and certificates in '
      'the CV.';
}

/// Các trường bắt buộc của bản tóm tắt, theo thứ tự trong [cvSummarySchema].
final cvSummaryFields = [
  for (final f in cvSummarySchema['required']! as List) f as String,
];

/// Điền giá trị rỗng cho trường bị thiếu, bỏ trường lạ: model dự phòng không
/// bị ép JSON schema chặt như Claude nên có thể trả thiếu hay thừa.
Map<String, dynamic> normalizeCvSummary(Map<String, dynamic> raw) {
  final properties = cvSummarySchema['properties']! as Map<String, Object>;
  return {
    for (final field in cvSummaryFields)
      field:
          raw[field] ??
          switch ((properties[field]! as Map)['type']) {
            'array' => <Object>[],
            'number' => 0,
            _ => '',
          },
  };
}

/// Gọi Claude API qua HTTP (Dart chưa có SDK chính thức của Anthropic).
class ClaudeClient {
  ClaudeClient(this._apiKey, {HttpClient? http})
    : _http =
          http ??
          (HttpClient()..connectionTimeout = const Duration(seconds: 20));

  final String _apiKey;
  final HttpClient _http;

  bool get configured => _apiKey.isNotEmpty;

  /// Đọc CV dạng PDF, trả bản tóm tắt theo [cvSummarySchema],
  /// viết bằng [language].
  Future<Map<String, dynamic>> summarizeCv(
    List<int> pdf, {
    required String language,
    List<PositionBrief> positions = const [],
  }) async {
    final url = Uri.parse('https://api.anthropic.com/v1/messages');
    final request = await _http.postUrl(url);
    request
      ..headers.contentType = ContentType.json
      ..headers.set('x-api-key', _apiKey)
      ..headers.set('anthropic-version', '2023-06-01')
      // Bị bộ lọc an toàn từ chối thì API tự chạy lại bằng mô hình dự phòng.
      ..headers.set('anthropic-beta', 'server-side-fallback-2026-07-01')
      ..add(
        utf8.encode(
          jsonEncode({
            'model': claudeModel,
            'max_tokens': 8000,
            'fallbacks': 'default',
            'output_config': {
              'effort': 'medium',
              'format': {'type': 'json_schema', 'schema': cvSummarySchema},
            },
            'system':
                'You help HR teams of a construction company review job '
                'applications. Summarise only what the CV states; never guess '
                'missing facts (use an empty string, 0 or an empty list). '
                'Do not judge age, gender, ethnicity, religion or marital '
                'status. '
                'Write every text value in $language.',
            'messages': [
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'document',
                    'source': {
                      'type': 'base64',
                      'media_type': 'application/pdf',
                      'data': base64Encode(pdf),
                    },
                  },
                  {
                    'type': 'text',
                    'text':
                        'Summarise this CV for the HR team. suitablePositions '
                        'lists roles in a construction company that fit this '
                        'person; questionsForInterview lists points HR should '
                        'clarify. ${positionPrompt(positions)}',
                  },
                ],
              },
            ],
          }),
        ),
      );

    final response = await request.close().timeout(const Duration(minutes: 3));
    final body = await utf8.decodeStream(response);
    if (response.statusCode != 200) {
      throw ClaudeError(
        'HTTP ${response.statusCode}: $body',
        statusCode: response.statusCode,
      );
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    if (json['stop_reason'] == 'refusal') {
      throw const ClaudeError('Request was declined');
    }
    final text = (json['content'] as List)
        .cast<Map<String, dynamic>>()
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join();
    return jsonDecode(text) as Map<String, dynamic>;
  }
}
