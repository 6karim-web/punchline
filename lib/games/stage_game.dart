import 'package:flutter/material.dart';
import '../data/joke_repository.dart';
import '../data/profile_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// The Stage. You are the act; the room reacts to your timing.
///
/// Most people kill a joke by rushing the punchline, and nobody has ever been
/// told this about themselves. Here the audience answers: too fast and you get
/// silence, too slow and you lose the room, and in the window between you get
/// the laugh. The verdict comes from the crowd, not from a number.
enum Reaction { none, silence, chuckle, laugh, ovation }

class StageGame extends StatefulWidget {
  const StageGame({super.key});

  @override
  State<StageGame> createState() => _StageGameState();
}

class _StageGameState extends State<StageGame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spot = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  Joke? _joke;
  DateTime? _startedAt;
  Reaction _reaction = Reaction.none;
  int _set = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  @override
  void dispose() {
    _spot.dispose();
    super.dispose();
  }

  void _next() => setState(() {
        _joke = JokeRepository.instance.next();
        _startedAt = null;
        _reaction = Reaction.none;
        _set++;
      });

  Future<void> _deliver() async {
    if (_startedAt == null) return;
    final ms = DateTime.now().difference(_startedAt!).inMilliseconds;
    final r = switch (ms) {
      < 700 => Reaction.silence,
      < 1100 => Reaction.chuckle,
      <= 2400 => Reaction.ovation,
      <= 3200 => Reaction.laugh,
      _ => Reaction.silence,
    };
    if (r == Reaction.ovation) {
      await Profile.instance.recordLaugh();
    } else if (r == Reaction.laugh || r == Reaction.chuckle) {
      await Profile.instance.award(3);
    }
    setState(() => _reaction = r);
  }

  (String, Color, IconData) _verdict(S s) => switch (_reaction) {
        Reaction.ovation => (s('ovation'), T.gold, Icons.auto_awesome),
        Reaction.laugh => (s('goodLaugh'), T.arena, Icons.sentiment_very_satisfied),
        Reaction.chuckle => (s('chuckle'), T.museum, Icons.sentiment_satisfied),
        _ => (s('silence'), T.faint, Icons.sentiment_neutral),
      };

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final joke = _joke;

    return Scaffold(
      appBar: AppBar(
        title: Text(s('roomStage')),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: T.s4),
            child: Center(
              child: Text('${s('setLabel')} $_set',
                  style: AppType.number(color: T.dim, size: 13)),
            ),
          ),
        ],
      ),
      body: joke == null
          ? Center(child: Text(s('nothingHere')))
          : Stack(
              children: [
                // The spotlight: a soft cone that breathes. Painted, never an
                // image, so it costs nothing and scales to any screen.
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _spot,
                    builder: (context, _) => DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -1.1),
                          radius: 1.0 + _spot.value * 0.12,
                          colors: [
                            T.gold.withValues(alpha: 0.13),
                            T.stage.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.42, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(T.s4),
                  child: Column(
                    children: [
                      Text(s('stagePrompt'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, height: 1.5, color: T.dim)),
                      const SizedBox(height: T.s5),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(joke.setup,
                                  style: AppType.punchline(
                                      color: T.white, size: 22)),
                              if (_reaction != Reaction.none) ...[
                                const SizedBox(height: T.s4),
                                Text(joke.punchline,
                                    style: AppType.punchline(
                                        color: T.gold, size: 20)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (_reaction != Reaction.none) _audience(s),
                      const SizedBox(height: T.s4),
                      if (_reaction != Reaction.none)
                        _button(s('nextSet'), T.stage, _next)
                      else if (_startedAt == null)
                        _button(s('takeTheMic'), T.stage,
                            () => setState(() => _startedAt = DateTime.now()))
                      else
                        _button(s('dropIt'), T.gold, _deliver, dark: true),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _audience(S s) {
    final (label, colour, icon) = _verdict(s);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: T.s4),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.11),
        border: Border.all(color: colour.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(T.rCard),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: colour),
          const SizedBox(height: T.s2),
          Text(label,
              style: AppType.punchline(color: colour, size: 17)),
        ],
      ),
    );
  }

  Widget _button(String label, Color colour, VoidCallback onTap,
          {bool dark = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: colour,
            borderRadius: BorderRadius.circular(T.rControl),
            boxShadow: [
              BoxShadow(
                  color: colour.withValues(alpha: 0.32),
                  blurRadius: 24,
                  spreadRadius: -4),
            ],
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: dark ? T.night : Colors.white)),
        ),
      );
}
