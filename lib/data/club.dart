import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// A room in the club, and when its doors are open.
///
/// Closing rooms sounds like a mistake — you are hiding content people could
/// be enjoying. It is the opposite. An app where everything is available all
/// the time gives no reason to open it NOW rather than tomorrow. A place with
/// opening hours does. Closed doors are visible on purpose.
class Room {
  final String id;
  final String nameKey;
  final String blurbKey;
  final Color colour;
  final IconData icon;
  final int opensAt; // hour, 24h
  final int closesAt;
  final Set<int> weekdays; // 1 = Monday ... 7 = Sunday
  final bool built;

  const Room({
    required this.id,
    required this.nameKey,
    required this.blurbKey,
    required this.colour,
    required this.icon,
    required this.opensAt,
    required this.closesAt,
    required this.weekdays,
    this.built = false,
  });

  bool isOpenAt(DateTime now) {
    if (!weekdays.contains(now.weekday)) return false;
    // A room can run past midnight; handle the wrap rather than pretending
    // the day ends neatly at 23:59.
    if (closesAt <= opensAt) {
      return now.hour >= opensAt || now.hour < closesAt;
    }
    return now.hour >= opensAt && now.hour < closesAt;
  }

  /// When it next lets people in, as a "HH:00" string plus whether that is
  /// today or tomorrow.
  (String time, bool tomorrow) nextOpening(DateTime now) {
    final label = '${opensAt.toString().padLeft(2, '0')}:00';
    final laterToday = weekdays.contains(now.weekday) && now.hour < opensAt;
    return (label, !laterToday);
  }
}

class Club {
  Club._();

  static const rooms = <Room>[
    Room(
      id: 'tribunal',
      nameKey: 'roomTribunal',
      blurbKey: 'roomTribunalBlurb',
      colour: T.tribunal,
      icon: Icons.gavel,
      opensAt: 0,
      closesAt: 0, // always in session while we have only three rooms
      weekdays: {1, 2, 3, 4, 5, 6, 7},
      built: true,
    ),
    Room(
      id: 'arena',
      nameKey: 'roomArena',
      blurbKey: 'roomArenaBlurb',
      colour: T.arena,
      icon: Icons.sports_mma,
      opensAt: 0,
      closesAt: 0,
      weekdays: {1, 2, 3, 4, 5, 6, 7},
      built: true,
    ),
    Room(
      id: 'stage',
      nameKey: 'roomStage',
      blurbKey: 'roomStageBlurb',
      colour: T.stage,
      icon: Icons.theater_comedy,
      opensAt: 19,
      closesAt: 2,
      weekdays: {1, 2, 3, 4, 5, 6, 7},
      built: true,
    ),
    Room(
      id: 'wheel',
      nameKey: 'roomWheel',
      blurbKey: 'roomWheelBlurb',
      colour: T.wheel,
      icon: Icons.casino,
      opensAt: 12,
      closesAt: 23,
      weekdays: {1, 2, 3, 4, 5, 6, 7},
    ),
    Room(
      id: 'decoder',
      nameKey: 'roomDecoder',
      blurbKey: 'roomDecoderBlurb',
      colour: T.decoder,
      icon: Icons.blur_on,
      opensAt: 8,
      closesAt: 22,
      weekdays: {1, 2, 3, 4, 5, 6, 7},
    ),
    Room(
      id: 'museum',
      nameKey: 'roomMuseum',
      blurbKey: 'roomMuseumBlurb',
      colour: T.museum,
      icon: Icons.museum,
      opensAt: 9,
      closesAt: 18,
      weekdays: {2, 3, 4, 5, 6, 7},
    ),
  ];

  static int openCount(DateTime now) =>
      rooms.where((r) => r.built && r.isOpenAt(now)).length;
}
