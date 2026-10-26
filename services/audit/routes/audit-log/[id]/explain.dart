/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:audit_service/src/anomaly_explainer.dart';
import 'package:audit_service/src/audit_reader.dart';
import 'package:audit_service/src/audit_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

const _languages = {'en': 'English', 'de': 'German', 'pt': 'Portuguese'};

/// POST /audit-log/{id}/explain?language=vi  AI giải thích điểm bất thường của
/// sự kiện (lưu lại, lần sau trả ngay); người đọc một nước chỉ xem nước mình
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final reader = auditReader(context);
  if (reader is Response) return reader;
  final number = int.tryParse(id);
  final repository = context.read<AuditRepository>();
  final event = number == null ? null : await repository.event(number);
  final scope = readerRegion(reader as Claims);
  if (event == null || (scope != null && event['region'] != scope)) {
    return apiError(404, 'not_found', 'No event $id');
  }
  final cached = await repository.explanation(number!);
  if (cached != null) return Response.json(body: cached);
  final explainer = context.read<AnomalyExplainer>();
  if (!explainer.configured) {
    return apiError(503, 'ai_unavailable', 'AI is not configured');
  }
  final language = context.request.uri.queryParameters['language'];
  final result = await explainer.explain(
    event: event,
    history: await repository.history(
      event['aggregateId'] as String,
      before: number,
    ),
    language: _languages[language] ?? 'Vietnamese',
  );
  if (result == null) {
    return apiError(503, 'ai_unavailable', 'AI could not explain right now');
  }
  await repository.saveExplanation(
    number,
    result.explanation,
    source: result.source,
  );
  return Response.json(
    body: {...result.explanation, 'source': result.source},
  );
}
