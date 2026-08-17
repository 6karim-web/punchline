import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

class AppType {
  AppType._();

  static TextStyle display(Color color, {double size = 28}) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: size,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle punchline({Color color = T.ink, double size = 20}) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: size,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle eyebrow(Color color) => GoogleFonts.inter(
        fontSize: 11,
        letterSpacing: 1.0,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle number({required Color color, double size = 16}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

ThemeData buildTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final text = GoogleFonts.interTextTheme(base.textTheme)
      .apply(bodyColor: T.ink, displayColor: T.ink);

  return base.copyWith(
    scaffoldBackgroundColor: T.canvas,
    colorScheme: base.colorScheme.copyWith(
      surface: T.canvas,
      primary: T.coral,
      onPrimary: Colors.white,
      outline: T.border,
    ),
    textTheme: text.copyWith(
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 16, height: 1.55),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
      bodySmall: text.bodySmall?.copyWith(fontSize: 12.5, color: T.muted),
      titleMedium: text.titleMedium?.copyWith(
          fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2),
    ),
    dividerColor: T.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: T.canvas,
      surfaceTintColor: Colors.transparent,
      foregroundColor: T.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: T.ink,
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
