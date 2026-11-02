// Nguyễn Tâm Bình - 2324801030003
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/features/organization/domain/organization.dart';
import 'package:tbtcenter/features/organization/presentation/pages/position_tree_page.dart';

import 'helpers.dart';

const _positions = [
  (id: 'P6', name: 'Ban lãnh đạo', level: 6, holders: 1),
  (id: 'P4', name: 'Trưởng phòng', level: 4, holders: 1),
  (id: 'P1', name: 'Nhân viên', level: 1, holders: 2),
  (id: 'P2', name: 'Chuyên viên chính', level: 2, holders: 0),
];

const _people = [
  TreePerson(id: 'E1', name: 'Nguyễn Bình', level: 6, position: 'Ban lãnh đạo'),
  TreePerson(id: 'E2', name: 'Trần An', level: 4, position: 'Trưởng phòng', departmentName: 'Kế toán'),
  TreePerson(id: 'E3', name: 'Lê Chi', level: 1, position: 'Nhân viên'),
  TreePerson(id: 'E4', name: 'Phạm Dũng', level: 1, position: 'Nhân viên'),
  TreePerson(id: 'E5', name: 'Võ Hà', level: 3, position: 'Cố vấn'),
];

List<TreeNode3> _scene({required bool withPeople}) =>
    buildPositionScene(positions: _positions, people: _people, withPeople: withPeople, tierName: (level) => 'Cấp $level');

void main() {
  test('tab chức vụ xếp đủ chức vụ theo tầng, cấp cao ở trên, tầng nối thành trục', () {
    final nodes = _scene(withPeople: false);
    final tiers = nodes.where((n) => n.kind == TreeNodeKind.tier).toList();
    expect(tiers.map((t) => t.level), [6, 4, 3, 2, 1]);
    expect(tiers.first.y, greaterThan(tiers.last.y));
    expect(tiers.first.parent, isNull);
    expect(tiers[1].parent, tiers.first);

    final names = [for (final n in nodes) if (n.kind == TreeNodeKind.position) n.label];
    expect(names, containsAll(['Ban lãnh đạo', 'Chuyên viên chính', 'Cố vấn']));
    expect(nodes.any((n) => n.kind == TreeNodeKind.person), isFalse);
  });

  test('tab người giữ nối từng người vào chức vụ, bỏ chức vụ chưa có ai', () {
    final nodes = _scene(withPeople: true);
    final people = nodes.where((n) => n.kind == TreeNodeKind.person).toList();
    expect(people, hasLength(_people.length));
    expect(people.firstWhere((n) => n.label == 'Trần An').parent?.label, 'Trưởng phòng');
    expect(people.firstWhere((n) => n.label == 'Võ Hà').parent?.label, 'Cố vấn');
    expect(nodes.any((n) => n.label == 'Chuyên viên chính'), isFalse);
  });

  testWidgets('Văn phòng quản lý mở cây, đổi tab, bấm vào người thấy nút đổi chức vụ', (tester) async {
    final overrides = await testOverrides(language: 'vi', store: MemorySessionStore(fakeSession(token: fakeJwt(roles: ['executive']))));
    await tester.pumpWidget(ProviderScope(
      overrides: [...overrides, positionTreeProvider.overrideWith((ref) async => (positions: _positions.toList(), people: _people.toList()))],
      child: const TbtApp(),
    ));
    await tester.pumpAndSettle();

    final card = find.widgetWithText(ListTile, 'Cây chức vụ');
    await tester.scrollUntilVisible(card, 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Chức vụ'), findsOneWidget);
    expect(find.text('Người giữ chức vụ'), findsOneWidget);

    await tester.tap(find.text('Người giữ chức vụ'));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final state = tester.state<PositionSceneViewState>(find.byWidgetPredicate((w) => w is PositionSceneView && w.withPeople));
    final origin = tester.getTopLeft(find.byWidgetPredicate((w) => w is PositionSceneView && w.withPeople));
    final person = state.nodes.firstWhere((n) => n.label == 'Trần An');
    await tester.tapAt(origin + person.screen);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Thăng chức, đổi chức vụ'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
