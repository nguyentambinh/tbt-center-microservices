/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:bank_mock_service/src/bank.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET  /admin/mode                       xem chế độ hiện tại
/// POST /admin/mode  {"mode": "failing"}  đổi chế độ khi demo
/// (normal, slow, failing) để thấy Circuit Breaker ngắt và Saga bù trừ.
Future<Response> onRequest(RequestContext context) async {
  final bank = context.read<MockBank>();
  if (context.request.method == HttpMethod.post) {
    final Object? mode;
    try {
      mode = (await context.request.json() as Map<String, dynamic>)['mode'];
    } on Object {
      return apiError(400, 'invalid_mode', 'Body must be {"mode": "..."}');
    }
    final next = BankMode.values.asNameMap()[mode];
    if (next == null) {
      return apiError(400, 'invalid_mode', 'Use normal, slow or failing');
    }
    bank.mode = next;
  } else if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET, POST only');
  }
  return Response.json(
    body: {'mode': bank.mode.name, 'transfers': bank.transferCount},
  );
}
