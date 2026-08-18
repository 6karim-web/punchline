import 'package:flutter/material.dart';
import '../data/joke_repository.dart';
import '../data/profile_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// The Arena. Two jokes fight, you referee, the winner stays on.
///
/// A champion on a ten-fight streak is the hook: you keep playing to find out
/// how far it goes. It is also the cleanest ranking signal we can collect —
/// a forced choice between two options, which is far more informative than
/// any thumbs-up.
class ArenaGame extends StatefulWidget {
  const ArenaGame({super.key});

  @override
  State<ArenaGame> createState() => _ArenaGameState();
}

class _ArenaGameState extends State<ArenaGame> {
  Joke? _champion;
  Joke? _challenger;
  int _streak = 0;
  int _openIndex = -1; // which card is unfolded, -1 for none

  @override
  void initState() {
    super.initState();
    _champion = JokeRepository.instance.next();
    _challenger = JokeRepository.instance.next();
  }

  Future<void> _pick(bool championWins) async {
    await Profile.instance.award(2);
    setState(() {
      if (championWins) {
        _streak++;
      } else {
        _champion = _challenger;
        _streak = 1;
      }
      _challenger = JokeRepository.instance.next();
      _openIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final a = _champion, b = _challenger;

    return Scaffold(
      appBar: AppBar(
        title: Text(s('roomArena')),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: T.s4),
            child: Center(
              child: Text('${s('streakLabel')} $_streak',
                  style: AppType.number(color: T.arena, size: 13)),
            ),
          ),
        ],
      ),
      body: (a == null || b == null)
          ? Center(child: Text(s('nothingHere')))
          : Padding(
              padding: const EdgeInsets.all(T.s4),
              child: Column(
                children: [
                  Text(s('arenaPrompt'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, height: 1.5, color: T.dim)),
                  const SizedBox(height: T.s4),
                  Expanded(
                    child: _fighter(a, 0, T.arena, s, champion: true),
                  ),
                  const SizedBox(height: T.s3),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: T.line)),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: T.s3),
                        child: Text(s('versus'),
                            style: AppType.tag(T.gold)),
                      ),
                      const Expanded(child: Divider(color: T.line)),
                    ],
                  ),
                  const SizedBox(height: T.s3),
                  Expanded(
                    child: _fighter(b, 1, T.stage, s, champion: false),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _fighter(Joke joke, int index, Color colour, S s,
      {required bool champion}) {
    final open = _openIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _openIndex = open ? -1 : index),
      child: Container(
        width: double.infinity,
        decoration: T.lit(colour),
        padding: const EdgeInsets.all(T.s4),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  champion
                      ? '${s('champion')} · ${_streak}'
                      : s('challenger'),
                  style: AppType.tag(colour)),
              const SizedBox(height: T.s2),
              Text(joke.setup,
                  style: Theme.of(context).textTheme.bodyLarge),
              AnimatedSize(
                duration: T.foldDuration,
                curve: T.foldCurve,
                alignment: Alignment.topCenter,
                child: open
                    ? Padding(
                        padding: const EdgeInsets.only(top: T.s3),
                        child: Text(joke.punchline,
                            style: AppType.punchline(size: 17)),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: T.s2),
                        child: Text(s('tapForPunchline'),
                            style: TextStyle(fontSize: 12, color: colour)),
                      ),
              ),
              const SizedBox(height: T.s3),
              GestureDetector(
                onTap: () => _pick(champion),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: colour,
                    borderRadius: BorderRadius.circular(T.rControl),
                  ),
                  child: Text(s('thisOneWins'),
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
