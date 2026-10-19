/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';

/// Mỗi vai trò một loại đá quý. Nền đen và viền vàng giữ nguyên, chỉ đổi màu nhấn.
/// Tên hiển thị theo ngôn ngữ nằm ở `LocalizedNames.gemName`.
enum RoleGem {
  gold(Color(0xFFD4AF37), Color(0xFF8A6E1F)),
  platinum(Color(0xFFE5E4E2), Color(0xFF8E8D8A)),
  emerald(Color(0xFF3FCF8E), Color(0xFF1B6B47)),
  ruby(Color(0xFFFF4D79), Color(0xFF8C1C3A)),
  sapphire(Color(0xFF5B8DEF), Color(0xFF233F7A)),
  diamond(Color(0xFFB9F2FF), Color(0xFF5E8C99)),
  amethyst(Color(0xFFB39DDB), Color(0xFF5B4A82));

  const RoleGem(this.color, this.deep);

  final Color color;

  /// Tông tối hơn, dùng làm đầu kia của dải chuyển màu ánh kim.
  final Color deep;

  static RoleGem forRole(String role) => switch (role) {
        'executive' => gold,
        'admin' => platinum,
        'hr' => emerald,
        'finance' => ruby,
        'employee' => sapphire,
        'candidate' => diamond,
        'auditor' => amethyst,
        _ => gold,
      };
}
