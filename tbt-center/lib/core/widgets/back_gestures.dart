/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Quay lại: vuốt sang phải.
class BackGestures extends StatefulWidget {
  const BackGestures({super.key, required this.navigatorKey, required this.child});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<BackGestures> createState() => _BackGesturesState();
}

class _BackGesturesState extends State<BackGestures> {
  double _dragDx = 0;

  void _back() {
    final navigator = widget.navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) navigator.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        // List cuộn ngang bên trong vẫn được ưu tiên
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
          HorizontalDragGestureRecognizer.new,
          (r) => r
            ..onStart = (_) {
              _dragDx = 0;
            }
            ..onUpdate = (d) {
              _dragDx += d.delta.dx;
            }
            ..onEnd = (d) {
              if (_dragDx > 80 && (d.primaryVelocity ?? 0) > 250) _back();
            },
        ),
      },
      child: Stack(
        children: [
          widget.child,
          // Dải mép trái nằm trên cùng, để tab vuốt ngang không chiếm cú vuốt back
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 16,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) => _dragDx = 0,
              onHorizontalDragUpdate: (d) => _dragDx += d.delta.dx,
              onHorizontalDragEnd: (d) {
                if (_dragDx > 60) _back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
