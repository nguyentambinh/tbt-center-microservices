/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Một nhóm cột (ví dụ một tháng): mỗi giá trị một cột, cùng thứ tự với
/// [BarSeries] của biểu đồ.
class BarGroup {
  const BarGroup(this.label, this.values);

  final String label;
  final List<double> values;
}

class BarSeries {
  const BarSeries(this.name, this.color);

  final String name;
  final Color color;
}

/// Biểu đồ cột nhóm đơn giản (R25), tự vẽ để khỏi thêm thư viện biểu đồ.
/// Có chú thích màu và nhãn giá trị lớn nhất ở trục dọc.
class GroupedBarChart extends StatelessWidget {
  const GroupedBarChart({
    super.key,
    required this.series,
    required this.groups,
    required this.formatValue,
    this.height = 180,
  });

  final List<BarSeries> series;
  final List<BarGroup> groups;
  final String Function(double value) formatValue;
  final double height;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodySmall;
    final maxValue = groups.expand((g) => g.values).fold<double>(0, max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          children: [
            for (final s in series)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, color: s.color),
                  const SizedBox(width: 6),
                  Text(s.name, style: text),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(formatValue(maxValue), style: text?.copyWith(color: AppColors.textSecondary)),
        SizedBox(
          height: height,
          width: double.infinity,
          child: Semantics(
            label: [
              for (final g in groups)
                '${g.label}: ${[for (var i = 0; i < series.length; i++) '${series[i].name} ${formatValue(g.values[i])}'].join(', ')}',
            ].join('; '),
            child: CustomPaint(
              painter: _BarPainter(
                groups: groups,
                colors: [for (final s in series) s.color],
                maxValue: maxValue,
                labelStyle: text?.copyWith(color: AppColors.textSecondary) ?? const TextStyle(fontSize: 11),
                axisColor: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.groups,
    required this.colors,
    required this.maxValue,
    required this.labelStyle,
    required this.axisColor,
  });

  final List<BarGroup> groups;
  final List<Color> colors;
  final double maxValue;
  final TextStyle labelStyle;
  final Color axisColor;

  static const _labelHeight = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - _labelHeight;
    canvas.drawLine(Offset(0, chartHeight), Offset(size.width, chartHeight), Paint()..color = axisColor);
    if (groups.isEmpty || maxValue <= 0) return;

    final groupWidth = size.width / groups.length;
    final barWidth = min(18.0, groupWidth * 0.7 / colors.length);
    for (var g = 0; g < groups.length; g++) {
      final group = groups[g];
      final start = g * groupWidth + (groupWidth - barWidth * colors.length) / 2;
      for (var i = 0; i < colors.length && i < group.values.length; i++) {
        final h = chartHeight * (group.values[i].clamp(0, maxValue) / maxValue);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(start + i * barWidth, chartHeight - h, barWidth - 2, h),
            topLeft: const Radius.circular(3),
            topRight: const Radius.circular(3),
          ),
          Paint()..color = colors[i],
        );
      }
      final label = TextPainter(
        text: TextSpan(text: group.label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: groupWidth);
      label.paint(canvas, Offset(g * groupWidth + (groupWidth - label.width) / 2, chartHeight + 3));
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.groups != groups || old.maxValue != maxValue || old.colors != colors;
}
