/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Quay lại: vuốt sang phải hoặc chạm hai lần.
class BackGestures extends StatefulWidget {
  const BackGestures({super.key, required this.navigatorKey, required this.child});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<BackGestures> createState() => _BackGesturesState();
}

class _BackGesturesState extends State<BackGestures> {
  static const _doubleTapGap = Duration(milliseconds: 300);
  static const _tapSlop = 18.0;

  final _down = <int, ({Offset at, Duration time})>{};
  ({Offset at, Duration time})? _lastTap;
  double _dragDx = 0;

  void _back() {
    final navigator = widget.navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) navigator.maybePop();
  }

  bool get _typing => FocusManager.instance.primaryFocus?.context?.widget is EditableText;

  void _pointerDown(PointerDownEvent e) {
    _down[e.pointer] = (at: e.position, time: e.timeStamp);
  }

  void _pointerUp(PointerUpEvent e) {
    final start = _down.remove(e.pointer);
    // Chạm giả lập (timeStamp 0) không tính
    if (start == null || _down.isNotEmpty || e.timeStamp == Duration.zero) return;
    final isTap = (e.position - start.at).distance < _tapSlop && e.timeStamp - start.time < _doubleTapGap;
    if (!isTap) {
      _lastTap = null;
      return;
    }
    final last = _lastTap;
    if (last != null && e.timeStamp - last.time < _doubleTapGap && (e.position - last.at).distance < 40 && !_typing) {
      _lastTap = null;
      _back();
    } else {
      _lastTap = (at: e.position, time: e.timeStamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _pointerDown,
      onPointerUp: _pointerUp,
      onPointerCancel: (e) => _down.remove(e.pointer),
      child: RawGestureDetector(
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
      ),
    );
  }
}
