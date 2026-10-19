/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:finance_service/src/data/finance_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// Tiền tệ của khu vực và tỷ giá quy USD, hỏi service currency.
class RateSource {
  RateSource(this.currency, this._client);

  final String currency;
  final InternalClient _client;

  /// Mỗi chứng từ lưu tỷ giá của chính ngày phát sinh, không tính lại về sau.
  Future<Rate> rateOn(DateTime day) async {
    final data = await _client.get(
      '/internal/rate',
      query: {
        'quote': currency,
        'date': day.toIso8601String().substring(0, 10),
      },
    );
    return (
      rate: data['rate'] as String,
      date: DateTime.parse(data['rateDate'] as String),
    );
  }
}
