/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_states.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../core/widgets/remote_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/organization.dart';
import '../providers/organization_providers.dart';
import '../widgets/head_tag.dart';
import '../../../../core/widgets/input_rules.dart';

final orgTreeProvider = FutureProvider.autoDispose<OrgTree>((ref) => ref.watch(organizationRepositoryProvider).orgTree());

/// Tên cấp chức vụ 1..6
String levelName(AppLocalizations l10n, int level) => switch (level) {
      6 => l10n.level6,
      5 => l10n.level5,
      4 => l10n.level4,
      3 => l10n.level3,
      2 => l10n.level2,
      _ => l10n.level1,
    };

/// Màu theo cấp: cấp càng cao càng đậm
Color levelColor(BuildContext context, int level) => switch (level) {
      >= 6 => context.tbt.brandGold,
      5 => context.tbt.danger,
      4 => Theme.of(context).colorScheme.primary,
      3 => context.tbt.caution,
      2 => context.tbt.info,
      _ => context.tbt.textSecondary,
    };

/// Bỏ dấu tiếng Việt, chữ thường: "Bảo", "BẢO", "bao" đều thành "bao"
String foldText(String s) {
  const from = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  const to = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
  return [for (final c in s.toLowerCase().split('')) from.contains(c) ? to[from.indexOf(c)] : c].join().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Sơ đồ tổ chức: cây phòng ban → trưởng phòng → người theo cấp chức vụ, 2D và 3D
class OrgTreePage extends ConsumerStatefulWidget {
  const OrgTreePage({super.key});

  @override
  ConsumerState<OrgTreePage> createState() => _OrgTreePageState();
}

class _OrgTreePageState extends ConsumerState<OrgTreePage> {
  String _query = '';

  /// Phòng ban đang xem; null là tất cả
  Set<String>? _shown;

  bool _hit(TreePerson p) => _query.isNotEmpty && (foldText(p.name).contains(_query) || foldText(p.position ?? '').contains(_query));

  void _toggle(OrgTree tree, String id, bool on) => setState(() {
        final shown = _shown ?? {for (final d in tree.departments) d.id};
        on ? shown.add(id) : shown.remove(id);
        _shown = shown.length == tree.departments.length ? null : shown;
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tree = ref.watch(orgTreeProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.orgTree),
          bottom: TabBar(tabs: [Tab(text: l10n.chart2d), Tab(text: l10n.chart3d)]),
        ),
        body: switch (tree) {
          AsyncValue(:final value?) => Builder(builder: (context) {
              final visible = OrgTree(departments: [for (final d in value.departments) if (_shown?.contains(d.id) ?? true) d]);
              // Tìm ra người thì chỉ sáng phòng ban có người đó; không ai khớp mới xét tên phòng ban
              final anyPerson = visible.departments.any((d) => d.people.any(_hit));
              bool deptHit(TreeDepartment d) => _query.isNotEmpty && (anyPerson ? d.people.any(_hit) : foldText(d.name).contains(_query));
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          inputFormatters: InputRules.search,
                          decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.orgTreeSearch, isDense: true),
                          onChanged: (v) => setState(() => _query = foldText(v)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      MenuAnchor(
                        menuChildren: [
                          CheckboxMenuButton(
                            value: _shown == null,
                            closeOnActivate: false,
                            onChanged: (_) => setState(() => _shown = _shown == null ? <String>{} : null),
                            child: Text(l10n.filterAll, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          for (final d in value.departments)
                            CheckboxMenuButton(
                              value: _shown?.contains(d.id) ?? true,
                              closeOnActivate: false,
                              onChanged: (on) => _toggle(value, d.id, on ?? false),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 240),
                                child: Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ),
                        ],
                        builder: (context, menu, _) => Tooltip(
                          message: l10n.filterDepartment,
                          child: OutlinedButton.icon(
                            onPressed: () => menu.isOpen ? menu.close() : menu.open(),
                            icon: const Icon(Icons.filter_list),
                            label: Text('${visible.departments.length}/${value.departments.length}'),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  _LevelLegend(),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _Tree2d(tree: visible, hit: _hit, deptHit: deptHit, query: _query),
                        _Tree3d(tree: visible, hit: _hit, deptHit: deptHit, query: _query),
                      ],
                    ),
                  ),
                ],
              );
            }),
          AsyncValue(:final error?) => ErrorView(error: error, onRetry: () => ref.invalidate(orgTreeProvider)),
          _ => const SkeletonList(),
        },
      ),
    );
  }
}

