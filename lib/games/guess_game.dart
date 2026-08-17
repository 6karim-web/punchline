import 'dart:math';
import 'package:flutter/material.dart';
import '../data/joke_repository.dart';
import '../data/profile_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Guess the punchline: the real ending plus two stolen from other jokes.
/// No new content required — the catalogue plays against itself.
class GuessGame extends StatefulWidget {
  const GuessGame({super.key});

  @override
  State<GuessGame> createState() => _GuessGameState();
}

class _GuessGameState extends State<GuessGame> {
  final _random = Random();
  Joke? _joke;
  List<String> _options = [];
  String? _picked;
  int _score = 0;
  int _round = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    final repo = JokeRepository.instance;
    final joke = repo.next();
    if (joke == null) return;
    final pool = repo.byCategory('all')..shuffle(_random);
    final decoys = pool
        .where((j) => j.id != joke.id)
        .take(2)
        .map((j) => j.punchline)
        .toList();
    setState(() {
      _joke = joke;
      _options = [joke.punchline, ...decoys]..shuffle(_random);
      _picked = null;
      _round++;
    });
  }

  Future<void> _pick(String option) async {
    setState(() => _picked = option);
    if (option == _joke!.punchline) {
      _score++;
      await Profile.instance.award(3);
    }
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) _next();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final joke = _joke;
    final accent = joke == null ? T.sky : T.forCategory(joke.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(s('guessGame')),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: T.s4),
            child: Center(
              child: Text('$_score / $_round',
                  style: AppType.number(color: T.muted, size: 14)),
            ),
          ),
        ],
      ),
      body: joke == null
          ? Center(child: Text(s('nothingHere')))
          : ListView(
              padding: const EdgeInsets.all(T.s4),
              children: [
                Container(
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
                      Text(s('whichEnding'), style: AppType.eyebrow(accent)),
                      const SizedBox(height: T.s3),
                      Text(joke.setup,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
                const SizedBox(height: T.s4),
                for (final o in _options) _option(o, accent),
              ],
            ),
    );
  }

  Widget _option(String option, Color accent) {
    final isRight = option == _joke!.punchline;
    final answered = _picked != null;
    // Once answered we always reveal the true ending, not only the pick —
    // being shown the right answer is the whole point of the round.
    final color = !answered
        ? T.border
        : isRight
            ? T.mint
            : (option == _picked ? T.coral : T.border);

    return Padding(
      padding: const EdgeInsets.only(bottom: T.s3),
      child: GestureDetector(
        onTap: answered ? null : () => _pick(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: answered && (isRight || option == _picked)
                ? color.withValues(alpha: 0.12)
                : T.surface,
            border: Border.all(color: color, width: answered ? 1.5 : 1),
            borderRadius: BorderRadius.circular(T.rCard),
          ),
          padding: const EdgeInsets.all(T.s4),
          child: Text(option,
              style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: answered && !isRight && option != _picked
                      ? T.faint
                      : T.ink)),
        ),
      ),
    );
  }
}
