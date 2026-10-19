/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/knowledge_graph.dart';

/// Màu theo loại nút; nút khái niệm dùng màu nhấn của vai trò
Color nodeColor(NodeType type, Color accent) => switch (type) {
      NodeType.concept => accent,
      NodeType.process => const Color(0xFFE0A458),
      NodeType.step => const Color(0xFF7FB7BE),
      NodeType.rule => const Color(0xFFC3A6FF),
      NodeType.role => const Color(0xFFF28B82),
      NodeType.service => const Color(0xFF9AA0A6),
      NodeType.technology => const Color(0xFF8AB4F8),
      NodeType.pattern => const Color(0xFFFF8BCB),
      NodeType.region => const Color(0xFF81C995),
      NodeType.document => const Color(0xFFFDD663),
    };

double nodeRadius(GraphNode n, {required bool center}) => center ? 26 : 9 + min(n.degree, 12) * 0.5;

/// Trên điện thoại chỉ vẽ chừng này nút quanh tâm; danh sách liên kết vẫn đủ
const maxDrawnNeighbors = 14;

// Loại quan trọng xếp trước khi phải bớt nút
const _typePriority = [
  NodeType.process,
  NodeType.rule,
  NodeType.step,
  NodeType.concept,
  NodeType.document,
  NodeType.role,
  NodeType.pattern,
  NodeType.region,
  NodeType.service,
  NodeType.technology,
];

/// Chỉ giữ nút giữa và tối đa [maxDrawnNeighbors] nút nối thẳng với nó
GraphView visibleGraph(GraphView view) {
  final direct = {
    for (final e in view.edges)
      if (e.source == view.center.id) e.target else if (e.target == view.center.id) e.source,
  };
  final neighbors = view.nodes.where((n) => direct.contains(n.id)).toList()
    ..sort((a, b) {
      final byType = _typePriority.indexOf(a.type).compareTo(_typePriority.indexOf(b.type));
      return byType != 0 ? byType : a.label.compareTo(b.label);
    });
  final keep = {view.center.id, for (final n in neighbors.take(maxDrawnNeighbors)) n.id};
  return GraphView(
    center: view.center,
    nodes: [for (final n in view.nodes) if (keep.contains(n.id)) n],
    edges: [for (final e in view.edges) if (keep.contains(e.source) && keep.contains(e.target)) e],
  );
}

/// Bố trí hình tia: nút giữa ở tâm, nút quanh nó chia đều trên hai vòng elip so le
/// để chữ của hai nút cạnh nhau không đè lên nhau. Cùng dữ liệu thì luôn ra cùng hình.
Map<String, Offset> layoutGraph(GraphView view, Size size) {
  final mid = size.center(Offset.zero);
  final others = [
    for (final n in view.nodes)
      if (n.id != view.center.id) n,
  ]..sort((a, b) {
      final byType = _typePriority.indexOf(a.type).compareTo(_typePriority.indexOf(b.type));
      return byType != 0 ? byType : a.label.compareTo(b.label);
    });
  // Chừa lề cho chữ hai bên
  // Elip theo khung để dùng hết chiều cao; chừa lề cho chữ hai bên
  final rx = size.width / 2 - 88;
  final ry = size.height / 2 - 44;
  final pos = <String, Offset>{view.center.id: mid};
  for (var i = 0; i < others.length; i++) {
    final angle = -pi / 2 + 2 * pi * i / others.length;
    final scale = others.length > 6 && i.isOdd ? 0.6 : 1.0;
    pos[others[i].id] = mid + Offset(cos(angle) * rx * scale, sin(angle) * ry * scale);
  }
  return pos;
}

/// Vẽ đồ thị, chạm vào nút thì gọi [onTapNode]
class GraphCanvas extends StatefulWidget {
  const GraphCanvas({super.key, required this.view, required this.onTapNode});

  final GraphView view;
  final ValueChanged<GraphNode> onTapNode;

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {
  late GraphView _drawn = visibleGraph(widget.view);
  Map<String, Offset> _positions = const {};
  Size _laidOutFor = Size.zero;

  @override
  void didUpdateWidget(GraphCanvas old) {
    super.didUpdateWidget(old);
    if (old.view != widget.view) {
      _drawn = visibleGraph(widget.view);
      _laidOutFor = Size.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, max(constraints.maxHeight, 280));
      if (_laidOutFor != size) {
        _positions = layoutGraph(_drawn, size);
        _laidOutFor = size;
      }
      return InteractiveViewer(
        minScale: 0.8,
        maxScale: 3,
        boundaryMargin: const EdgeInsets.all(80),
        child: GestureDetector(
          onTapUp: (d) {
            final hit = _hitTest(d.localPosition);
            if (hit != null) widget.onTapNode(hit);
          },
          child: CustomPaint(size: size, painter: _GraphPainter(_drawn, _positions, accent)),
        ),
      );
    });
  }

  GraphNode? _hitTest(Offset p) {
    GraphNode? best;
    var bestDistance = double.infinity;
    for (final n in _drawn.nodes) {
      final pos = _positions[n.id];
      if (pos == null) continue;
      final d = (pos - p).distance;
      if (d < nodeRadius(n, center: n.id == _drawn.center.id) + 16 && d < bestDistance) {
        best = n;
        bestDistance = d;
      }
    }
    return best;
  }
}

class _GraphPainter extends CustomPainter {
  _GraphPainter(this.view, this.positions, this.accent);

