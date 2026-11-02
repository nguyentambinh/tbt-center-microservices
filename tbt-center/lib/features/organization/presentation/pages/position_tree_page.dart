// Nguyễn Tâm Bình - 2324801030003
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/input_rules.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../admin/admin_repository.dart';
import '../../../hr/presentation/widgets/executive_actions.dart';
import '../../domain/organization.dart';
import '../providers/organization_providers.dart';
import '../widgets/org_actions.dart';
import 'org_tree_page.dart';

typedef PositionTreeData = ({List<PositionItem> positions, List<TreePerson> people});

final positionTreeProvider = FutureProvider.autoDispose<PositionTreeData>((ref) async {
  final results = await Future.wait<Object>([
    ref.watch(adminRepositoryProvider).positions(),
    ref.watch(organizationRepositoryProvider).orgTree(),
  ]);
  final tree = results[1] as OrgTree;
  return (
    positions: results[0] as List<PositionItem>,
    people: [for (final d in tree.departments) ...d.people, ...tree.unassigned],
  );
});

enum TreeNodeKind { tier, position, person }

/// Một nút trong không gian 3D; [parent] là đầu trên của đường liên kết
class TreeNode3 {
  TreeNode3(this.x, this.y, this.z, {required this.kind, required this.level, required this.label, this.ring = 0, this.parent, this.position, this.person});

  final double x;
  final double y;
  final double z;
  final TreeNodeKind kind;
  final int level;
  final String label;

  /// Bán kính vòng tròn của tầng
  final double ring;
  final TreeNode3? parent;
  final PositionItem? position;
  final TreePerson? person;

  Offset screen = Offset.zero;
  double depth = 0;
  double scale = 1;
  bool dimmed = false;

  double get radius => switch (kind) {
        TreeNodeKind.tier => 11,
        TreeNodeKind.position => 8,
        TreeNodeKind.person => 5,
      };
}

/// Người giữ theo tên chức vụ; người có chức vụ ngoài danh mục cũng được giữ lại
Map<String, List<TreePerson>> holdersByPosition(List<TreePerson> people) {
  final holders = <String, List<TreePerson>>{};
  for (final p in people) {
    (holders[p.position ?? '-'] ??= []).add(p);
  }
  return holders;
}

const _maxRing = 240.0;
const _nodeGap = 44.0;

/// Dựng tầng theo cấp, cấp cao ở trên: trục tầng, vòng chức vụ, ngoài cùng là người giữ
List<TreeNode3> buildPositionScene({
  required List<PositionItem> positions,
  required List<TreePerson> people,
  required bool withPeople,
  required String Function(int level) tierName,
  String noPosition = '-',
}) {
  final holders = holdersByPosition(people);
  final known = {for (final p in positions) p.name};
  final catalog = <PositionItem>[
    ...positions,
    for (final entry in holders.entries)
      if (!known.contains(entry.key)) (id: '', name: entry.key, level: entry.value.first.level, holders: entry.value.length),
  ];
  final nodes = <TreeNode3>[];
  final tierGap = withPeople ? 170.0 : 150.0;
  TreeNode3? above;
  for (var level = 6; level >= 1; level--) {
    final row = [
      for (final p in catalog)
        if (p.level == level && (!withPeople || (holders[p.name]?.isNotEmpty ?? false))) p,
    ];
    if (row.isEmpty) continue;
    final y = (level - 3.5) * tierGap;
    // Tầng đông thì xếp hai vòng để cây không bị bè ra
    final ring = math.min(90.0 + row.length * 24, _maxRing);
    final outer = math.min(row.length, (math.pi * 2 * ring / _nodeGap).floor());
    final tier = TreeNode3(0, y, 0, kind: TreeNodeKind.tier, level: level, label: tierName(level), ring: ring, parent: above);
    nodes.add(tier);
    above = tier;
    for (final (i, position) in row.indexed) {
      final inner = i >= outer;
      final count = inner ? row.length - outer : outer;
      final angle = (inner ? i - outer + 0.5 : i) / count * math.pi * 2 + level * 0.7;
      final r = inner ? ring * 0.6 : ring;
      final py = inner ? y + 30 : y;
      final node = TreeNode3(math.cos(angle) * r, py, math.sin(angle) * r,
          kind: TreeNodeKind.position, level: level, label: position.name == '-' ? noPosition : position.name, parent: tier, position: position);
      nodes.add(node);
      if (!withPeople) continue;
      final list = holders[position.name]!;
      final spread = math.min(math.pi * 2 / count * 0.8, 1.6);
      for (final (j, person) in list.indexed) {
        final band = j % 4;
        final a = angle + spread * ((j + 0.5) / list.length - 0.5);
        final pr = (inner ? r + 30 : r + 46) + band * 18;
        nodes.add(TreeNode3(math.cos(a) * pr, py - 16 - band * 12, math.sin(a) * pr,
            kind: TreeNodeKind.person, level: level, label: person.name, parent: node, person: person));
      }
    }
  }
  return nodes;
}

