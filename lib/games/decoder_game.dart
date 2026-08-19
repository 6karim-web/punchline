import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/joke_repository.dart';
import '../data/profile_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// The Decoder. The punchline arrives scrambled and resolves character by
/// character. Guess before it finishes and you score more.
///
/// The tension is visible rather than announced: you can literally watch your
/// score draining as the letters settle, which is what makes people commit
/// early instead of waiting for the answer.
class DecoderGame extends StatefulWidget {
  const DecoderGame({super.key});

  @override
  State<DecoderGame> createState() => _DecoderGameState();
}

class _DecoderGameState extends State<DecoderGame> {
  static const _glyphs = '@#\$%&?*+=<>/\\~^01';

  final _random = Random();
  Joke? _joke;
  Timer? _ticker;
  int _revealed = 0;
  bool _guessed = false;
  int _score = 0;
  int _round = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _next() {
    _ticker?.cancel();
    setState(() {
      _joke = JokeRepository.instance.next();
      _revealed = 0;
      _guessed = false;
      _round++;
    });
    final total = _joke?.punchline.length ?? 0;
    if (total == 0) return;
    // Resolve the whole line in roughly twelve seconds whatever its length,
    // so a long punchline is not automatically an easier round.
    final step = Duration(milliseconds: max(24, 12000 ~/ total));
    _ticker = Timer.periodic(step, (t) {
      if (!mounted) return t.cancel();
      if (_revealed >= total) {
        t.cancel();
        return;
      }
      setState(() => _revealed++);
    });
  }

  Future<void> _gotIt() async {
    _ticker?.cancel();
    final total = _joke!.punchline.length;
    final earned = ((1 - _revealed / total) * 20).round().clamp(1, 20);
    await Profile.instance.award(earned);
    setState(() {
      _guessed = true;
      _score += earned;
      _revealed = total;
    });
  }

  String _scramble(String text) {
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final c = text[i];
      if (i < _revealed || c == ' ' || c == '\n') {
        buffer.write(c);
      } else {
        buffer.write(_glyphs[(i * 31 + _revealed) % _glyphs.length]);
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final joke = _joke;
    if (joke == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s('roomDecoder'))),
        body: Center(child: Text(s('nothingHere'))),
      );
    }
    final total = joke.punchline.length;
    final worth = ((1 - _revealed / total) * 20).round().clamp(0, 20);

    return Scaffold(
      appBar: AppBar(
        title: Text(s('roomDecoder')),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: T.s4),
            child: Center(
              child: Text('$_score',
                  style: AppType.number(color: T.decoder, size: 14)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(T.s4),
        child: Column(
          children: [
            Text(s('decoderPrompt'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, height: 1.5, color: T.dim)),
            const SizedBox(height: T.s4),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  decoration: T.lit(T.decoder),
                  padding: const EdgeInsets.all(T.s5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${s('caseFile')} $_round',
                          style: AppType.tag(T.decoder)),
                      const SizedBox(height: T.s3),
                      Text(joke.setup,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: T.s4),
                      const Divider(color: T.line, height: 1),
                      const SizedBox(height: T.s4),
                      Text(
                        _scramble(joke.punchline),
                        style: AppType.punchline(
                            color: _guessed ? T.decoder : T.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: T.s4),
            if (_guessed)
              _btn(s('nextOne'), T.decoder, _next)
            else ...[
              // The bar drains as the line resolves: the cost of waiting is
              // shown, not explained.
              ClipRRect(
                borderRadius: BorderRadius.circular(T.rPill),
                child: LinearProgressIndicator(
                  value: 1 - _revealed / total,
                  minHeight: 4,
                  backgroundColor: T.line,
                  valueColor: const AlwaysStoppedAnimation(T.decoder),
                ),
              ),
              const SizedBox(height: T.s2),
              Text('$worth ${s('pointsLeft')}',
                  style: const TextStyle(fontSize: 12, color: T.dim)),
              const SizedBox(height: T.s3),
              _btn(s('iGotIt'), T.decoder, _gotIt),
            ],
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, Color c, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(T.rControl),
            boxShadow: [
              BoxShadow(
                  color: c.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: -4),
            ],
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      );
}
