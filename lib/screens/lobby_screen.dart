import 'package:flutter/material.dart';
import '../data/club.dart';
import '../data/profile_repository.dart';
import '../games/arena_game.dart';
import '../games/decoder_game.dart';
import '../games/museum_game.dart';
import '../games/wheel_game.dart';
import '../games/stage_game.dart';
import '../games/tribunal_game.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/room_card.dart';

/// The lobby. Not a menu of games — a building you walk into.
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  Widget? _roomScreen(String id) => switch (id) {
        'tribunal' => const TribunalGame(),
        'arena' => const ArenaGame(),
        'stage' => const StageGame(),
        'wheel' => const WheelGame(),
        'decoder' => const DecoderGame(),
        'museum' => const MuseumGame(),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final now = DateTime.now();
    final open = Club.openCount(now);

    return ListView(
      padding: const EdgeInsets.fromLTRB(T.s4, T.s4, T.s4, T.s6),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Text('PUNCHLINE', style: AppType.wordmark())),
            Text('CLUB',
                style: AppType.tag(T.gold).copyWith(letterSpacing: 2)),
          ],
        ),
        const SizedBox(height: T.s2),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: open > 0 ? T.arena : T.faint,
                shape: BoxShape.circle,
                boxShadow: open > 0
                    ? [
                        BoxShadow(
                            color: T.arena.withValues(alpha: 0.7),
                            blurRadius: 8)
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              '$open ${open == 1 ? s('roomOpen') : s('roomsOpen')}  ·  '
              '${_hhmm(now)}',
              style: const TextStyle(fontSize: 12, color: T.dim),
            ),
            const Spacer(),
            Text('${Profile.instance.points} pts',
                style: AppType.number(color: T.gold, size: 12.5)),
          ],
        ),
        const SizedBox(height: T.s5),
        for (final room in Club.rooms)
          RoomCard(
            room: room,
            s: s,
            onEnter: () {
              final screen = _roomScreen(room.id);
              if (screen == null) return;
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => screen))
                  .then((_) => setState(() {}));
            },
          ),
        const SizedBox(height: T.s4),
        Center(
          child: Text(s('moreRoomsSoon'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: T.faint)),
        ),
      ],
    );
  }

  static String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}