/// Thông tin một người: ảnh, chức vụ, cấp, phòng ban, nút mở hồ sơ
void showPersonInfo(BuildContext context, TreePerson p) {
  final l10n = AppLocalizations.of(context);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              SizedBox.square(dimension: 56, child: RemotePhoto(url: p.photoUrl, aspectRatio: 1, radius: 28, icon: Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: Theme.of(sheet).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text(p.position ?? '-', style: TextStyle(color: sheet.tbt.textSecondary)),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              Chip(label: Text(levelName(l10n, p.rank)), side: BorderSide(color: levelColor(sheet, p.rank)), labelStyle: TextStyle(color: levelColor(sheet, p.rank))),
              if (p.isHead) const HeadTag(),
              if (p.departmentName case final d?) Chip(avatar: const Icon(Icons.account_tree_outlined, size: 16), label: Text(d)),
            ]),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(sheet);
                context.push('${Routes.employees}/${Uri.encodeComponent(p.id)}');
              },
              icon: const Icon(Icons.badge_outlined),
              label: Text(l10n.viewProfile),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LevelLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final level in [6, 5, 4, 3, 2, 1])
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: levelColor(context, level), shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(levelName(l10n, level), style: TextStyle(fontSize: 11, color: context.tbt.textSecondary)),
              ]),
            ),
        ],
      ),
    );
  }
}

/// Cây 2D: gốc tập đoàn → các phòng ban (bấm để thu gọn/mở) → người theo cấp; phóng to, kéo được
class _Tree2d extends StatefulWidget {
  const _Tree2d({required this.tree, required this.hit, required this.deptHit, required this.query});

  final OrgTree tree;
  final bool Function(TreePerson) hit;
  final bool Function(TreeDepartment) deptHit;
  final String query;

  @override
  State<_Tree2d> createState() => _Tree2dState();
}

class _Tree2dState extends State<_Tree2d> {
  final _collapsed = <String>{};
  final _view = TransformationController();

  @override
  void dispose() {
    _view.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final departments = widget.tree.departments;
    final line = context.tbt.glassBorder;
    final searching = widget.query.isNotEmpty;
    return Stack(
      children: [
        InteractiveViewer(
          transformationController: _view,
          constrained: false,
          minScale: 0.3,
          maxScale: 2.5,
          boundaryMargin: const EdgeInsets.all(200),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Node(
                  width: 220,
                  color: context.tbt.brandGold,
                  title: departments.firstOrNull?.company ?? 'TBT Center',
                  subtitle: l10n.orgTreeSummary(departments.length, departments.fold(0, (s, d) => s + d.people.length)),
                ),
                for (final d in departments)
                  Builder(builder: (context) {
                    final open = !_collapsed.contains(d.id) || (searching && d.people.any(widget.hit));
                    final dim = searching && !widget.deptHit(d);
                    return Opacity(
                      opacity: dim ? 0.35 : 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: DecoratedBox(
                          decoration: BoxDecoration(border: Border(left: BorderSide(color: line, width: 2))),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () => setState(() => open ? _collapsed.add(d.id) : _collapsed.remove(d.id)),
                                  child: _Node(
                                    width: 250,
                                    color: Theme.of(context).colorScheme.primary,
                                    highlight: searching && widget.deptHit(d),
                                    title: '${open ? '▾' : '▸'} ${d.name}',
                                    subtitle: [l10n.employeesCount(d.people.length), if (d.head case final h?) h.name].join(' · '),
                                  ),
                                ),
                                if (open)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 28),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(border: Border(left: BorderSide(color: line, width: 1.5))),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          for (final p in d.people)
                                            Padding(
                                              padding: EdgeInsets.only(left: 12.0 + (6 - p.rank) * 14, top: 6),
                                              child: InkWell(
                                                onTap: () => showPersonInfo(context, p),
                                                child: Opacity(
                                                  opacity: searching && !widget.hit(p) ? 0.35 : 1,
                                                  child: _Node(
                                                    width: 230,
                                                    color: levelColor(context, p.rank),
                                                    highlight: widget.hit(p),
                                                    title: p.name,
                                                    subtitle: '${p.position ?? '-'} · ${levelName(l10n, p.rank)}',
                                                    trailing: p.isHead ? const HeadTag() : null,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Column(children: [
            FloatingActionButton.small(heroTag: 'tree-in', onPressed: () => _zoom(1.25), child: const Icon(Icons.add)),
            const SizedBox(height: 8),
            FloatingActionButton.small(heroTag: 'tree-out', onPressed: () => _zoom(0.8), child: const Icon(Icons.remove)),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'tree-toggle',
              tooltip: l10n.orgTreeToggle,
              onPressed: () => setState(() => _collapsed.length == departments.length ? _collapsed.clear() : _collapsed.addAll(departments.map((d) => d.id))),
              child: const Icon(Icons.unfold_less),
            ),
          ]),
        ),
      ],
    );
  }

  void _zoom(double factor) => _view.value = _view.value.clone()..scaleByDouble(factor, factor, 1, 1);
}

class _Node extends StatelessWidget {
  const _Node({required this.width, required this.color, required this.title, required this.subtitle, this.highlight = false, this.trailing});

  final double width;
  final Color color;
  final String title;
  final String subtitle;
  final bool highlight;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.tbt.glass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: highlight ? context.tbt.success : color, width: highlight ? 2.5 : 1.2),
        ),
        child: Row(children: [
          Container(width: 6, height: 30, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: context.tbt.textSecondary)),
            ]),
          ),
          ?trailing,
        ]),
      );
}

