/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';

import 'package:tbt_common/tbt_common.dart';

class PayoutItem {
  const PayoutItem({
    required this.reference,
    required this.account,
    required this.amount,
    required this.currency,
  });

  factory PayoutItem.fromJson(Map<String, dynamic> json) => PayoutItem(
    reference: json['reference'] as String,
    account: json['account'] as String,
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String,
  );

  final String reference;
  final String account;
  final double amount;
  final String currency;
}

/// Ngân hàng trả lời lỗi (không phải do dữ liệu gửi sai).
class BankError implements Exception {
  const BankError(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'Bank $statusCode: $message';
}

/// Kênh chi lương ra ngoài: ngân hàng giả lập hoặc payOS
abstract interface class PayoutGateway {
  CircuitBreaker get breaker;

  /// Tên kênh hiện ở GET /
  String get channel;

  /// Chuyển một khoản; trả mã giao dịch phía kênh chi.
  Future<String> transfer(PayoutItem item);
}

/// Gửi lệnh chi lương sang ngân hàng (R72). Mọi lời gọi đi qua Circuit
/// Breaker: ngân hàng lỗi liên tiếp thì ngắt, không gửi tiếp vào chỗ hỏng.
class BankGateway implements PayoutGateway {
  BankGateway(this.bankUrl, {CircuitBreaker? breaker, HttpClient? http})
    : breaker = breaker ?? CircuitBreaker('bank'),
      _http =
          http ??
          (HttpClient()..connectionTimeout = const Duration(seconds: 5));

  final Uri bankUrl;
  final HttpClient _http;

  @override
  final CircuitBreaker breaker;

  @override
  String get channel => 'bank_mock';

  /// Cùng `reference` gửi lại thì ngân hàng trả giao dịch cũ, không chuyển lại.
  @override
  Future<String> transfer(PayoutItem item) => breaker.call(() async {
    final request = await _http.postUrl(bankUrl.resolve('/transfers'));
    request
      ..headers.contentType = ContentType.json
      ..add(
        utf8.encode(
          jsonEncode({
            'reference': item.reference,
            'account': item.account,
            'amount': item.amount,
            'currency': item.currency,
          }),
        ),
      );
    final response = await request.close().timeout(
      const Duration(seconds: 10),
    );
    final body = await utf8.decodeStream(response);
    if (response.statusCode != 201) {
      throw BankError(response.statusCode, body);
    }
    return (jsonDecode(body) as Map<String, dynamic>)['bankReference']
        as String;
  }, isFailure: (e) => e is! BankError || e.statusCode >= 500);
}
