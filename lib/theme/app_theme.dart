import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

class AppType {
  AppType._();

  /// The club wordmark: wide tracking is what makes it read as a marquee
  /// rather than a page title.
  static TextStyle wordmark() => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 3,
        color: T.white,
      );

  static TextStyle display(Color color, {double size = 26}) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: size,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle roomName(Color color) => GoogleFonts.bricolageGrotesque(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle punchline({Color color = T.white, double size = 19}) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: size,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle tag(Color color) => GoogleFonts.inter(
        fontSize: 10,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle number({required Color color, double size = 16}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final text = GoogleFonts.interTextTheme(base.textTheme)
      .apply(bodyColor: T.white, displayColor: T.white);

  return base.copyWith(
    scaffoldBackgroundColor: T.night,
    colorScheme: base.colorScheme.copyWith(
      surface: T.night,
      primary: T.gold,
      onPrimary: T.night,
      outline: T.line,
    ),
    textTheme: text.copyWith(
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 15.5, height: 1.55),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
      bodySmall: text.bodySmall?.copyWith(fontSize: 12, color: T.dim),
    ),
    dividerColor: T.line,
    appBarTheme: const AppBarTheme(
      backgroundColor: T.night,
      surfaceTintColor: Colors.transparent,
      foregroundColor: T.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: T.panel,
      contentTextStyle: TextStyle(color: T.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