/// Góc nhìn và đồng hồ hiệu ứng: đổi là vẽ lại, không dựng lại widget
class _TreeView extends ChangeNotifier {
  static const startAngle = 0.5;
  static const startTilt = 0.38;

  double angle = startAngle;
  double tilt = startTilt;
  double zoom = 1;
  double time = 0;
  double idle = 0;
  bool touching = false;

  void tick(double seconds) {
    time += seconds;
    idle += seconds;
    // Tự xoay chậm khi không chạm
    if (!touching && idle > 2.5) angle += seconds * 0.16;
    notifyListeners();
  }

  void drag(Offset delta) {
    angle += delta.dx / 120;
    tilt = (tilt + delta.dy / 160).clamp(-1.3, 1.4);
    idle = 0;
  }

  void setZoom(double value) {
    zoom = value.clamp(0.5, 5.0);
    idle = 0;
  }

  void reset() {
    angle = startAngle;
    tilt = startTilt;
    zoom = 1;
    idle = 0;
  }
}

/// Cây chức vụ cho Văn phòng quản lý: tab chức vụ theo tầng và tab người giữ chức vụ; đổi chức vụ ngay trên cây
class PositionTreePage extends ConsumerStatefulWidget {
  const PositionTreePage({super.key});

  @override
  ConsumerState<PositionTreePage> createState() => _PositionTreePageState();
}

class _PositionTreePageState extends ConsumerState<PositionTreePage> {
  String _query = '';

  Future<void> _changePosition(TreePerson person) async {
    final l10n = AppLocalizations.of(context);
    if (await showChangePositionDialog(context, employeeId: person.id, name: person.name)) {
      ref.invalidate(positionTreeProvider);
      showDone(l10n.execApplied);
    }
  }

  void _openPerson(TreePerson person) => showPersonInfo(context, person, onChangePosition: () => _changePosition(person));

  void _openPosition(PositionItem position, List<TreePerson> holders) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(position.name == '-' ? l10n.positionTreeNoPosition : position.name, style: Theme.of(sheet).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text('${levelName(l10n, position.level)} · ${l10n.adminHolders(holders.length)}', style: TextStyle(color: sheet.tbt.textSecondary)),
              ]),
            ),
            if (holders.isEmpty)
              Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), child: Text(l10n.positionTreeNoHolder))
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final person in holders)
                      ListTile(
                        title: Text(person.name),
                        subtitle: person.departmentName == null ? null : Text(person.departmentName!),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(sheet);
                          _openPerson(person);
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(l10n.positionTree),
          bottom: TabBar(tabs: [Tab(text: l10n.positionTreeTabPositions), Tab(text: l10n.positionTreeTabPeople)]),
        ),
        body: switch (ref.watch(positionTreeProvider)) {
          AsyncValue(:final value?) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    inputFormatters: InputRules.search,
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.orgTreeSearch, isDense: true),
                    onChanged: (v) => setState(() => _query = foldText(v)),
                  ),
                ),
                const LevelLegend(),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final withPeople in [false, true])
                        PositionSceneView(
                          key: ValueKey(withPeople),
                          data: value,
                          withPeople: withPeople,
                          query: _query,
                          onPerson: _openPerson,
                          onPosition: (position) => _openPosition(position, holdersByPosition(value.people)[position.name] ?? const []),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(positionTreeProvider)),
          _ => const SkeletonList(),
        },
      ),
    );
  }
}

/// Khung 3D của một tab: kéo để xoay và nghiêng, chụm hai ngón để phóng to, bấm vào nút để xem
class PositionSceneView extends StatefulWidget {
  const PositionSceneView({super.key, required this.data, required this.withPeople, required this.query, required this.onPerson, required this.onPosition});

  final PositionTreeData data;
  final bool withPeople;
  final String query;
  final ValueChanged<TreePerson> onPerson;
  final ValueChanged<PositionItem> onPosition;

  @override
  State<PositionSceneView> createState() => PositionSceneViewState();
}

