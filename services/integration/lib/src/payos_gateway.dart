/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-19
 */

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:integration_service/src/bank_gateway.dart';
import 'package:tbt_common/tbt_common.dart';

/// Cấu hình kênh chi hộ payOS, đọc từ deploy/secrets/payos.env
class PayOsConfig {
  const PayOsConfig({
    required this.clientId,
    required this.apiKey,
    required this.checksumKey,
    required this.payoutAmount,
    required this.toBin,
    required this.toAccount,
    this.baseUrl = 'https://api-merchant.payos.vn',
  });

  /// `null` khi chưa bật hoặc thiếu khóa, thiếu tài khoản nhận
  static PayOsConfig? fromEnv(Map<String, String> env) {
    final region = env['REGION'] ?? '';
    final regions = (env['PAYOS_REGIONS'] ?? 'vn')
        .split(',')
        .map((r) => r.trim());
    final config = PayOsConfig(
      clientId: env['PAYOS_CLIENT_ID'] ?? '',
      apiKey: env['PAYOS_API_KEY'] ?? '',
      checksumKey: env['PAYOS_CHECKSUM_KEY'] ?? '',
      payoutAmount: int.tryParse(env['PAYOS_PAYOUT_AMOUNT'] ?? '') ?? 2000,
      toBin: env['PAYOS_TO_BIN'] ?? '',
      toAccount: env['PAYOS_TO_ACCOUNT'] ?? '',
      baseUrl: env['PAYOS_BASE_URL'] ?? 'https://api-merchant.payos.vn',
    );
    final ready =
        env['PAYOS_ENABLED'] == 'true' &&
        regions.contains(region) &&
        [
          config.clientId,
          config.apiKey,
          config.checksumKey,
          config.toBin,
          config.toAccount,
        ].every((v) => v.isNotEmpty);
    return ready ? config : null;
  }

  final String clientId;
  final String apiKey;
  final String checksumKey;

  /// Số tiền chi thật cho mỗi khoản (VND); số trong CSDL giữ nguyên
  final int payoutAmount;

  /// Mã BIN ngân hàng/ví nhận (MoMo: 971025) và số tài khoản nhận
  final String toBin;
  final String toAccount;
  final String baseUrl;
}

/// Chữ ký payOS: khóa sắp xếp, `key=value` mã hóa URL nối bằng `&`,
/// HMAC-SHA256 theo checksum key, dạng hex
String payOsSignature(Map<String, dynamic> body, String checksumKey) {
  final query = canonicalQuery(body);
  return Hmac(
    sha256,
    utf8.encode(checksumKey),
  ).convert(utf8.encode(query)).toString();
}

String canonicalQuery(Map<String, dynamic> body) {
  final sorted = _deepSort(body)! as Map<String, dynamic>;
  return [
    for (final MapEntry(:key, :value) in sorted.entries)
      '${Uri.encodeComponent(key)}=${Uri.encodeComponent(_text(value))}',
  ].join('&');
}

Object? _deepSort(Object? value) => switch (value) {
  Map() => {
    for (final key in (value.keys.map((k) => '$k').toList()..sort()))
      key: _deepSort(value[key]),
  },
  List() => [for (final v in value) _deepSort(v)],
  _ => value,
};

String _text(Object? value) => switch (value) {
  null => '',
  Map() || List() => jsonEncode(value),
  _ => '$value',
};

/// Chi lương qua payOS (lệnh chi hộ /v1/payouts), cùng Circuit Breaker như cổng ngân hàng.
/// Mỗi khoản chuyển [PayOsConfig.payoutAmount] đồng tới tài khoản cấu hình sẵn.
class PayOsGateway implements PayoutGateway {
  PayOsGateway(this.config, {CircuitBreaker? breaker, HttpClient? http})
    : breaker = breaker ?? CircuitBreaker('bank'),
      _http =
          http ??
          (HttpClient()..connectionTimeout = const Duration(seconds: 8));

  final PayOsConfig config;
  final HttpClient _http;

  @override
  final CircuitBreaker breaker;

  @override
  String get channel => 'payos';

  @override
  Future<String> transfer(PayoutItem item) => breaker.call(() async {
    final body = <String, dynamic>{
      'referenceId': item.reference,
      'amount': config.payoutAmount,
      'description': _description(item.reference),
      'toBin': config.toBin,
      'toAccountNumber': config.toAccount,
    };
    // Cùng reference gửi lại thì payOS coi là một lệnh, không chi lần hai
    final data = await _send(
      'POST',
      '/v1/payouts',
      body: body,
      idempotencyKey: item.reference,
    );
    return data['id'] as String;
  }, isFailure: (e) => e is! BankError || e.statusCode >= 500);

  /// Số dư tài khoản chi hộ, dùng kiểm khóa mà không chuyển tiền
  Future<Map<String, dynamic>> balance() =>
      _send('GET', '/v1/payouts-account/balance');

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? idempotencyKey,
  }) async {
    final request = await _http.openUrl(
      method,
      Uri.parse('${config.baseUrl}$path'),
    );
    request.headers
      ..set('x-client-id', config.clientId)
      ..set('x-api-key', config.apiKey);
    if (body != null) {
      request.headers
        ..contentType = ContentType.json
        ..set('x-signature', payOsSignature(body, config.checksumKey));
      if (idempotencyKey != null) {
        request.headers.set('x-idempotency-key', idempotencyKey);
      }
      request.add(utf8.encode(jsonEncode(body)));
    }
    final response = await request.close().timeout(const Duration(seconds: 15));
    final text = await utf8.decodeStream(response);
    final json = text.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(text) as Map<String, dynamic>;
    // payOS trả HTTP 200 kèm code '00' khi thành công
    if (response.statusCode >= 300 || json['code'] != '00') {
      final status = response.statusCode >= 300 ? response.statusCode : 422;
      throw BankError(status, 'payOS ${json['code']}: ${json['desc']}');
    }
    return (json['data'] as Map<String, dynamic>?) ?? {};
  }

  // Nội dung chuyển khoản không dấu, ngắn
  String _description(String reference) {
    final tail = reference.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    final start = tail.length > 12 ? tail.length - 12 : 0;
    return 'TBT luong ${tail.substring(start)}';
  }
}
