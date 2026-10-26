/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:convert';

import 'package:tbt_common/tbt_common.dart';

/// AI đọc đơn thôi việc cho cấp trên: lý do chính, nhóm lý do, gợi ý giữ chân;
/// không tự duyệt hay từ chối đơn
class ResignationAnalyst {
  ResignationAnalyst(this.ai);

  final StructuredAi ai;

  static const categories = [
    'career',
    'salary',
    'workload',
    'management',
    'environment',
    'personal',
    'health',
    'relocation',
    'other',
  ];

  static const _schema = {
    'type': 'object',
    'properties': {
      'summary': {'type': 'string'},
      'mainReasons': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'category': {'type': 'string', 'enum': categories},
      'tone': {
        'type': 'string',
        'enum': ['calm', 'dissatisfied', 'urgent'],
      },
      'retentionIdeas': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'concerns': {'type': 'string'},
      'matchesStatedReason': {'type': 'boolean'},
    },
    'required': ['summary', 'mainReasons', 'category', 'matchesStatedReason'],
  };

  bool get configured => ai.configured;

  /// [letter] là bản đơn; Word đổi thành chữ, PDF và ảnh gửi nguyên cho AI
  Future<({Map<String, dynamic> analysis, String source})?> analyze({
    required String statedReason,
    required String lastDay,
    required ({String mime, List<int> bytes, String name}) letter,
    required String language,
  }) async {
    if (!ai.configured) return null;
    final texts = <String>[];
    final files = <AiFile>[];
    if (letter.mime == 'application/pdf' || letter.mime.startsWith('image/')) {
      files.add((mimeType: letter.mime, bytes: letter.bytes));
    } else {
      try {
        texts.add(docxText(letter.bytes));
      } on Object {
        texts.add('(unreadable)');
      }
    }
    final result = await ai.generate(
      system:
          'You help a manager review an employee resignation letter. Read the '
          'attached letter and the stated reason. Summarise the real reasons, '
          'classify the main one, describe the tone, flag anything the '
          'company should check (conflicts, harassment, health, unpaid '
          'wages) and suggest realistic ways to keep the employee. Do not '
          'decide approval. Reply in $language.',
      user: jsonEncode({
        'statedReason': statedReason,
        'lastDay': lastDay,
        'letterText': texts,
      }),
      schema: _schema,
      files: files,
    );
    if (result == null) return null;
    return (analysis: result, source: ai.lastProvider ?? 'ai');
  }
}
