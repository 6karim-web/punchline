import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

/// Three faces, three jobs:
///   Bricolage Grotesque — punchlines only
///   Inter              — everything else
///   Inter tabular      — any number that changes (prices, percentages)
class AppType {
  AppType._();

  static TextStyle punchline() => GoogleFonts.bricolageGrotesque(
        fontSize: 19,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: T.saffron,
      );

  static TextStyle punchlineHero() => GoogleFonts.bricolageGrotesque(
        fontSize: 28,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: T.saffron,
      );

  static TextStyle eyebrow() => GoogleFonts.inter(
        fontSize: 11,
        letterSpacing: 0.9,
        fontWeight: FontWeight.w500,
        color: T.saffron,
      );

  /// Tabular figures stop ticker columns from jittering on every refresh.
  static TextStyle number({required Color color, double size = 15}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final text = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: T.text,
    displayColor: T.text,
  );

  return base.copyWith(
    scaffoldBackgroundColor: T.canvas,
    colorScheme: base.colorScheme.copyWith(
      surface: T.canvas,
      primary: T.saffron,
      onPrimary: T.canvas,
      outline: T.border,
    ),
    textTheme: text.copyWith(
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
      bodySmall: text.bodySmall?.copyWith(fontSize: 12, color: T.textMuted),
      titleMedium: text.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
    ),
    dividerColor: T.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: T.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}
