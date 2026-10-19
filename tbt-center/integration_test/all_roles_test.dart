/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tbtcenter/core/widgets/async_states.dart';

import 'e2e_helpers.dart';

// E2E: mọi role ở 6 nước mở hết chức năng trên màn chính
const _only = String.fromEnvironment('TBT_TEST_USERS');
const _slow = Duration(seconds: 3);

final _users = [
  'anonymous1606',
  'auditor.ext',
  'ungvien.cv',
  for (final r in ['vn', 'de', 'us', 'br', 'za', 'au']) ...['hr.$r', 'finance.$r', 'employee.$r'],
];

final _report = <String>[];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() {
    if (e2ePassword.isEmpty) throw StateError('Thiếu --dart-define=TBT_TEST_PASSWORD');
  });

  tearDownAll(() {
    debugPrint('===== BÁO CÁO E2E =====\n${_report.join('\n')}\n=======================');
  });

  final users = _only.isEmpty ? _users : _only.split(',');
  for (final username in users) {
    testWidgets('$username: mở mọi chức năng trên màn chính', (tester) async {
      await pumpAs(tester, username);
      expect(find.textContaining('Xin chào'), findsOneWidget, reason: '$username không vào được màn chính');

      final cards = homeCards(tester);
      _report.add('[$username] ${cards.length} chức năng: ${cards.join(', ')}');
      final problems = <String>[];
      for (final title in cards) {
        final watch = Stopwatch()..start();
        await openHomeCard(tester, title);
        final took = watch.elapsed;
        final errors = find.byType(ErrorView).evaluate().length;
        final note = '${took.inMilliseconds} ms${took > _slow ? ' (CHẬM)' : ''}${errors > 0 ? ' LỖI' : ''}';
        _report.add('   $title: $note');
        if (errors > 0) problems.add('$title lỗi');

        // Vuốt từ mép trái để quay lại như người dùng
        await tester.flingFrom(const Offset(4, 420), const Offset(300, 0), 1500);
        await waitLoaded(tester);
        if (find.textContaining('Xin chào').evaluate().isEmpty) {
          problems.add('$title: vuốt không quay lại được');
          await tester.pageBack();
          await waitLoaded(tester);
        }
      }
      expect(problems, isEmpty, reason: problems.join('; '));
    });
  }
}
