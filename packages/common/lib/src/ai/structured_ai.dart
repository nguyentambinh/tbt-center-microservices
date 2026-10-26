/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';
import 'dart:io';

/// Tệp gửi kèm câu hỏi: PDF hoặc ảnh
typedef AiFile = ({String mimeType, List<int> bytes});

/// Model Claude rẻ cho việc chọn, xếp; Sonnet cho việc đọc hiểu tài liệu
const claudeHaiku = 'claude-haiku-5-5';
const claudeSonnet = 'claude-sonnet-5-5';

/// Gọi AI trả JSON theo schema: Claude trước, lỗi thì Gemini; không có khóa
/// hoặc cả hai lỗi thì trả null để service dùng cách tính dự phòng.
class StructuredAi {
  StructuredAi({
    this.anthropicKey = '',
    this.geminiKey = '',
    this.claudeModel = claudeHaiku,
    this.effort = 'low',
    this.geminiModels = const ['gemini-2.5-flash'],
    HttpClient? http,
  }) : _http =
           http ??
           (HttpClient()..connectionTimeout = const Duration(seconds: 10));

  /// [claudeModel] theo độ khó: Haiku chọn trong danh sách có sẵn, Sonnet
  /// đọc tài liệu dài (hợp đồng, CV)
  factory StructuredAi.fromEnvironment([
    Map<String, String>? env,
    String claudeModel = claudeHaiku,
    String effort = 'low',
  ]) {
    final e = env ?? Platform.environment;
    return StructuredAi(
      claudeModel: claudeModel,
      effort: effort,
      anthropicKey: e['ANTHROPIC_API_KEY'] ?? '',
      geminiKey: e['GEMINI_API_KEY'] ?? '',
      // Model chính quá tải (503) thì thử model kế tiếp
      geminiModels: {
        if ((e['GEMINI_MODEL'] ?? '').isNotEmpty) e['GEMINI_MODEL']!,
        'gemini-2.5-flash',
      }.toList(),
    );
  }

  final String anthropicKey;
  final String geminiKey;
  final String claudeModel;
  final String effort;
  final List<String> geminiModels;
  final HttpClient _http;

  bool get configured => anthropicKey.isNotEmpty || geminiKey.isNotEmpty;

  /// Tên nhà cung cấp đã trả lời ở lần gọi gần nhất (claude, gemini)
  String? lastProvider;

  /// [pdf] gửi kèm một tệp PDF (hợp đồng, đơn từ); [files] gửi thêm PDF hoặc
  /// ảnh (`image/jpeg`, `image/png`) để AI đọc cùng câu hỏi
  Future<Map<String, dynamic>?> generate({
    required String system,
    required String user,
    required Map<String, dynamic> schema,
    List<int>? pdf,
    List<AiFile> files = const [],
  }) async {
    final attached = [
      if (pdf != null) (mimeType: 'application/pdf', bytes: pdf),
      ...files,
    ];
    if (anthropicKey.isNotEmpty) {
      try {
        final result = await _claude(system, user, schema, attached);
        lastProvider = 'claude';
        return result;
      } on Object catch (e) {
        // Hết hạn mức hoặc lỗi mạng: thử Gemini
        stderr.writeln('Claude lỗi: $e');
      }
    }
    if (geminiKey.isNotEmpty) {
      for (final model in geminiModels) {
        try {
          final result = await _gemini(model, system, user, schema, attached);
          lastProvider = 'gemini';
          return result;
        } on Object catch (e) {
          // Hết model thì service dùng cách tính dự phòng
          stderr.writeln('Gemini $model lỗi: $e');
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> _claude(
    String system,
    String user,
    Map<String, dynamic> schema,
    List<AiFile> files,
  ) async {
    final body = await _post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      {'x-api-key': anthropicKey, 'anthropic-version': '2023-06-01'},
      {
        'model': claudeModel,
        'max_tokens': 8000,
        'output_config': {
          'effort': effort,
          'format': {'type': 'json_schema', 'schema': closedSchema(schema)},
        },
        'system': system,
        'messages': [
          {
            'role': 'user',
            'content': [
              for (final f in files)
                {
                  'type': f.mimeType.startsWith('image/')
                      ? 'image'
                      : 'document',
                  'source': {
                    'type': 'base64',
                    'media_type': f.mimeType,
                    'data': base64Encode(f.bytes),
                  },
                },
              {'type': 'text', 'text': user},
            ],
          },
        ],
      },
    );
    final text = (body['content'] as List)
        .cast<Map<String, dynamic>>()
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join();
    return jsonDecode(text) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _gemini(
    String model,
    String system,
    String user,
    Map<String, dynamic> schema,
    List<AiFile> files,
  ) async {
    final body = await _post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$model:generateContent',
      ),
      {'x-goog-api-key': geminiKey},
      {
        'systemInstruction': {
          'parts': [
            {'text': system},
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              for (final f in files)
                {
                  'inlineData': {
                    'mimeType': f.mimeType,
                    'data': base64Encode(f.bytes),
                  },
                },
              {'text': user},
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseJsonSchema': schema,
          'temperature': 0.2,
        },
      },
    );
    final candidates = body['candidates'] as List? ?? const [];
    if (candidates.isEmpty) throw const FormatException('no candidates');
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

  Future<Map<String, dynamic>> _post(
    Uri url,
    Map<String, String> headers,
    Map<String, Object?> payload,
  ) async {
    final request = await _http.postUrl(url);
    request.headers.contentType = ContentType.json;
    headers.forEach(request.headers.set);
    request.add(utf8.encode(jsonEncode(payload)));
    final response = await request.close().timeout(const Duration(seconds: 90));
    final text = await utf8.decodeStream(response);
    if (response.statusCode != 200) {
      final detail = text.length > 300 ? text.substring(0, 300) : text;
      throw HttpException('HTTP ${response.statusCode} $detail', uri: url);
    }
    return jsonDecode(text) as Map<String, dynamic>;
  }
}

/// Claude bắt buộc mọi `object` trong schema ghi rõ `additionalProperties:
/// false`; Gemini không đòi nên schema gốc giữ nguyên cho Gemini
Object? closedSchema(Object? node) => switch (node) {
  final Map<String, dynamic> m => {
    for (final e in m.entries) e.key: closedSchema(e.value),
    if (m['type'] == 'object') 'additionalProperties': false,
  },
  final List<dynamic> l => [for (final v in l) closedSchema(v)],
  _ => node,
};