class PositionSceneViewState extends State<PositionSceneView> with SingleTickerProviderStateMixin {
  final _view = _TreeView();
  final _labels = <String, ui.Paragraph>{};
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _zoomAtStart = 1;
  List<TreeNode3> nodes = const [];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _view.tick((elapsed - _last).inMicroseconds / 1e6);
      _last = elapsed;
    })
      ..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _labels.clear();
    _rebuild();
  }

  @override
  void didUpdateWidget(PositionSceneView old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) _rebuild();
    if (old.query != widget.query) _applyQuery();
  }

  void _rebuild() {
    final l10n = AppLocalizations.of(context);
    nodes = buildPositionScene(
      positions: widget.data.positions,
      people: widget.data.people,
      withPeople: widget.withPeople,
      tierName: (level) => levelName(l10n, level),
      noPosition: l10n.positionTreeNoPosition,
    );
    _applyQuery();
  }

  void _applyQuery() {
    for (final node in nodes) {
      final text = '${node.label} ${node.person?.position ?? ''}';
      node.dimmed = widget.query.isNotEmpty && node.kind != TreeNodeKind.tier && !foldText(text).contains(widget.query);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _view.dispose();
    super.dispose();
  }

  void _tap(Offset at) {
    TreeNode3? best;
    for (final node in nodes) {
      if (node.kind == TreeNodeKind.tier) continue;
      final distance = (node.screen - at).distance;
      if (distance < node.radius * node.scale + 16 && (best == null || distance < (best.screen - at).distance)) best = node;
    }
    if (best?.person case final person?) {
      widget.onPerson(person);
    } else if (best?.position case final position?) {
      widget.onPosition(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tag = widget.withPeople ? 'people' : 'positions';
    Widget button(String name, IconData icon, String tip, VoidCallback onTap) =>
        FloatingActionButton.small(heroTag: 'position-tree-$tag-$name', tooltip: tip, onPressed: onTap, child: Icon(icon));
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onScaleStart: (_) {
              _zoomAtStart = _view.zoom;
              _view.touching = true;
            },
            onScaleUpdate: (d) {
              _view.drag(d.focalPointDelta);
              if (d.pointerCount > 1) _view.setZoom(_zoomAtStart * d.scale);
            },
            onScaleEnd: (_) => _view.touching = false,
            onTapUp: (d) => _tap(d.localPosition),
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _PositionTreePainter(
                  nodes: nodes,
                  view: _view,
                  labels: _labels,
                  colors: {for (var level = 1; level <= 6; level++) level: levelColor(context, level)},
                  text: context.tbt.textMain,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          right: 76,
          child: IgnorePointer(child: Text(l10n.positionTreeHint, style: TextStyle(fontSize: 12, color: context.tbt.textSecondary))),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Column(children: [
            button('in', Icons.add, l10n.viewZoomIn, () => _view.setZoom(_view.zoom * 1.25)),
            const SizedBox(height: 8),
            button('out', Icons.remove, l10n.viewZoomOut, () => _view.setZoom(_view.zoom * 0.8)),
            const SizedBox(height: 8),
            button('reset', Icons.center_focus_strong, l10n.viewReset, _view.reset),
          ]),
        ),
      ],
    );
  }
}

class _PositionTreePainter extends CustomPainter {
  _PositionTreePainter({required this.nodes, required this.view, required this.labels, required this.colors, required this.text}) : super(repaint: view);

  final List<TreeNode3> nodes;
  final _TreeView view;
  final Map<String, ui.Paragraph> labels;
  final Map<int, Color> colors;
  final Color text;

  static const _ringSegments = 56;

  late double _sinA = math.sin(view.angle);
  late double _cosA = math.cos(view.angle);
  late double _sinT = math.sin(view.tilt);
  late double _cosT = math.cos(view.tilt);
  double _focal = 900;
  double _fit = 1;
  Offset _center = Offset.zero;

  // Xoay quanh trục đứng, nghiêng, rồi chiếu phối cảnh
  (Offset, double, double) _project(double px, double py, double pz) {
    final x = px * _cosA - pz * _sinA;
    final z = px * _sinA + pz * _cosA;
    final y = py * _cosT - z * _sinT;
    final depth = py * _sinT + z * _cosT;
    final scale = _focal / (_focal + depth) * _fit;
    return (_center + Offset(x * scale, -y * scale), depth, scale);
  }

