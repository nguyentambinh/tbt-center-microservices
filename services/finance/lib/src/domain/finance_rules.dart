/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// Xem số liệu tài chính (R23: dữ liệu tài chính chỉ cho bộ phận liên quan).
const financeViewerRoles = {'finance', 'admin', 'executive'};

/// Nhập chứng từ, trả nhà cung cấp, chốt sổ.
const financeWriterRoles = {'finance', 'admin'};

class FinanceRuleViolation implements Exception {
  const FinanceRuleViolation(this.code, this.message);

  final String code;
  final String message;
}

Response ruleError(FinanceRuleViolation e) {
  final status = switch (e.code) {
    'period_closed' ||
    'overpaid' ||
    'budget_exceeded' ||
    'already_spent' => 409,
    'unknown_supplier' => 404,
    _ => 400,
  };
  return apiError(status, e.code, e.message);
}

final _amount = RegExp(r'^\d{1,16}(\.\d{1,2})?$');

/// Số tiền giữ dạng chuỗi để không lệch số lẻ khi đổi qua số thực.
String? parseAmount(Object? value) {
  final text = value is num ? value.toString() : value as String?;
  if (text == null || !_amount.hasMatch(text.trim())) return null;
  return double.parse(text) > 0 ? text.trim() : null;
}

DateTime? parseDay(Object? value) {
  if (value is! String || value.length != 10) return null;
  return DateTime.tryParse(value);
}

/// Kỳ dạng `YYYY-MM`.
bool isPeriod(String value) =>
    value.length == 7 && DateTime.tryParse('$value-01') != null;

String periodOf(DateTime day) => day.toIso8601String().substring(0, 7);
