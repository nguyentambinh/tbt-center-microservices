/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Cột 3D nhìn chéo: mỗi cột vẽ mặt trước, mặt bên (tối hơn) và nắp (sáng hơn)
class IsometricBarsPainter extends CustomPainter {
  IsometricBarsPainter({required this.labels, required this.values, required this.colors, required this.grid, required this.text});

  final List<String> labels;
  final List<double> values;
  final List<Color> colors;
  final Color grid;
  final Color text;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxValue = values.fold<double>(1, math.max);
    final slot = size.width / (values.length + 1);
    final bar = slot * 0.55;
    final depth = bar * 0.5;
    final floor = size.height - 28;
    final top = depth + 16;
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    // Sàn và lưới nghiêng theo chiều sâu
    for (var i = 0; i <= 4; i++) {
      final y = floor - (floor - top) * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width - depth, y), gridPaint);
      canvas.drawLine(Offset(size.width - depth, y), Offset(size.width, y - depth), gridPaint);
    }
    for (var i = 0; i < values.length; i++) {
      final h = (floor - top) * values[i] / maxValue;
      final x = slot * (i + 0.5);
      final base = colors[i];
      final hsl = HSLColor.fromColor(base);
      final front = Rect.fromLTWH(x, floor - h, bar, h);
      canvas.drawRect(front, Paint()..color = base);
      final side = Path()
        ..moveTo(x + bar, floor - h)
        ..lineTo(x + bar + depth, floor - h - depth)
        ..lineTo(x + bar + depth, floor - depth)
        ..lineTo(x + bar, floor)
        ..close();
      canvas.drawPath(side, Paint()..color = hsl.withLightness((hsl.lightness * 0.6).clamp(0, 1)).toColor());
      final cap = Path()
        ..moveTo(x, floor - h)
        ..lineTo(x + depth, floor - h - depth)
        ..lineTo(x + bar + depth, floor - h - depth)
        ..lineTo(x + bar, floor - h)
        ..close();
      canvas.drawPath(cap, Paint()..color = hsl.withLightness((hsl.lightness * 1.25).clamp(0, 1)).toColor());
      _label(canvas, NumberFormat.compact().format(values[i]), Offset(x + bar / 2 + depth / 2, floor - h - depth - 14), 10);
      _label(canvas, labels[i], Offset(x + bar / 2, floor + 6), 9);
    }
  }

  void _label(Canvas canvas, String value, Offset center, double fontSize) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: TextStyle(color: text, fontSize: fontSize)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, 0));
  }

  @override
  bool shouldRepaint(IsometricBarsPainter old) => old.values != values || old.colors != colors;
}
