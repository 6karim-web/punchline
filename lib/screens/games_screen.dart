import 'package:flutter/material.dart';
import '../games/guess_game.dart';
import '../games/timing_game.dart';
import '../games/tribunal_game.dart';
import '../games/write_game.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);

    final games = [
      (s('tribunal'), s('tribunalBlurb'), Icons.gavel, T.violet,
          () => const TribunalGame()),
      (s('writeGame'), s('writeBlurb'), Icons.edit_outlined, T.coral,
          () => const WriteGame()),
      (s('guessGame'), s('guessBlurb'), Icons.help_outline, T.sky,
          () => const GuessGame()),
      (s('timingGame'), s('timingBlurb'), Icons.timer_outlined, T.sun,
          () => const TimingGame()),
    ];

    return ListView(
      padding: const EdgeInsets.all(T.s4),
      children: [
        Text(s('games'), style: AppType.display(T.ink, size: 30)),
        const SizedBox(height: T.s2),
        Text(s('gamesIntro'),
            style: const TextStyle(fontSize: 14, height: 1.5, color: T.muted)),
        const SizedBox(height: T.s5),
        for (final (title, blurb, icon, color, builder) in games)
          Padding(
            padding: const EdgeInsets.only(bottom: T.s3),
            child: GestureDetector(
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => builder())),
              child: Container(
                decoration: BoxDecoration(
                  color: T.tint(color),
                  border:
                      Border.all(color: color.withValues(alpha: 0.28), width: 1),
                  borderRadius: BorderRadius.circular(T.rCard),
                ),
                padding: const EdgeInsets.all(T.s4 + 2),
                child: Row(
                  children: [
                    Icon(icon, size: 26, color: color),
                    const SizedBox(width: T.s4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppType.punchline(size: 17)),
                          const SizedBox(height: 3),
                          Text(blurb,
                              style: const TextStyle(
                                  fontSize: 13, height: 1.4, color: T.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: T.s5),
      ],
    );
  }
}
