/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:integration_service/src/bank_gateway.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /internal/payouts  {"items": [{reference, account, amount, currency}]}
/// Chi lần lượt từng khoản. Gặp lỗi ngân hàng (hoặc mạch đang ngắt) thì dừng,
/// trả 503 kèm các khoản đã chi được để bên gọi (Saga) quyết định bù trừ.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final List<PayoutItem> items;
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    items = [
      for (final i in body['items'] as List)
        PayoutItem.fromJson(i as Map<String, dynamic>),
    ];
  } on Object {
    return apiError(400, 'invalid_payouts', 'Body must be {"items": [...]}');
  }

  final gateway = context.read<BankGateway>();
  final paid = <Map<String, dynamic>>[];
  for (final item in items) {
    try {
      final bankReference = await gateway.transfer(item);
      paid.add({'reference': item.reference, 'bankReference': bankReference});
    } on Exception catch (e) {
      final code = e is CircuitOpenException ? 'circuit_open' : 'bank_error';
      return Response.json(
        statusCode: 503,
        body: {
          'code': code,
          'message': e.toString(),
          'paid': paid,
          'failedReference': item.reference,
        },
      );
    }
  }
  return Response.json(body: {'paid': paid});
}
