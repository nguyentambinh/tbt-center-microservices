/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'e2e_helpers.dart';

// Giữ từng màn vài giây để chụp màn hình bằng adb
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('trưng bày giao diện', (tester) async {
    for (final user in ['hr.vn', 'finance.de', 'anonymous1606']) {
      await pumpAs(tester, user);
      await tester.pump(const Duration(seconds: 6));
    }
    await openHomeCard(tester, 'Chấm công & nghỉ phép');
    await tester.pump(const Duration(seconds: 6));
  });
}
