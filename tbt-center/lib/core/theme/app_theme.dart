/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'role_gem.dart';

/// Nền đen, bề mặt kính mờ, màu nhấn theo role
abstract final class AppColors {
  static const background = Color(0xFF000000);
  // Nền đặc cho hộp thoại, bảng trượt, menu nổi trên nội dung
  static const card = Color(0xFF16151A);
  // Glassmorphism: trắng trong suốt trên nền đen
  static const glass = Color(0x17FFFFFF);
  static const glassStrong = Color(0x24FFFFFF);
  static const glassBorder = Color(0x2EFFFFFF);
  static const overlay = Color(0xF2141418);
  static const brandGold = Color(0xFFD4AF37);
  static const textMain = Color(0xFFF5F1E6);
  static const textSecondary = Color(0xFFA8A29E);
}

ThemeData buildTheme(RoleGem gem) {
  final scheme = ColorScheme.dark(
    surface: AppColors.background,
    surfaceContainer: AppColors.card,
    surfaceContainerHigh: AppColors.card,
    primary: gem.color,
    onPrimary: AppColors.background,
    secondary: gem.color,
    onSecondary: AppColors.background,
    onSurface: AppColors.textMain,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.glassBorder,
  );

  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final t = base.textTheme;
  // Tiêu đề in đậm
  const bold = FontWeight.w800;
  const semi = FontWeight.w700;
  final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(32));
  const buttonText = TextStyle(fontWeight: semi, fontSize: 15);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: t.copyWith(
      displayLarge: t.displayLarge?.copyWith(fontWeight: bold, color: gem.color),
      displayMedium: t.displayMedium?.copyWith(fontWeight: bold, color: gem.color),
      displaySmall: t.displaySmall?.copyWith(fontWeight: bold, color: gem.color),
      headlineLarge: t.headlineLarge?.copyWith(fontWeight: bold, color: gem.color),
      headlineMedium: t.headlineMedium?.copyWith(fontWeight: bold, color: gem.color),
      headlineSmall: t.headlineSmall?.copyWith(fontWeight: bold, color: AppColors.textMain),
      titleLarge: t.titleLarge?.copyWith(fontWeight: semi, color: AppColors.textMain),
      titleMedium: t.titleMedium?.copyWith(fontWeight: semi, color: AppColors.textMain),
      titleSmall: t.titleSmall?.copyWith(fontWeight: semi, color: AppColors.textMain),
      labelLarge: t.labelLarge?.copyWith(fontWeight: semi),
    ),
    // Trượt từ phải sang, vuốt mép trái để back
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
    ),
    cardTheme: CardThemeData(
      color: AppColors.glass,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: gem.color,
      titleTextStyle: t.titleMedium?.copyWith(fontWeight: semi, color: AppColors.textMain),
      subtitleTextStyle: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.glassBorder, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.glass,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: gem.color, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: gem.color,
        foregroundColor: AppColors.background,
        shape: pill,
        textStyle: buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: gem.color,
        backgroundColor: Colors.white.withValues(alpha: 0.06),
        side: BorderSide(color: gem.color.withValues(alpha: 0.6)),
        shape: pill,
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: gem.color, textStyle: buttonText),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.glass,
      selectedColor: gem.color,
      side: const BorderSide(color: AppColors.glassBorder),
      shape: const StadiumBorder(),
      labelStyle: const TextStyle(fontWeight: semi),
      secondaryLabelStyle: const TextStyle(color: AppColors.background, fontWeight: semi),
      checkmarkColor: AppColors.background,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: gem.color,
      foregroundColor: AppColors.background,
      shape: const StadiumBorder(),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.overlay,
      contentTextStyle: const TextStyle(color: AppColors.textMain),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: gem.color.withValues(alpha: 0.6)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.overlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
      titleTextStyle: t.titleLarge?.copyWith(fontWeight: bold, color: gem.color),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.overlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        side: BorderSide(color: AppColors.glassBorder),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: gem.color),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.textMain,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: t.titleLarge?.copyWith(fontWeight: bold, color: gem.color),
    ),
  );
}