/// Một điểm trên cây 3D: tọa độ x, y (cao theo cấp), z
class _Point3 {
  _Point3(this.x, this.y, this.z, {required this.color, required this.radius, this.person, this.department, this.label, this.parent});

  final double x;
  final double y;
  final double z;
  final Color color;
  final double radius;
  final TreePerson? person;
  final TreeDepartment? department;
  final String? label;
  final _Point3? parent;
  Offset screen = Offset.zero;
  double depth = 0;
  double scale = 1;
}

/// Cây 3D: phòng ban xếp vòng tròn, người xếp tầng theo cấp (cấp cao ở trên); đứng yên, kéo ngang để xoay,
/// kéo dọc để nghiêng, chụm hai ngón để phóng to; có nút điều chỉnh; bấm vào người để xem
class _Tree3d extends StatefulWidget {
  const _Tree3d({required this.tree, required this.hit, required this.deptHit, required this.query});

  final OrgTree tree;
  final bool Function(TreePerson) hit;
  final bool Function(TreeDepartment) deptHit;
  final String query;

  @override
  State<_Tree3d> createState() => _Tree3dState();
}

class _Tree3dState extends State<_Tree3d> {
  static const _startAngle = 0.6;
  static const _startTilt = 0.45;

  double _angle = _startAngle;

  /// Nghiêng: dương là nhìn từ trên xuống, âm là nhìn từ dưới lên
  double _tilt = _startTilt;
  double _zoom = 1;
  double _zoomAtStart = 1;
  List<_Point3> _points = const [];

  void _view({double angle = 0, double tilt = 0, double zoom = 1}) => setState(() {
        _angle += angle;
        _tilt = (_tilt + tilt).clamp(-1.4, 1.5);
        _zoom = (_zoom * zoom).clamp(0.4, 4.0);
      });

  List<_Point3> _build(BuildContext context) {
    final departments = widget.tree.departments;
    final root = _Point3(0, 160, 0, color: context.tbt.brandGold, radius: 11, label: departments.firstOrNull?.company ?? 'TBT Center');
    final points = <_Point3>[root];
    final ring = 150.0 + departments.length * 6;
    for (final (i, d) in departments.indexed) {
      final angle = i / math.max(1, departments.length) * math.pi * 2;
      final cx = math.cos(angle) * ring;
      final cz = math.sin(angle) * ring;
      final dept = _Point3(cx, 95, cz, color: Theme.of(context).colorScheme.primary, radius: 8, department: d, label: d.name, parent: root);
      points.add(dept);
      for (final (j, p) in d.people.indexed) {
        final a = j / math.max(1, d.people.length) * math.pi * 2;
        final r = 18.0 + (6 - p.rank) * 8;
        points.add(_Point3(
          cx + math.cos(a) * r,
          -40 + p.rank * 22,
          cz + math.sin(a) * r,
          color: levelColor(context, p.rank),
          radius: p.isHead ? 7 : 4.5,
          person: p,
          label: p.isHead ? p.name : null,
          parent: dept,
        ));
      }
    }
    return points;
  }

