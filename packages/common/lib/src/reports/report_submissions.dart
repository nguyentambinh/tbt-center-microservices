/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/src/db/database.dart';
import 'package:tbt_common/src/db/outbox.dart';
import 'package:tbt_common/src/http/claims.dart';
import 'package:tbt_common/src/http/middleware.dart';

/// Cấp trên nhận báo cáo khu vực
const reportReviewerRoles = {'executive'};

class ReportRuleViolation implements Exception {
  const ReportRuleViolation(this.code, this.message);

  final String code;
  final String message;
}

/// Bản trước chưa được cấp trên xác nhận (hoặc trả lại) thì chưa gửi bản mới
void checkCanSubmit(String? lastStatus) {
  if (lastStatus == 'submitted') {
    throw const ReportRuleViolation(
      'awaiting_ack',
      'The previous report is waiting for confirmation',
    );
  }
}

/// Kỳ báo cáo dạng YYYY-MM: tháng hiện tại hoặc cũ hơn, tháng đã được cấp
/// trên xác nhận thì không gửi lại (tháng bị trả lại thì gửi lại được)
void checkReportPeriod(
  String period, {
  required DateTime now,
  required Set<String> acknowledged,
}) {
  if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(period)) {
    throw const ReportRuleViolation('invalid_period', 'Use YYYY-MM');
  }
  final current = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  if (period.compareTo(current) > 0) {
    throw const ReportRuleViolation(
      'future_period',
      'Only the current or a past month can be reported',
    );
  }
  if (acknowledged.contains(period)) {
    throw const ReportRuleViolation(
      'period_acknowledged',
      'This month was already acknowledged',
    );
  }
}

String nextReportStatus(String status, String action) =>
    switch ((status, action)) {
      ('submitted', 'acknowledge') => 'acknowledged',
      ('submitted', 'return') => 'returned',
      _ => throw ReportRuleViolation(
        'invalid_report_action',
        'Cannot $action a $status report',
      ),
    };

/// Báo cáo gửi cấp trên: ảnh chụp số liệu lúc gửi, ghi chú, trạng thái xác nhận.
/// Mỗi service (hr, finance) giữ báo cáo của mảng mình trong bảng
/// `report_submissions`
class ReportSubmissions {
  ReportSubmissions(this._db, {required this.kind});

  final Database _db;

  /// `hr` hoặc `finance`
  final String kind;

  static const _columns =
      'id, kind, period, note, data, status, submitted_by, reviewed_by, '
      'review_note, created_at, reviewed_at';

  Future<List<Map<String, dynamic>>> list() async {
    final rows = await _db.query(
      'select $_columns from report_submissions where kind = @kind '
      'order by created_at desc limit 50',
      params: {'kind': kind},
      fromPrimary: true,
    );
    return [for (final r in rows) _json(r)];
  }

  Future<Map<String, dynamic>> submit({
    required String period,
    required Map<String, dynamic> data,
    required String by,
    String? note,
  }) => _db.transaction((tx) async {
    // Khóa theo loại báo cáo: hai người bấm gửi cùng lúc chỉ một bản qua
    await tx.execute(
      Sql.named('select pg_advisory_xact_lock(hashtext(@kind))'),
      parameters: {'kind': 'report:$kind'},
    );
    final last = await tx.execute(
      Sql.named(
        'select status from report_submissions where kind = @kind '
        'order by created_at desc limit 1',
      ),
      parameters: {'kind': kind},
    );
    checkCanSubmit(last.isEmpty ? null : last.first[0] as String?);
    final done = await tx.execute(
      Sql.named(
        'select distinct period from report_submissions '
        "where kind = @kind and status = 'acknowledged'",
      ),
      parameters: {'kind': kind},
    );
    checkReportPeriod(
      period,
      now: DateTime.now(),
      acknowledged: {for (final r in done) r[0]! as String},
    );
    final rows = await tx.execute(
      Sql.named(
        'insert into report_submissions (kind, period, note, data, '
        'submitted_by) values (@kind, @period, @note, @data::jsonb, @by) '
        'returning $_columns',
      ),
      parameters: {
        'kind': kind,
        'period': period,
        'note': note,
        'data': jsonEncode(data),
        'by': by,
      },
    );
    final report = _json(rows.first.toColumnMap());
    await addOutboxEvent(
      tx,
      aggregate: 'report',
      aggregateId: '${report['id']}',
      eventType: 'ReportSubmitted',
      payload: {'reportId': report['id'], 'kind': kind, 'period': period},
    );
    return report;
  });

  /// `acknowledge` hoặc `return`; `null` nếu không có báo cáo
  Future<Map<String, dynamic>?> review(
    int id, {
    required String action,
    required String by,
    String? note,
  }) => _db.transaction((tx) async {
    final rows = await tx.execute(
      Sql.named(
        'select status, period from report_submissions '
        'where id = @id and kind = @kind for update',
      ),
      parameters: {'id': id, 'kind': kind},
    );
    if (rows.isEmpty) return null;
    final next = nextReportStatus(rows.first[0]! as String, action);
    final updated = await tx.execute(
      Sql.named(
        'update report_submissions set status = @status, reviewed_by = @by, '
        'review_note = @note, reviewed_at = now() where id = @id '
        'returning $_columns',
      ),
      parameters: {'id': id, 'status': next, 'by': by, 'note': note},
    );
    await addOutboxEvent(
      tx,
      aggregate: 'report',
      aggregateId: '$id',
      eventType: next == 'acknowledged'
          ? 'ReportAcknowledged'
          : 'ReportReturned',
      payload: {'reportId': id, 'kind': kind, 'period': rows.first[1]},
    );
    return _json(updated.first.toColumnMap());
  });

  Map<String, dynamic> _json(Map<String, dynamic> r) => {
    'id': r['id'],
    'kind': r['kind'],
    'period': r['period'],
    'note': r['note'],
    'data': switch (r['data']) {
      final Map<String, dynamic> m => m,
      final String s => jsonDecode(s),
      _ => const <String, dynamic>{},
    },
    'status': r['status'],
    'submittedBy': r['submitted_by'],
    'reviewedBy': r['reviewed_by'],
    'reviewNote': r['review_note'],
    'createdAt': (r['created_at'] as DateTime).toUtc().toIso8601String(),
    'reviewedAt': (r['reviewed_at'] as DateTime?)?.toUtc().toIso8601String(),
  };
}

/// POST /reports/{id}/review  {action: acknowledge|return, note}: Ban lãnh đạo
/// xác nhận để khu vực gửi bản tiếp, hoặc trả lại kèm ghi chú
Future<Response> reviewReportRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(reportReviewerRoles)) {
    return apiError(403, 'forbidden', 'Management only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final number = int.tryParse(id);
  final action = body['action'];
  if (number == null || action is! String) {
    return apiError(400, 'invalid_action', 'Unknown action');
  }
  try {
    final report = await context.read<ReportSubmissions>().review(
      number,
      action: action,
      by: claims.username,
      note: (body['note'] as String?)?.trim(),
    );
    if (report == null) return apiError(404, 'not_found', 'No report $id');
    return Response.json(body: report);
  } on ReportRuleViolation catch (e) {
    return apiError(409, e.code, e.message);
  }
}
