/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:attendance_service/src/data/period_lock.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// Saga chốt lương khóa, mở kỳ. POST/DELETE {"period": "2026-10", "runId": "..."}
Future<Response> onRequest(RequestContext context) async {
  final locks = context.read<PeriodLocks>();
  final method = context.request.method;
  if (method == HttpMethod.get) {
    return Response.json(body: {'locked': await locks.locked()});
  }
  if (method != HttpMethod.post && method != HttpMethod.delete) {
    return apiError(405, 'method_not_allowed', 'GET, POST or DELETE');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final period = body['period'];
  final runId = body['runId'];
  if (period is! String ||
      DateTime.tryParse('$period-01') == null ||
      period.length != 7 ||
      runId is! String ||
      runId.isEmpty) {
    return apiError(400, 'invalid_lock', 'period (YYYY-MM) and runId required');
  }
  if (method == HttpMethod.post) {
    await locks.lock(period, runId);
  } else {
    await locks.unlock(period, runId);
  }
  return Response.json(
    body: {'period': period, 'locked': method == HttpMethod.post},
  );
}
