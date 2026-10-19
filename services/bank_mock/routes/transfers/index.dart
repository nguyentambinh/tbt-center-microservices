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

/// POST /transfers  {"reference","account","amount","currency"}
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }

  final TransferRequest request;
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    request = TransferRequest(
      reference: body['reference'] as String,
      account: body['account'] as String,
      amount: (body['amount'] as num).toDouble(),
      currency: body['currency'] as String,
    );
  } on Object {
    return apiError(400, 'invalid_transfer', 'Invalid transfer request');
  }
  if (request.amount <= 0) {
    return apiError(400, 'invalid_amount', 'Amount must be positive');
  }

  try {
    final transfer = await context.read<MockBank>().transfer(request);
    return Response.json(statusCode: 201, body: transfer.toJson());
  } on BankUnavailable {
    return apiError(503, 'bank_unavailable', 'Bank is temporarily unavailable');
  }
}
