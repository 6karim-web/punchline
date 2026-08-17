import 'package:flutter/material.dart';

/// The single source of truth for every visual value. Nothing outside this
/// file declares a raw colour.
///
/// The palette is warm paper rather than white, and the joy comes from the
/// accents rather than from decoration: no gradients, no shadows, no glow.
/// Elegance is what keeps cheerful from becoming childish — the colours are
/// loud, everything around them is quiet.
class T {
  T._();

  static const canvas = Color(0xFFFDF9F3); // warm paper, never pure white
  static const surface = Color(0xFFFFFFFF);
  static const raised = Color(0xFFFFFDFA);
  static const border = Color(0xFFEDE4D8);
  static const borderSoft = Color(0xFFF5EFE6);

  static const ink = Color(0xFF1C1917); // near-black, never pure black
  static const muted = Color(0xFF7A716B);
  static const faint = Color(0xFFA8A09A);

  // Six accents. Each category owns one, so the library reads as a colour
  // wheel rather than a list — that variety IS the cheerfulness.
  static const coral = Color(0xFFFF6B4A);
  static const sun = Color(0xFFFFB800);
  static const mint = Color(0xFF10C99B);
  static const violet = Color(0xFF7B61FF);
  static const sky = Color(0xFF3D9BFF);
  static const rose = Color(0xFFFF5C8A);

  static const accents = <Color>[coral, sun, mint, violet, sky, rose];

  /// Stable colour per category: the same joke always wears the same colour,
  /// which is what makes the library feel organised rather than random.
  static Color forCategory(String category) =>
      accents[category.hashCode.abs() % accents.length];

  /// The pale wash behind a card. Low enough that ink stays readable.
  static Color tint(Color c) => Color.alphaBlend(c.withValues(alpha: 0.09), canvas);

  // Spacing — six values, nothing else.
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 24.0;
  static const s6 = 32.0;

  static const rControl = 10.0;
  static const rCard = 16.0;
  static const rSheet = 24.0;
  static const rPill = 99.0;

  static const foldDuration = Duration(milliseconds: 260);
  static const foldCurve = Cubic(0.2, 0.8, 0.3, 1.1);
}
