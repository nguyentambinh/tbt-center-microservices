/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'role_gem.dart';

/// Bảng màu theo chế độ sáng/tối: bề mặt kính mờ, chữ, màu trạng thái
@immutable
class TbtColors extends ThemeExtension<TbtColors> {
  const TbtColors({
    required this.background,
    required this.card,
    required this.glass,
    required this.glassStrong,
    required this.glassBorder,
    required this.glassTop,
    required this.glassBottom,
    required this.overlay,
    required this.brandGold,
    required this.textMain,
    required this.textSecondary,
    required this.navIdle,
    required this.success,
    required this.danger,
    required this.warning,
    required this.caution,
    required this.info,
  });

  final Color background;

  /// Nền đặc cho menu, nội dung vẽ tay nổi trên trang
  final Color card;
  final Color glass;
  final Color glassStrong;
  final Color glassBorder;

  /// Hai đầu dải màu của tấm kính (đăng nhập, thanh điều hướng)
  final Color glassTop;
  final Color glassBottom;

  /// Nền hộp thoại, bảng trượt, thông báo nổi
  final Color overlay;
  final Color brandGold;
  final Color textMain;
  final Color textSecondary;
  final Color navIdle;
  final Color success;
  final Color danger;
  final Color warning;

  /// Vàng (nhắc sớm) và xanh dương (chưa bắt đầu) của cảnh báo dự án
  final Color caution;
  final Color info;

  static const dark = TbtColors(
    background: Color(0xFF000000),
    card: Color(0xFF16151A),
    glass: Color(0x17FFFFFF),
    glassStrong: Color(0x24FFFFFF),
    glassBorder: Color(0x2EFFFFFF),
    glassTop: Color(0x24FFFFFF),
    glassBottom: Color(0x0AFFFFFF),
    overlay: Color(0xF2141418),
    brandGold: Color(0xFFD4AF37),
    textMain: Color(0xFFF5F1E6),
    textSecondary: Color(0xFFA8A29E),
    navIdle: Color(0x99FFFFFF),
    success: Color(0xFF3FCF8E),
    danger: Color(0xFFFF4D79),
    warning: Color(0xFFFFA726),
    caution: Color(0xFFFFD54F),
    info: Color(0xFF64B5F6),
  );

  static const light = TbtColors(
    background: Color(0xFFF3F1EC),
    card: Color(0xFFFFFFFF),
    glass: Color(0xB8FFFFFF),
    glassStrong: Color(0x0F000000),
    glassBorder: Color(0x1F000000),
    glassTop: Color(0xE6FFFFFF),
    glassBottom: Color(0x99FFFFFF),
    overlay: Color(0xF7FFFFFF),
    brandGold: Color(0xFF7A5C0F),
    textMain: Color(0xFF1D1B18),
    textSecondary: Color(0xFF5C574F),
    navIdle: Color(0xFF6B655C),
    success: Color(0xFF1B7A4C),
    danger: Color(0xFFB3264A),
    warning: Color(0xFF8F5400),
    caution: Color(0xFF6E5A00),
    info: Color(0xFF1F5FA8),
  );

  @override
  TbtColors copyWith() => this;

  @override
  TbtColors lerp(TbtColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return TbtColors(
      background: l(background, other.background),
      card: l(card, other.card),
      glass: l(glass, other.glass),
      glassStrong: l(glassStrong, other.glassStrong),
      glassBorder: l(glassBorder, other.glassBorder),
      glassTop: l(glassTop, other.glassTop),
      glassBottom: l(glassBottom, other.glassBottom),
      overlay: l(overlay, other.overlay),
      brandGold: l(brandGold, other.brandGold),
      textMain: l(textMain, other.textMain),
      textSecondary: l(textSecondary, other.textSecondary),
      navIdle: l(navIdle, other.navIdle),
      success: l(success, other.success),
      danger: l(danger, other.danger),
      warning: l(warning, other.warning),
      caution: l(caution, other.caution),
      info: l(info, other.info),
    );
  }
}

