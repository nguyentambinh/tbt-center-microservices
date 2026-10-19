/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-19
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../locale/locale_providers.dart';

const _themeModeKey = 'theme_mode';

/// Chế độ sáng/tối: mặc định theo điện thoại, người dùng chọn thì lưu trên máy
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => switch (ref.watch(sharedPreferencesProvider).getString(_themeModeKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> choose(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (mode == ThemeMode.system) {
      await prefs.remove(_themeModeKey);
    } else {
      await prefs.setString(_themeModeKey, mode.name);
    }
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