  TreePerson? _tapped(Offset at) {
    _Point3? best;
    for (final p in _points.where((p) => p.person != null)) {
      final d = (p.screen - at).distance;
      if (d < p.radius * p.scale + 14 && (best == null || d < (best.screen - at).distance)) best = p;
    }
    return best?.person;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _points = _build(context);
    Widget button(String tag, IconData icon, String tip, VoidCallback onTap) =>
        FloatingActionButton.small(heroTag: 'tree3d-$tag', tooltip: tip, onPressed: onTap, child: Icon(icon));
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, box) => GestureDetector(
            onScaleStart: (_) => _zoomAtStart = _zoom,
            onScaleUpdate: (d) => setState(() {
              _angle += d.focalPointDelta.dx / 120;
              _tilt = (_tilt + d.focalPointDelta.dy / 160).clamp(-1.4, 1.5);
              if (d.pointerCount > 1) _zoom = (_zoomAtStart * d.scale).clamp(0.4, 4.0);
            }),
            onTapUp: (d) {
              if (_tapped(d.localPosition) case final p?) showPersonInfo(context, p);
            },
            child: CustomPaint(
              size: box.biggest,
              painter: _Tree3dPainter(
                points: _points,
                angle: _angle,
                tilt: _tilt,
                zoom: _zoom,
                line: context.tbt.glassBorder,
                text: context.tbt.textMain,
                highlight: context.tbt.success,
                hit: widget.hit,
                deptHit: widget.deptHit,
                searching: widget.query.isNotEmpty,
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Column(children: [
            button('in', Icons.add, l10n.viewZoomIn, () => _view(zoom: 1.25)),
            const SizedBox(height: 8),
            button('out', Icons.remove, l10n.viewZoomOut, () => _view(zoom: 0.8)),
            const SizedBox(height: 8),
            button('reset', Icons.center_focus_strong, l10n.viewReset, () => setState(() {
                  _angle = _startAngle;
                  _tilt = _startTilt;
                  _zoom = 1;
                })),
          ]),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Column(children: [
            button('top', Icons.keyboard_arrow_up, l10n.viewFromTop, () => _view(tilt: 0.2)),
            const SizedBox(height: 4),
            Row(children: [
              button('left', Icons.rotate_left, l10n.viewRotateLeft, () => _view(angle: -0.3)),
              const SizedBox(width: 44),
              button('right', Icons.rotate_right, l10n.viewRotateRight, () => _view(angle: 0.3)),
            ]),
            const SizedBox(height: 4),
            button('bottom', Icons.keyboard_arrow_down, l10n.viewFromBottom, () => _view(tilt: -0.2)),
          ]),
        ),
      ],
    );
  }
}

class _Tree3dPainter extends CustomPainter {
  _Tree3dPainter({required this.points, required this.angle, required this.tilt, required this.zoom, required this.line, required this.text, required this.highlight, required this.hit, required this.deptHit, required this.searching});

  final List<_Point3> points;
  final double angle;
  final double tilt;
  final double zoom;
  final Color line;
  final Color text;
  final Color highlight;
  final bool Function(TreePerson) hit;
  final bool Function(TreeDepartment) deptHit;
  final bool searching;

  @override
  void paint(Canvas canvas, Size size) {
    const focal = 650.0;
    final center = Offset(size.width / 2, size.height * 0.55);
    final fit = math.min(size.width, size.height) / 560 * zoom;
    for (final p in points) {
      final x = p.x * math.cos(angle) - p.z * math.sin(angle);
      final z = p.x * math.sin(angle) + p.z * math.cos(angle);
      final y = p.y * math.cos(tilt) - z * math.sin(tilt);
      final depth = p.y * math.sin(tilt) + z * math.cos(tilt);
      final scale = focal / (focal + depth) * fit;
      p
        ..depth = depth
        ..scale = scale
        ..screen = center + Offset(x * scale, -y * scale);
    }
    final paintLine = Paint()
      ..color = line
      ..strokeWidth = 1;
    for (final p in points) {
      if (p.parent case final parent?) canvas.drawLine(parent.screen, p.screen, paintLine);
    }
    for (final p in [...points]..sort((a, b) => b.depth.compareTo(a.depth))) {
      final match = switch (p) {
        _Point3(person: final person?) => hit(person),
        _Point3(department: final department?) => searching && deptHit(department),
        _ => false,
      };
      final dim = searching && (p.person != null || p.department != null) && !match;
      final color = match ? highlight : p.color.withValues(alpha: dim ? 0.25 : 0.95);
      canvas.drawCircle(p.screen, p.radius * p.scale * (match ? 1.6 : 1), Paint()..color = color);
      if (p.label case final label? when !dim) {
        final builder = ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: 10 * p.scale.clamp(0.7, 1.4), maxLines: 1, ellipsis: '…'))
          ..pushStyle(ui.TextStyle(color: text))
          ..addText(label);
        final paragraph = builder.build()..layout(const ui.ParagraphConstraints(width: 120));
        canvas.drawParagraph(paragraph, p.screen + Offset(-paragraph.maxIntrinsicWidth / 2, p.radius * p.scale + 2));
      }
    }
  }

  @override
  bool shouldRepaint(_Tree3dPainter old) => true;
}
