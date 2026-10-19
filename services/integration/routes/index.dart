/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:integration_service/src/bank_gateway.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'service': 'integration',
      'status': 'ok',
      'channel': context.read<PayoutGateway>().channel,
      'circuits': {'bank': context.read<PayoutGateway>().breaker.state.name},
    },
  );
}
