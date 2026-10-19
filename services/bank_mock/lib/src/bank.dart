/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:math';

/// Chế độ hoạt động của ngân hàng giả lập, đổi được lúc chạy để thử
/// Circuit Breaker và Saga: bình thường, chậm, hoặc lỗi.
enum BankMode { normal, slow, failing }

class TransferRequest {
  const TransferRequest({
    required this.reference,
    required this.account,
    required this.amount,
    required this.currency,
  });

  /// Mã tham chiếu do hệ thống lương đặt, dùng để chống chuyển trùng.
  final String reference;
  final String account;
  final double amount;
  final String currency;
}

class Transfer {
  Transfer(this.request, this.bankReference, this.createdAt);

  final TransferRequest request;
  final String bankReference;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'reference': request.reference,
    'bankReference': bankReference,
    'account': request.account,
    'amount': request.amount,
    'currency': request.currency,
    'status': 'completed',
    'createdAt': createdAt.toIso8601String(),
  };
}

class BankUnavailable implements Exception {
  const BankUnavailable();
}

/// Ngân hàng giả lập lưu giao dịch trong bộ nhớ: đủ để thử luồng chi lương,
/// không phải hệ thống thật.
class MockBank {
  MockBank({Random? random}) : _random = random ?? Random.secure();

  final Random _random;
  final _transfers = <String, Transfer>{};
  BankMode mode = BankMode.normal;

  /// Chậm thêm bao lâu ở chế độ [BankMode.slow].
  Duration slowDelay = const Duration(seconds: 5);

  /// Chuyển tiền. Cùng [TransferRequest.reference] gửi lại thì trả giao dịch
  /// cũ, không chuyển lần hai.
  Future<Transfer> transfer(TransferRequest request) async {
    if (mode == BankMode.failing) throw const BankUnavailable();
    if (mode == BankMode.slow) await Future<void>.delayed(slowDelay);

    final existing = _transfers[request.reference];
    if (existing != null) return existing;

    final bankReference =
        'BNK${List.generate(10, (_) => _random.nextInt(10)).join()}';
    return _transfers[request.reference] = Transfer(
      request,
      bankReference,
      DateTime.now().toUtc(),
    );
  }

  Transfer? find(String reference) => _transfers[reference];

  int get transferCount => _transfers.length;
}