extension TbtColorsContext on BuildContext {
  TbtColors get tbt => Theme.of(this).extension<TbtColors>() ?? TbtColors.dark;
}

ThemeData buildTheme(RoleGem gem, {Brightness brightness = Brightness.dark}) {
  final dark = brightness == Brightness.dark;
  final c = dark ? TbtColors.dark : TbtColors.light;
  final accent = gem.accent(brightness);
  final onAccent = dark ? c.background : Colors.white;
  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: brightness,
  ).copyWith(
    surface: c.background,
    surfaceContainer: c.card,
    surfaceContainerHigh: c.card,
    primary: accent,
    onPrimary: onAccent,
    secondary: accent,
    onSecondary: onAccent,
    onSurface: c.textMain,
    onSurfaceVariant: c.textSecondary,
    outline: c.glassBorder,
    error: c.danger,
  );

  final base = ThemeData(colorScheme: scheme, useMaterial3: true, extensions: [c]);
  final t = base.textTheme;
  // Tiêu đề in đậm
  const bold = FontWeight.w800;
  const semi = FontWeight.w700;
  final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(32));
  const buttonText = TextStyle(fontWeight: semi, fontSize: 15);

  return base.copyWith(
    scaffoldBackgroundColor: c.background,
    textTheme: t.copyWith(
      displayLarge: t.displayLarge?.copyWith(fontWeight: bold, color: accent),
      displayMedium: t.displayMedium?.copyWith(fontWeight: bold, color: accent),
      displaySmall: t.displaySmall?.copyWith(fontWeight: bold, color: accent),
      headlineLarge: t.headlineLarge?.copyWith(fontWeight: bold, color: accent),
      headlineMedium: t.headlineMedium?.copyWith(fontWeight: bold, color: accent),
      headlineSmall: t.headlineSmall?.copyWith(fontWeight: bold, color: c.textMain),
      titleLarge: t.titleLarge?.copyWith(fontWeight: semi, color: c.textMain),
      titleMedium: t.titleMedium?.copyWith(fontWeight: semi, color: c.textMain),
      titleSmall: t.titleSmall?.copyWith(fontWeight: semi, color: c.textMain),
      labelLarge: t.labelLarge?.copyWith(fontWeight: semi),
    ),
    // Trượt từ phải sang, vuốt mép trái để back
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
    ),
    cardTheme: CardThemeData(
      color: c.glass,
      elevation: 0,
      // Thẻ trong danh sách luôn tách nhau
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.glassBorder),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: accent,
      titleTextStyle: t.titleMedium?.copyWith(fontWeight: semi, color: c.textMain),
      subtitleTextStyle: t.bodyMedium?.copyWith(color: c.textSecondary),
    ),
    dividerTheme: DividerThemeData(color: c.glassBorder, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.glass,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: c.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: c.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: accent, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: onAccent,
        shape: pill,
        textStyle: buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        backgroundColor: c.glass,
        side: BorderSide(color: accent.withValues(alpha: 0.6)),
        shape: pill,
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accent, textStyle: buttonText),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.glass,
      selectedColor: accent,
      side: BorderSide(color: c.glassBorder),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(fontWeight: semi, color: c.textMain),
      secondaryLabelStyle: TextStyle(color: onAccent, fontWeight: semi),
      checkmarkColor: onAccent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: onAccent,
      shape: const StadiumBorder(),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.overlay,
      contentTextStyle: TextStyle(color: c.textMain),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent.withValues(alpha: 0.6)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.overlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: c.glassBorder),
      ),
      titleTextStyle: t.titleLarge?.copyWith(fontWeight: bold, color: accent),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.overlay,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        side: BorderSide(color: c.glassBorder),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: c.textMain,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: t.titleLarge?.copyWith(fontWeight: bold, color: accent),
      systemOverlayStyle: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),
  );
}
