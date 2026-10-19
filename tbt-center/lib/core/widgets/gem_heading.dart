/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';

import '../theme/role_gem.dart';

/// Tiêu đề phủ dải màu ánh kim theo đá quý của vai trò.
class GemHeading extends StatelessWidget {
  const GemHeading(this.text, {super.key, required this.gem, this.style});

  final String text;
  final RoleGem gem;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? Theme.of(context).textTheme.displayMedium;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gem.shine(Theme.of(context).brightness),
        stops: const [0, 0.35, 0.5, 0.65, 1],
      ).createShader(bounds),
      child: Text(text, style: textStyle),
    );
  }
}