  ui.Paragraph _label(TreeNode3 node) => labels.putIfAbsent('${node.kind.name}|${node.label}', () {
        final tier = node.kind == TreeNodeKind.tier;
        final builder = ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: tier ? 12 : 11, maxLines: 1, ellipsis: '…', textAlign: TextAlign.center))
          ..pushStyle(ui.TextStyle(color: tier ? colors[node.level] : text, fontWeight: tier ? FontWeight.bold : FontWeight.w500))
          ..addText(node.label);
        return builder.build()..layout(const ui.ParagraphConstraints(width: 130));
      });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;
    _sinA = math.sin(view.angle);
    _cosA = math.cos(view.angle);
    _sinT = math.sin(view.tilt);
    _cosT = math.cos(view.tilt);
    var wide = 1.0;
    var tall = 1.0;
    for (final n in nodes) {
      wide = math.max(wide, math.max(n.x.abs(), n.z.abs()));
      tall = math.max(tall, n.y.abs());
    }
    _focal = math.max(wide, tall) * 3;
    // Vừa khung theo cả chiều ngang lẫn chiều cao; nghiêng làm vòng tròn cao thêm
    _fit = math.min(size.width / (wide * 2.1), size.height / (tall * 2.35 + wide * 0.75)) * view.zoom;
    _center = Offset(size.width / 2, size.height * 0.45);
    for (final n in nodes) {
      final (screen, depth, scale) = _project(n.x, n.y, n.z);
      n
        ..screen = screen
        ..depth = depth
        ..scale = scale;
    }
    _paintTiers(canvas);
    _paintLinks(canvas);
    _paintNodes(canvas);
    _paintLabels(canvas, size);
  }

  void _paintTiers(Canvas canvas) {
    final tiers = nodes.where((n) => n.kind == TreeNodeKind.tier).toList()..sort((a, b) => b.depth.compareTo(a.depth));
    for (final tier in tiers) {
      final path = Path();
      for (var i = 0; i <= _ringSegments; i++) {
        final a = i / _ringSegments * math.pi * 2;
        final (point, _, _) = _project(math.cos(a) * tier.ring, tier.y, math.sin(a) * tier.ring);
        i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
      }
      final color = colors[tier.level]!;
      canvas
        ..drawPath(path, Paint()..color = color.withValues(alpha: 0.07))
        ..drawPath(path, Paint()
          ..color = color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    }
  }

  void _paintLinks(Canvas canvas) {
    final line = Paint()..strokeWidth = 1.1;
    final pulse = Paint();
    for (final (i, node) in nodes.indexed) {
      final parent = node.parent;
      if (parent == null) continue;
      final color = colors[node.level]!;
      final fade = node.dimmed ? 0.08 : (0.65 - node.depth / (_focal * 2)).clamp(0.2, 0.75);
      line.color = color.withValues(alpha: fade);
      canvas.drawLine(parent.screen, node.screen, line);
      if (node.dimmed) continue;
      // Hạt sáng chạy từ cấp trên xuống dọc đường liên kết
      final t = (view.time * 0.4 + i * 0.137) % 1;
      pulse.color = color.withValues(alpha: math.sin(t * math.pi).clamp(0.0, 1.0));
      canvas.drawCircle(Offset.lerp(parent.screen, node.screen, t)!, 2.2 * node.scale.clamp(0.6, 1.6), pulse);
    }
  }

  void _paintNodes(Canvas canvas) {
    final sorted = [...nodes]..sort((a, b) => b.depth.compareTo(a.depth));
    final paint = Paint();
    for (final n in sorted) {
      final r = n.radius * n.scale.clamp(0.55, 2.2);
      final color = colors[n.level]!;
      final alpha = n.dimmed ? 0.18 : 1.0;
      if (n.kind == TreeNodeKind.tier) {
        final glow = 1.25 + math.sin(view.time * 2.2) * 0.2;
        paint.color = color.withValues(alpha: 0.22);
        canvas.drawCircle(n.screen, r * 1.7 * glow, paint);
      }
      // Hai lớp màu tạo khối cầu
      paint.color = Color.lerp(color, const Color(0xFF000000), 0.35)!.withValues(alpha: alpha);
      canvas.drawCircle(n.screen, r, paint);
      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(n.screen + Offset(-r * 0.12, -r * 0.12), r * 0.78, paint);
      paint.color = const Color(0xFFFFFFFF).withValues(alpha: 0.55 * alpha);
      canvas.drawCircle(n.screen + Offset(-r * 0.32, -r * 0.34), r * 0.24, paint);
    }
  }

  // Nhãn quan trọng và ở gần vẽ trước, nhãn đè lên nhau thì bỏ
  void _paintLabels(Canvas canvas, Size size) {
    int priority(TreeNode3 n) => switch (n.kind) {
          TreeNodeKind.tier => 0,
          TreeNodeKind.position => 1,
          TreeNodeKind.person => 2,
        };
    final order = nodes.where((n) => !n.dimmed).toList()
      ..sort((a, b) {
        final byKind = priority(a).compareTo(priority(b));
        return byKind != 0 ? byKind : a.depth.compareTo(b.depth);
      });
    final used = <Rect>[];
    for (final n in order) {
      final paragraph = _label(n);
      final width = math.min(paragraph.maxIntrinsicWidth + 6, 130.0);
      final top = n.screen.dy + n.radius * n.scale.clamp(0.55, 2.2) + 2;
      final rect = Rect.fromLTWH(n.screen.dx - width / 2, top, width, paragraph.height);
      if (rect.right < 0 || rect.left > size.width || rect.bottom < 0 || rect.top > size.height) continue;
      if (used.any(rect.overlaps)) continue;
      used.add(rect);
      canvas.drawParagraph(paragraph, Offset(n.screen.dx - 65, top));
    }
  }

  @override
  bool shouldRepaint(_PositionTreePainter old) => old.nodes != nodes || old.text != text || old.colors != colors;
}
