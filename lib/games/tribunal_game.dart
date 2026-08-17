import 'package:flutter/material.dart';
import '../data/joke_repository.dart';
import '../data/profile_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// The Tribunal. A joke stands accused of being funny; you return a verdict.
///
/// Judging produces a far better signal than liking: everyone presses a thumb
/// up, but a verdict makes you choose. Until there is a server the percentage
/// shown is honestly labelled as YOUR record, not a national one.
class TribunalGame extends StatefulWidget {
  const TribunalGame({super.key});

  @override
  State<TribunalGame> createState() => _TribunalGameState();
}

class _TribunalGameState extends State<TribunalGame> {
  Joke? _joke;
  bool _revealed = false;
  bool? _verdict;
  int _round = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    setState(() {
      _joke = JokeRepository.instance.next();
      _revealed = false;
      _verdict = null;
      _round++;
    });
  }

  Future<void> _judge(bool funny) async {
    if (_joke == null) return;
    await Profile.instance.recordVerdict(_joke!.id, funny);
    setState(() => _verdict = funny);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) _next();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final joke = _joke;
    final accent = joke == null ? T.violet : T.forCategory(joke.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(s('tribunal')),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: T.s4),
            child: Center(
              child: Text('${s('case')} $_round',
                  style: AppType.number(color: T.muted, size: 14)),
            ),
          ),
        ],
      ),
      body: joke == null
          ? Center(child: Text(s('nothingHere')))
          : Padding(
              padding: const EdgeInsets.all(T.s4),
              child: Column(
                children: [
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
                            Text(s('theAccused'),
                                style: AppType.eyebrow(accent)),
                            const SizedBox(height: T.s4),
                            Text(joke.setup,
                                style: Theme.of(context).textTheme.bodyLarge),
                            AnimatedSize(
                              duration: T.foldDuration,
                              curve: T.foldCurve,
                              alignment: Alignment.topCenter,
                              child: _revealed
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: T.s4),
                                      child: Text(joke.punchline,
                                          style: AppType.punchline(size: 20)),
                                    )
                                  : const SizedBox(width: double.infinity),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: T.s4),
                  if (!_revealed)
                    _wide(s('hearTheEvidence'), accent,
                        () => setState(() => _revealed = true))
                  else if (_verdict == null)
                    Row(
                      children: [
                        Expanded(
                          child: _wide(s('notGuilty'), T.muted,
                              () => _judge(false),
                              outlined: true),
                        ),
                        const SizedBox(width: T.s3),
                        Expanded(
                          child: _wide(s('guilty'), T.mint, () => _judge(true)),
                        ),
                      ],
                    )
                  else
                    _verdictBanner(s),
                  const SizedBox(height: T.s2),
                  Text(
                    '${s('yourRecord')}: ${Profile.instance.approvalRate}% '
                    '${s('foundFunny')}',
                    style: const TextStyle(fontSize: 12, color: T.faint),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _verdictBanner(S s) => Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: (_verdict! ? T.mint : T.muted).withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(T.rControl),
        ),
        child: Text(
          _verdict! ? s('convicted') : s('acquitted'),
          style: AppType.punchline(
              color: _verdict! ? T.mint : T.muted, size: 17),
        ),
      );

  Widget _wide(String label, Color color, VoidCallback onTap,
          {bool outlined = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color,
            border: outlined
                ? Border.all(color: T.border, width: 1)
                : null,
            borderRadius: BorderRadius.circular(T.rControl),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: outlined ? T.muted : Colors.white)),
        ),
      );
}
