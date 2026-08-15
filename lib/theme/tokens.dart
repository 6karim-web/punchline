import 'package:flutter/material.dart';

/// The single source of truth for every visual value in the app.
/// Nothing outside this file may declare a raw colour or spacing number.
class T {
  T._();

  // Surfaces — in a dark UI, elevation is encoded by lightness.
  static const canvas = Color(0xFF0E1014);
  static const card = Color(0xFF191C22);
  static const sheet = Color(0xFF232730);
  static const border = Color(0xFF2C313B);
  static const borderSoft = Color(0xFF3A404C);

  // Text — never pure white on near-black; it haloes.
  static const text = Color(0xFFF2EFE9);
  static const textMuted = Color(0xFF8E96A3);
  static const textFaint = Color(0xFF6E7684);

  // Accents — one per section.
  static const saffron = Color(0xFFF5B324); // Punchline
  static const blue = Color(0xFF5B9BE8); // News
  static const violet = Color(0xFF9B8CFF); // Faith

  // Reserved: green and red mean market direction and nothing else, anywhere.
  static const up = Color(0xFF26C281);
  static const down = Color(0xFFE8503A);

  // Tinted pill backgrounds.
  static const blueTint = Color(0xFF16243A);

  // Spacing — six values, no others.
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 24.0;
  static const s6 = 32.0;

  // Radii.
  static const rControl = 8.0;
  static const rCard = 12.0;
  static const rSheet = 20.0;
  static const rPill = 99.0;

  // Motion — one animation in the whole app.
  static const foldDuration = Duration(milliseconds: 260);
  static const foldCurve = Cubic(0.2, 0.8, 0.3, 1.1);
}
