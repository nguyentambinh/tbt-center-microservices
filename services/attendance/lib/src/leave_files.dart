/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';

import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Minh chứng nhận: Word, PDF, ảnh JPG/PNG
const leaveFileTypes = {
  'application/pdf',
  'image/jpeg',
  'image/png',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
};

/// Một đơn tối đa 5 tệp
const maxLeaveFiles = 5;

typedef LeaveFile = ({
  String id,
  String mimeType,
  String objectKey,
  String fileName,
  DateTime uploadedAt,
});

abstract interface class LeaveFileRepository {
  /// Đơn của đúng người, còn chờ duyệt; ném [LeaveRuleViolation] nếu không
  Future<void> checkOwnPending(String leaveId, String employeeId);

  Future<List<LeaveFile>> files(String leaveId);

  /// Ném `too_many_files` khi đã đủ [maxLeaveFiles]
  Future<void> attach(
    String leaveId, {
    required String mimeType,
    required String objectKey,
    required String fileName,
  });

  Future<void> saveSummary(
    String leaveId,
    Map<String, dynamic> summary, {
    required String source,
  });

  /// Lý do, loại nghỉ, ngày để AI so với minh chứng
  Future<Map<String, dynamic>?> leave(String leaveId);
}

class PostgresLeaveFileRepository implements LeaveFileRepository {
  PostgresLeaveFileRepository(this._db);

  final Database _db;

  @override
  Future<void> checkOwnPending(String leaveId, String employeeId) async {
    final rows = await _db.query(
      'select employee_id, status from leave_requests where id::text = @id',
      params: {'id': leaveId},
      fromPrimary: true,
    );
    if (rows.isEmpty || rows.first['employee_id'] != employeeId) {
      throw const LeaveRuleViolation('not_found', 'No such leave request');
    }
    if (rows.first['status'] != 'pending') {
      throw const LeaveRuleViolation(
        'already_decided',
        'Files can be added only while the request is pending',
      );
    }
  }

  @override
  Future<List<LeaveFile>> files(String leaveId) async {
    final rows = await _db.query(
      'select id::text, mime_type, object_key, file_name, uploaded_at '
      'from leave_attachments where leave_id::text = @id order by uploaded_at',
      params: {'id': leaveId},
      fromPrimary: true,
    );
    return [
      for (final r in rows)
        (
          id: r['id'] as String,
          mimeType: r['mime_type'] as String,
          objectKey: r['object_key'] as String,
          fileName: r['file_name'] as String,
          uploadedAt: r['uploaded_at'] as DateTime,
        ),
    ];
  }

  @override
  Future<void> attach(
    String leaveId, {
    required String mimeType,
    required String objectKey,
    required String fileName,
  }) => _db.transaction((tx) async {
    final count = await tx.execute(
      Sql.named(
        'select count(*)::int from leave_attachments '
        'where leave_id::text = @id',
      ),
      parameters: {'id': leaveId},
    );
    if ((count.first[0]! as int) >= maxLeaveFiles) {
      throw const LeaveRuleViolation(
        'too_many_files',
        'At most 5 files per request',
      );
    }
    await tx.execute(
      Sql.named(
        'insert into leave_attachments (leave_id, mime_type, object_key, '
        'file_name) values (@id::uuid, @mime, @key, @name)',
      ),
      parameters: {
        'id': leaveId,
        'mime': mimeType,
        'key': objectKey,
        'name': fileName,
      },
    );
  });

  @override
  Future<void> saveSummary(
    String leaveId,
    Map<String, dynamic> summary, {
    required String source,
  }) => _db.execute(
    'update leave_requests set ai_summary = @summary::jsonb, '
    'ai_source = @source where id::text = @id',
    params: {'id': leaveId, 'summary': jsonEncode(summary), 'source': source},
  );

  @override
  Future<Map<String, dynamic>?> leave(String leaveId) async {
    final rows = await _db.query(
      'select employee_id, leave_type, reason, from_date, to_date '
      'from leave_requests '
      'where id::text = @id',
      params: {'id': leaveId},
      fromPrimary: true,
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    String day(Object? d) =>
        (d! as DateTime).toIso8601String().substring(0, 10);
    return {
      'employeeId': r['employee_id'],
      'leaveType': r['leave_type'],
      'reason': r['reason'],
      'fromDate': day(r['from_date']),
      'toDate': day(r['to_date']),
    };
  }
}

/// AI đọc minh chứng, tóm ý chính cho HR; không tự duyệt đơn
class LeaveSummarizer {
  LeaveSummarizer(this.ai);

  final StructuredAi ai;

  static const _schema = {
    'type': 'object',
    'properties': {
      'summary': {'type': 'string'},
      'keyPoints': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'documentType': {'type': 'string'},
      'datesMentioned': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'matchesRequest': {'type': 'boolean'},
      'concerns': {'type': 'string'},
    },
    'required': ['summary', 'keyPoints', 'matchesRequest'],
  };

  /// [files] là nội dung từng minh chứng; Word đã đổi thành chữ
  Future<({Map<String, dynamic> summary, String source})?> summarize({
    required Map<String, dynamic> leave,
    required List<({String mimeType, List<int> bytes, String name})> files,
    required String language,
  }) async {
    if (!ai.configured || files.isEmpty) return null;
    final texts = <String>[];
    final attached = <AiFile>[];
    for (final f in files) {
      if (f.mimeType == 'application/pdf' || f.mimeType.startsWith('image/')) {
        attached.add((mimeType: f.mimeType, bytes: f.bytes));
      } else {
        try {
          texts.add('${f.name}:\n${docxText(f.bytes)}');
        } on Object {
          texts.add('${f.name}: (unreadable)');
        }
      }
    }
    final result = await ai.generate(
      system:
          'You help HR review leave requests. Read the attached evidence '
          '(medical certificates, letters, photos) and summarise only what it '
          'says. Do not decide approval. Say whether it supports the stated '
          'leave type, dates and reason. Reply in $language.',
      user: jsonEncode({'leaveRequest': leave, 'documentsText': texts}),
      schema: _schema,
      files: attached,
    );
    if (result == null) return null;
    return (summary: result, source: ai.lastProvider ?? 'ai');
  }
}
