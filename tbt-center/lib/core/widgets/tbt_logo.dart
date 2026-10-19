/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';

import '../theme/role_gem.dart';

/// Logo TBT Center, màu theo đá quý của role
class TbtLogo extends StatelessWidget {
  const TbtLogo({super.key, required this.gem, this.height = 120, this.showTagline = true});

  final RoleGem gem;
  final double height;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'TBT Center',
      image: true,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gem.deep, gem.color, Colors.white, gem.color, gem.deep],
          stops: const [0, 0.25, 0.45, 0.65, 1],
        ).createShader(bounds),
        child: SizedBox(
          height: height,
          width: height * _viewBox.width / _viewBox.height,
          child: CustomPaint(painter: _LogoPainter(showTagline: showTagline)),
        ),
      ),
    );
  }
}

// Khung của file SVG gốc
const _viewBox = Rect.fromLTWH(80, 30, 460, 280);

class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.showTagline});

  final bool showTagline;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / _viewBox.height;
    canvas
      ..scale(scale)
      ..translate(-_viewBox.left, -_viewBox.top);
    final paint = Paint()..color = Colors.white;

    for (final x in [100.0, 410.0]) {
      canvas
        ..drawRect(Rect.fromLTWH(x, 40, 110, 32), paint)
        ..drawRect(Rect.fromLTWH(x + 39, 40, 32, 150), paint);
    }

    final b = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(250, 40)
      ..lineTo(320, 40)
      ..quadraticBezierTo(362, 40, 362, 78)
      ..quadraticBezierTo(362, 104, 342, 113)
      ..quadraticBezierTo(370, 122, 370, 152)
      ..quadraticBezierTo(370, 190, 325, 190)
      ..lineTo(250, 190)
      ..close()
      ..moveTo(282, 68)
      ..lineTo(282, 96)
      ..lineTo(315, 96)
      ..quadraticBezierTo(331, 96, 331, 82)
      ..quadraticBezierTo(331, 68, 315, 68)
      ..close()
      ..moveTo(282, 122)
      ..lineTo(282, 162)
      ..lineTo(320, 162)
      ..quadraticBezierTo(338, 162, 338, 142)
      ..quadraticBezierTo(338, 122, 320, 122)
      ..close();
    canvas
      ..drawPath(b, paint)
      ..drawRect(const Rect.fromLTWH(100, 212, 420, 2.5), paint);

    _text(canvas, 'CENTER', 46, 22, 262, FontWeight.w700);
    if (showTagline) _text(canvas, 'MULTINATIONAL CONSTRUCTION GROUP', 13, 5, 298, FontWeight.w400);
  }

  void _text(Canvas canvas, String text, double size, double spacing, double baseline, FontWeight weight) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'serif',
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // Bù letterSpacing sau chữ cuối
    final width = painter.width - spacing;
    final top = baseline - painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    painter.paint(canvas, Offset(310 - width / 2, top));
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => oldDelegate.showTagline != showTagline;
}
