/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'e2e_helpers.dart';

// E2E FCM: app HR nhận thông báo đẩy thật khi có đơn nghỉ mới
Future<void> _createLeave(String username) async {
  final session = await login(username);
  // Ngày ngẫu nhiên năm sau để không trùng đơn cũ
  final day = DateTime(2027, 1, 1).add(Duration(days: Random().nextInt(300)));
  final date = day.toIso8601String().substring(0, 10);
  final http = HttpClient();
  final request = await http.postUrl(Uri.parse('http://localhost:8000/attendance/leave-requests'));
  request.headers
    ..set(HttpHeaders.authorizationHeader, 'Bearer ${session.accessToken}')
    ..set('Idempotency-Key', 'e2e-push-${DateTime.now().microsecondsSinceEpoch}')
    ..contentType = ContentType.json;
  request.add(utf8.encode(jsonEncode({'fromDate': date, 'toDate': date, 'leaveType': 'Nghỉ phép năm', 'reason': 'E2E FCM'})));
  final response = await request.close();
  final text = await utf8.decodeStream(response);
  http.close();
  if (response.statusCode >= 300) throw StateError('Tạo đơn nghỉ lỗi ${response.statusCode}: $text');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() async => Firebase.initializeApp());

  testWidgets('HR nhận thông báo đẩy FCM khi nhân viên xin nghỉ', (tester) async {
    await pumpAs(tester, 'hr.vn');
    // Chờ app xin quyền, lấy token FCM và gửi lên notification
    await tester.pump(const Duration(seconds: 6));

    await _createLeave('employee.vn');
    final watch = Stopwatch()..start();
    final snack = find.descendant(of: find.byType(SnackBar), matching: find.textContaining('xin nghỉ'));
    while (snack.evaluate().isEmpty && watch.elapsed < const Duration(seconds: 90)) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    debugPrint('Thông báo đẩy tới sau ${watch.elapsed.inSeconds} giây');
    expect(snack, findsOneWidget, reason: 'không nhận được thông báo đẩy trong 90 giây');
  });
}
