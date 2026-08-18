import 'package:flutter/material.dart';
import '../data/club.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// A door in the lobby. Lit when open, dark and locked when not.
///
/// The glow is painted, not an image: a wash from the top-left plus a hotter
/// spot at the top-right. That second layer is what stops the card looking
/// like a flat coloured rectangle.
class RoomCard extends StatelessWidget {
  final Room room;
  final S s;
  final VoidCallback? onEnter;

  const RoomCard({
    super.key,
    required this.room,
    required this.s,
    this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final open = room.built && room.isOpenAt(now);
    final (time, tomorrow) = room.nextOpening(now);

    return GestureDetector(
      onTap: open ? onEnter : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: T.s3),
        decoration: T.lit(room.colour, open: open),
        child: Stack(
          children: [
            if (open)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(T.rCard),
                    gradient: RadialGradient(
                      center: const Alignment(0.8, -1.0),
                      radius: 1.1,
                      colors: [
                        room.colour.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(T.s4, 15, T.s4, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(room.icon,
                          size: 17,
                          color: open ? room.colour : T.faint),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          open
                              ? s('${room.id}Status').toUpperCase()
                              : (room.built
                                      ? s('curtainDown')
                                      : s('comingSoon'))
                                  .toUpperCase(),
                          style: AppType.tag(
                              open ? room.colour : T.faint),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(s(room.nameKey),
                      style: AppType.roomName(
                          open ? T.white : const Color(0xFF7C748F))),
                  const SizedBox(height: 5),
                  Text(s(room.blurbKey),
                      style: const TextStyle(
                          fontSize: 12.5, height: 1.4, color: T.dim)),
                  const SizedBox(height: T.s3),
                  open ? _enter() : _locked(time, tomorrow),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _enter() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: room.colour,
          borderRadius: BorderRadius.circular(T.rPill),
          boxShadow: [
            BoxShadow(
              color: room.colour.withValues(alpha: 0.34),
              blurRadius: 20,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Text(s('enter'),
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: room.colour.computeLuminance() > 0.5
                    ? T.night
                    : Colors.white)),
      );

  Widget _locked(String time, bool tomorrow) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF3A3450), width: 1),
          borderRadius: BorderRadius.circular(T.rPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(room.built ? Icons.lock_outline : Icons.schedule,
                size: 13, color: const Color(0xFF9089A6)),
            const SizedBox(width: 6),
            Text(
              room.built
                  ? '${tomorrow ? s('tomorrow') : s('opensAt')} $time'
                  : s('comingSoon'),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9089A6)),
            ),
          ],
        ),
      );
}
