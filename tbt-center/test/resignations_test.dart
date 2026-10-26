/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbtcenter/app.dart';
import 'package:tbtcenter/features/resignations/data/resignation_repository.dart';
import 'package:tbtcenter/features/resignations/domain/resignation.dart';
import 'package:tbtcenter/features/resignations/presentation/resignations_page.dart';

import 'helpers.dart';

class FakeResignationRepository extends ResignationRepository {
  FakeResignationRepository(this.items) : super(Dio(), baseUrl: '');

  List<Resignation> items;
  final actions = <String>[];
  DateTime? sentDay;

  @override
  Future<List<Resignation>> list({String? status}) async => items;

  @override
  Future<Resignation> submit({required DateTime lastDay, required String reason}) async {
    sentDay = lastDay;
    final r = _resignation('pending', lastDay: lastDay, reason: reason);
    items = [r];
    return r;
  }

  @override
  Future<Resignation> respond(int id, {required String action, String? note}) async {
    actions.add(action);
    return items.first;
  }
}

Resignation _resignation(String status, {DateTime? lastDay, String reason = 'Chuyển về quê'}) => Resignation(
      id: 1,
      employeeId: 'NV001',
      name: 'Trần An',
      lastDay: lastDay ?? DateTime(2026, 12, 1),
      reason: reason,
      status: status,
      createdAt: DateTime(2026, 10, 25),
    );

Future<void> _pump(WidgetTester tester, FakeResignationRepository repository, {required List<String> roles, String? employeeId}) async {
  final overrides = await testOverrides(language: 'vi', store: MemorySessionStore(fakeSession(token: fakeJwt(roles: roles, employeeId: employeeId))));
  await tester.pumpWidget(ProviderScope(
    overrides: [...overrides, resignationRepositoryProvider.overrideWith((ref, region) => repository)],
    child: const TbtApp(),
  ));
  await tester.pumpAndSettle();
  await openHomeCard(tester, 'Xin thôi việc');
}

void main() {
  testWidgets('nhân viên gửi đơn, ngày làm cuối mặc định cách 30 ngày', (tester) async {
    final repository = FakeResignationRepository([]);
    await _pump(tester, repository, roles: ['employee'], employeeId: 'NV001');
    expect(find.text('Chưa có đơn thôi việc nào'), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    final send = find.widgetWithText(FilledButton, 'Gửi');
    expect(tester.widget<FilledButton>(send).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'Chuyển về quê');
    await tester.pump();
    await tester.tap(send);
    await tester.pumpAndSettle();
    final now = DateTime.now();
    expect(repository.sentDay, DateTime(now.year, now.month, now.day + resignationNoticeDays));
    expect(find.text('Chờ HR duyệt'), findsOneWidget);
    // Đang có đơn mở thì không gửi thêm
    expect(find.byType(FloatingActionButton), findsNothing);
    await tester.tap(find.text('Rút đơn'));
    await tester.pumpAndSettle();
    expect(repository.actions, ['withdraw']);
  });

  testWidgets('HR duyệt đơn chờ', (tester) async {
    final repository = FakeResignationRepository([_resignation('pending')]);
    await _pump(tester, repository, roles: ['hr']);
    expect(find.text('Trần An (NV001)'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Duyệt'));
    await tester.pumpAndSettle();
    expect(repository.actions, ['approve']);
  });

  testWidgets('HR chỉ hoàn tất được khi đã tới ngày làm cuối', (tester) async {
    final repository = FakeResignationRepository([_resignation('approved', lastDay: DateTime(2026, 1, 1))]);
    await _pump(tester, repository, roles: ['hr']);
    await tester.tap(find.widgetWithText(FilledButton, 'Hoàn tất nghỉ việc'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hồ sơ Trần An sẽ được bảo lưu'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Hoàn tất nghỉ việc').last);
    await tester.pumpAndSettle();
    expect(repository.actions, ['complete']);
  });

  testWidgets('chưa tới ngày làm cuối thì không có nút hoàn tất', (tester) async {
    final repository = FakeResignationRepository([_resignation('approved', lastDay: DateTime.now().add(const Duration(days: 20)))]);
    await _pump(tester, repository, roles: ['hr']);
    expect(find.text('Đã duyệt, chờ ngày nghỉ'), findsOneWidget);
    expect(find.text('Hoàn tất nghỉ việc'), findsNothing);
  });
}
