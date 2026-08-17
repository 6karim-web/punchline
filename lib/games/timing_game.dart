import 'package:flutter/material.dart';
import '../data/joke_repository.dart';
import '../data/profile_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// The timing trainer.
///
/// Most people kill a joke by rushing the punchline. Nobody has ever been told
/// this about themselves. Here you read the setup, then tap when you would
/// deliver the ending — and the app tells you whether you left the pause that
/// makes it land. It teaches the one thing that separates a good teller from
/// a bad one, and needs no microphone to do it.
class TimingGame extends StatefulWidget {
  const TimingGame({super.key});

  @override
  State<TimingGame> createState() => _TimingGameState();
}

class _TimingGameState extends State<TimingGame> {
  Joke? _joke;
  DateTime? _startedAt;
  Duration? _pause;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() => setState(() {
        _joke = JokeRepository.instance.next();
        _startedAt = null;
        _pause = null;
      });

  void _start() => setState(() => _startedAt = DateTime.now());

  Future<void> _deliver() async {
    if (_startedAt == null) return;
    final pause = DateTime.now().difference(_startedAt!);
    setState(() => _pause = pause);
    if (pause.inMilliseconds >= 900 && pause.inMilliseconds <= 2600) {
      await Profile.instance.award(4);
    }
  }

  String _feedback(S s) {
    final ms = _pause!.inMilliseconds;
    if (ms < 900) return s('tooFast');
    if (ms > 2600) return s('tooSlow');
    return s('perfectBeat');
  }

  Color _feedbackColor() {
    final ms = _pause!.inMilliseconds;
    if (ms < 900 || ms > 2600) return T.coral;
    return T.mint;
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final joke = _joke;
    final accent = joke == null ? T.sun : T.forCategory(joke.category);

    return Scaffold(
      appBar: AppBar(title: Text(s('timingGame'))),
      body: joke == null
          ? Center(child: Text(s('nothingHere')))
          : Padding(
              padding: const EdgeInsets.all(T.s4),
              child: Column(
                children: [
                  Text(s('timingHint'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, height: 1.5, color: T.muted)),
                  const SizedBox(height: T.s4),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: T.tint(accent),
                          border: Border.all(
                              color: accent.withValues(alpha: 0.28), width: 1),
                          borderRadius: BorderRadius.circular(T.rCard),
                        ),
                        padding: const EdgeInsets.all(T.s5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s('readAloud'), style: AppType.eyebrow(accent)),
                            const SizedBox(height: T.s3),
                            Text(joke.setup,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontSize: 18)),
                            if (_pause != null) ...[
                              const SizedBox(height: T.s4),
                              Text(joke.punchline,
                                  style: AppType.punchline(size: 19)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: T.s4),
                  if (_pause != null) ...[
                    Text(
                      '${(_pause!.inMilliseconds / 1000).toStringAsFixed(1)}s',
                      style:
                          AppType.number(color: _feedbackColor(), size: 30),
                    ),
                    const SizedBox(height: T.s1),
                    Text(_feedback(s),
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _feedbackColor())),
                    const SizedBox(height: T.s4),
                    _wide(s('nextOne'), accent, _next),
                  ] else if (_startedAt == null)
                    _wide(s('startReading'), accent, _start)
                  else
                    _wide(s('nowTheEnding'), T.ink, _deliver),
                  const SizedBox(height: T.s2),
                ],
              ),
            ),
    );
  }

  Widget _wide(String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(T.rControl),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
      );
}
