/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';
import 'dart:io';

import 'package:tbt_common/tbt_common.dart';

/// Lỗi chung của một nhà cung cấp AI (Claude, Gemini).
abstract interface class AiProviderError implements Exception {
  int? get statusCode;

  /// Lỗi do tài khoản API (sai key, hết credit, bị khóa), không phải do CV.
  bool get isAccountProblem;
}

/// Lỗi phía nhà cung cấp, đáng chuyển sang nhà cung cấp dự phòng: tài khoản,
/// quá tải, lỗi máy chủ, mất kết nối, quá giờ, mạch đang ngắt. Lỗi do chính
/// nội dung CV (400 vì tệp hỏng…) thì dự phòng cũng sẽ lỗi, không chuyển.
bool isProviderOutage(Object error) => switch (error) {
  CircuitOpenException() || IOException() || TimeoutException() => true,
  AiProviderError(:final isAccountProblem, :final statusCode) =>
    isAccountProblem ||
        statusCode == null ||
        statusCode == 429 ||
        statusCode >= 500,
  _ => false,
};
