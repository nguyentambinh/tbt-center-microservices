/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:integration_service/src/bank_gateway.dart';
import 'package:tbt_common/tbt_common.dart';

final bankGateway = BankGateway(
  Uri.parse(Platform.environment['BANK_URL'] ?? 'http://localhost:8090'),
);

/// Cổng ra hệ thống ngoài (ngân hàng). Chỉ service trong khu vực gọi được.
Handler middleware(Handler handler) {
  ServiceMetrics.instance.watch(bankGateway.breaker);
  final internal = handler.use(requireInternalToken());
  return ((RequestContext context) {
        if (context.request.uri.path == '/') return handler(context);
        return internal(context);
      })
      .use(provider<BankGateway>((_) => bankGateway))
      .use(correlationAndErrors())
      .use(metrics('integration'))
      .use(serviceRegistry('integration'));
}
