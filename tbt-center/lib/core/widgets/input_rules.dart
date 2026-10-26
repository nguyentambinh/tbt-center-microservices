/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:flutter/services.dart';

/// Ràng buộc ô nhập dùng chung: mỗi ô chỉ nhận đúng loại ký tự, chặn emoji,
/// giới hạn độ dài bằng formatter (không hiện bộ đếm dưới ô)
abstract final class InputRules {
  /// Emoji, ký hiệu hình, cờ, ký tự nối emoji
  static final _noEmoji = FilteringTextInputFormatter.deny(
    RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{2300}-\u{23FF}\u{FE0F}\u{200D}\u{20E3}\u{E0020}-\u{E007F}]', unicode: true),
  );

  static List<TextInputFormatter> text(int max) => [_noEmoji, LengthLimitingTextInputFormatter(max)];

  static final search = text(100);
  static final shortText = text(120);
  static final note = text(1000);
  static final longText = text(4000);
  static final sql = text(5000);
  static final password = text(64);

  /// Họ tên: chữ cái mọi ngôn ngữ, dấu cách, nháy đơn, chấm, gạch nối
  static final name = [FilteringTextInputFormatter.allow(RegExp(r"[\p{L}\p{M}\s'.\-]", unicode: true)), LengthLimitingTextInputFormatter(100)];
  static final email = [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9@._%+\-]')), LengthLimitingTextInputFormatter(120)];
  static final phone = [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')), LengthLimitingTextInputFormatter(20)];
  static final digits = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(15)];
  static final decimal = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')), LengthLimitingTextInputFormatter(18)];
  static final ip = [FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F.:]')), LengthLimitingTextInputFormatter(45)];
  static final currency = [FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')), LengthLimitingTextInputFormatter(3)];
  static final country = [FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')), LengthLimitingTextInputFormatter(2)];
  static final link = [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9@._~:/?#\[\]!$&()*+,;=%\-]')), LengthLimitingTextInputFormatter(200)];

  /// Trường hồ sơ cá nhân theo khóa
  static List<TextInputFormatter> profileField(String key) => switch (key) {
        'heightCm' || 'weightKg' || 'visionScore' => [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
        'email' => email,
        'phone' => phone,
        'facebook' || 'xHandle' => link,
        'medicalHistory' => note,
        _ => text(200),
      };
}
