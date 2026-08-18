import 'package:flutter/material.dart';

/// The club. Everything visual starts here; nothing outside declares a colour.
///
/// The app is a dark building you visit, and each room owns its light. That is
/// why the palette is organised by ROOM rather than by generic accent — when
/// you walk into the Tribunal it should feel violet, and the Arena green,
/// before you have read a single word.
class T {
  T._();

  // The building
  static const night = Color(0xFF08070C);   // the dark outside every room
  static const panel = Color(0xFF100E18);   // inputs, quiet surfaces
  static const line = Color(0xFF241F38);    // hairlines
  static const lineSoft = Color(0xFF17142270);

  static const white = Color(0xFFF4F1FF);   // never pure white on near-black
  static const dim = Color(0xFF8B849F);
  static const faint = Color(0xFF5A5470);

  /// Gold belongs to the club itself, never to a room: the wordmark, the
  /// active tab, opening hours. It is what holds the building together.
  static const gold = Color(0xFFFFC24B);

  // The rooms
  static const tribunal = Color(0xFF8B5CF6);
  static const arena = Color(0xFF10D9A0);
  static const stage = Color(0xFFFF3B5C);
  static const museum = Color(0xFF3B82F6);
  static const wheel = Color(0xFFFF6B4A);
  static const decoder = Color(0xFFFF5C8A);

  static const rooms = <Color>[tribunal, arena, stage, museum, wheel, decoder];

  /// Stable colour per joke category so the library reads as organised
  /// rather than random — the same joke always wears the same colour.
  static Color forCategory(String category) =>
      rooms[category.hashCode.abs() % rooms.length];

  /// The glow that makes a room look lit from within. Two layers: a wash from
  /// the top-left and a hotter spot top-right, which is what gives depth
  /// without a single image file.
  static BoxDecoration lit(Color room, {bool open = true}) => BoxDecoration(
        borderRadius: BorderRadius.circular(rCard),
        border: Border.all(
            color: open ? room.withValues(alpha: 0.34) : line, width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: open
              ? [
                  Color.alphaBlend(room.withValues(alpha: 0.17), night),
                  night,
                ]
              : [const Color(0xFF0E1018), night],
        ),
      );

  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 24.0;
  static const s6 = 32.0;

  static const rControl = 12.0;
  static const rCard = 16.0;
  static const rSheet = 26.0;
  static const rPill = 99.0;

  static const foldDuration = Duration(milliseconds: 260);
  static const foldCurve = Cubic(0.2, 0.8, 0.3, 1.1);
}
