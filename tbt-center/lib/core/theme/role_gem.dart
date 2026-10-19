/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';

/// Mỗi vai trò một loại đá quý, chỉ đổi màu nhấn.
/// Tên hiển thị theo ngôn ngữ nằm ở `LocalizedNames.gemName`.
enum RoleGem {
  gold(Color(0xFFD4AF37), Color(0xFF8A6E1F), Color(0xFF7A5C0F)),
  platinum(Color(0xFFE5E4E2), Color(0xFF8E8D8A), Color(0xFF55585E)),
  emerald(Color(0xFF3FCF8E), Color(0xFF1B6B47), Color(0xFF17694A)),
  ruby(Color(0xFFFF4D79), Color(0xFF8C1C3A), Color(0xFFA51D47)),
  sapphire(Color(0xFF5B8DEF), Color(0xFF233F7A), Color(0xFF2A52A3)),
  diamond(Color(0xFFB9F2FF), Color(0xFF5E8C99), Color(0xFF22677A)),
  amethyst(Color(0xFFB39DDB), Color(0xFF5B4A82), Color(0xFF5B4785));

  const RoleGem(this.color, this.deep, this.onLight);

  /// Màu nhấn trên nền tối.
  final Color color;

  /// Tông tối hơn, dùng làm đầu kia của dải chuyển màu ánh kim.
  final Color deep;

  /// Màu nhấn trên nền sáng, tương phản ≥ 4.5 với nền thẻ trắng.
  final Color onLight;

  Color accent(Brightness brightness) => brightness == Brightness.dark ? color : onLight;

  /// Dải ánh kim cho logo, tiêu đề lời chào
  List<Color> shine(Brightness brightness) => brightness == Brightness.dark
      ? [deep, color, Colors.white, color, deep]
      : [onLight, deep, Color.lerp(onLight, color, 0.35)!, deep, onLight];

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
