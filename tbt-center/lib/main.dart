/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/error/error_reporter.dart';
import 'core/locale/locale_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lỗi bất đồng bộ không ai bắt: ghi log và báo cho người dùng thay vì để app im lặng.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Lỗi chưa xử lý: $error\n$stack');
    reportFailure(error);
    return true;
  };
  // FCM; máy không có Google Play thì app vẫn chạy, chỉ không có thông báo đẩy
  try {
    await Firebase.initializeApp();
  } on Object catch (e) {
    debugPrint('Không khởi tạo được Firebase: $e');
  }
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TbtApp(),
    ),
  );
}