  final GraphView view;
  final Map<String, Offset> positions;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final byId = {for (final n in view.nodes) n.id: n};
    final mid = positions[view.center.id] ?? size.center(Offset.zero);
    // Cạnh giữa hai nút vòng ngoài vẽ mờ trước, cạnh nối với tâm vẽ đậm sau
    for (final touchesCenter in [false, true]) {
      final paint = Paint()
        ..color = touchesCenter ? accent.withValues(alpha: 0.55) : const Color(0x553A3942)
        ..strokeWidth = touchesCenter ? 1.6 : 1;
      for (final e in view.edges) {
        if ((e.source == view.center.id || e.target == view.center.id) != touchesCenter) continue;
        final a = positions[e.source];
        final b = positions[e.target];
        final target = byId[e.target];
        if (a == null || b == null || target == null) continue;
        final dir = (b - a) / max((b - a).distance, 0.01);
        final end = b - dir * (nodeRadius(target, center: target.id == view.center.id) + 2);
        // Cạnh do máy suy luận vẽ nét đứt
        if (e.inferred) {
          _dashed(canvas, a, end, paint);
        } else {
          canvas.drawLine(a, end, paint);
        }
        if (touchesCenter) _arrow(canvas, end, dir, paint.color);
      }
    }
    // Vẽ hết nút trước, chữ sau; ô đã có chữ hoặc nút thì chữ mới tìm chỗ khác
    final taken = <Rect>[];
    for (final n in view.nodes) {
      final p = positions[n.id];
      if (p == null) continue;
      final isCenter = n.id == view.center.id;
      final radius = nodeRadius(n, center: isCenter);
      final color = nodeColor(n.type, accent);
      if (isCenter) {
        canvas.drawCircle(p, radius + 6, Paint()..color = color.withValues(alpha: 0.18));
      }
      canvas.drawCircle(p, radius, Paint()..color = color);
      taken.add(Rect.fromCircle(center: p, radius: radius + 2));
    }
    final center = positions[view.center.id];
    if (center != null) {
      final r = nodeRadius(view.center, center: true);
      _label(canvas, size, taken, view.center.label, [(center + Offset(0, r + 8), const Offset(0, 1))],
          fontSize: 13, maxWidth: 150, bold: true);
    }
    for (final n in view.nodes) {
      final p = positions[n.id];
      if (p == null || n.id == view.center.id) continue;
      final r = nodeRadius(n, center: false) + 6;
      final out = p - mid;
      final dir = out.distance < 1 ? const Offset(0, 1) : out / out.distance;
      final side = dir.dx < 0 ? -1.0 : 1.0;
      // Thứ tự thử: phía ngoài, dưới, trên, phía đối diện
      _label(canvas, size, taken, n.label, [
        (p + dir * r, dir),
        (p + Offset(0, r), const Offset(0, 1)),
        (p - Offset(0, r), const Offset(0, -1)),
        (p - Offset(side * r, 0), Offset(-side, 0)),
      ], fontSize: 11, maxWidth: 84);
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    final length = (b - a).distance;
    final dir = (b - a) / max(length, 0.01);
    for (var d = 0.0; d < length; d += 9) {
      canvas.drawLine(a + dir * d, a + dir * min(d + 5, length), paint);
    }
  }

  void _arrow(Canvas canvas, Offset tip, Offset dir, Color color) {
    final normal = Offset(-dir.dy, dir.dx);
    final a = tip - dir * 7 + normal * 3.5;
    final b = tip - dir * 7 - normal * 3.5;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..close(),
      Paint()..color = color,
    );
  }

  void _label(Canvas canvas, Size canvasSize, List<Rect> taken, String text, List<(Offset, Offset)> spots,
      {required double fontSize, required double maxWidth, bool bold = false}) {
    Rect? chosen;
    TextPainter? chosenPainter;
    Rect? fallback;
    TextPainter? fallbackPainter;
    for (final (anchor, dir) in spots) {
      final align = dir.dx.abs() < 0.35
          ? TextAlign.center
          : dir.dx > 0
              ? TextAlign.left
              : TextAlign.right;
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.15,
            color: AppColors.textMain,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        textAlign: align,
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      )..layout(maxWidth: maxWidth);
      final w = painter.width;
      final h = painter.height;
      final raw = switch (align) {
        TextAlign.left => Offset(anchor.dx, anchor.dy - h / 2),
        TextAlign.right => Offset(anchor.dx - w, anchor.dy - h / 2),
        _ => Offset(anchor.dx - w / 2, dir.dy < 0 ? anchor.dy - h : anchor.dy),
      };
      // Chữ sát mép thì đẩy vào trong, không bị cắt
      final topLeft = Offset(
        raw.dx.clamp(4, max(4, canvasSize.width - w - 4)),
        raw.dy.clamp(4, max(4, canvasSize.height - h - 4)),
      );
      final rect = Rect.fromLTWH(topLeft.dx - 3, topLeft.dy - 1, w + 6, h + 2);
      fallback ??= rect;
      fallbackPainter ??= painter;
      if (!taken.any(rect.overlaps)) {
        chosen = rect;
        chosenPainter = painter;
        break;
      }
    }
    final rect = chosen ?? fallback!;
    final painter = chosenPainter ?? fallbackPainter!;
    taken.add(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = AppColors.card.withValues(alpha: 0.85),
    );
    painter.paint(canvas, rect.topLeft + const Offset(3, 1));
  }

  // Trình đọc màn hình và test đọc được từng nút
  @override
  SemanticsBuilderCallback get semanticsBuilder => (size) => [
        for (final n in view.nodes)
          if (positions[n.id] case final p?)
            CustomPainterSemantics(
              rect: Rect.fromCircle(center: p, radius: nodeRadius(n, center: n.id == view.center.id) + 6),
              properties: SemanticsProperties(label: n.label, textDirection: TextDirection.ltr),
            ),
      ];

  @override
  bool shouldRepaint(_GraphPainter old) =>
      old.view != view || old.positions != positions || old.accent != accent;

  @override
  bool shouldRebuildSemantics(_GraphPainter old) => shouldRepaint(old);
}
