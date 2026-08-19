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

/// The Wheel. Spin for a category, then thirty seconds to judge as many as
/// you can. The randomness is the point: a visible spin creates a promise,
/// and a promise is what makes someone tap again.
class WheelGame extends StatefulWidget {
  const WheelGame({super.key});

  @override
  State<WheelGame> createState() => _WheelGameState();
}

class _WheelGameState extends State<WheelGame>
    with SingleTickerProviderStateMixin {
  static const _slices = <String>[
    'work', 'marriage', 'money', 'medical', 'bar', 'animals', 'tech', 'misc',
  ];

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final Animation<double> _turns =
      CurvedAnimation(parent: _spin, curve: Curves.easeOutQuart);

  final _random = Random();
  double _target = 0;
  String? _category;
  Joke? _joke;
  int _left = 0;
  int _score = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _spin.dispose();
    super.dispose();
  }

  Future<void> _launch() async {
    final index = _random.nextInt(_slices.length);
    // Four full turns plus the slice offset: the extra rotations are what
    // make it read as a spin rather than a jump.
    setState(() => _target = 4 + index / _slices.length);
    _spin
      ..reset()
      ..forward();
    await Future.delayed(_spin.duration!);
    if (!mounted) return;
    setState(() {
      _category = _slices[index];
      _score = 0;
      _left = 30;
      _joke = JokeRepository.instance.next(category: _category!);
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _left--);
      if (_left <= 0) {
        t.cancel();
        setState(() => _joke = null);
      }
    });
  }

  Future<void> _judge(bool funny) async {
    if (_joke == null) return;
    await Profile.instance.recordVerdict(_joke!.id, funny);
    setState(() {
      _score++;
      _joke = JokeRepository.instance.next(category: _category!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final running = _left > 0 && _joke != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(s('roomWheel')),
        actions: [
          if (running)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: T.s4),
              child: Center(
                child: Text('$_left s   ·   $_score',
                    style: AppType.number(color: T.wheel, size: 14)),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(T.s4),
        child: running ? _round(s) : _wheel(s),
      ),
    );
  }

  Widget _wheel(S s) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_category != null && _left <= 0) ...[
            Text(s('timeUp'), style: AppType.display(T.wheel, size: 30)),
            const SizedBox(height: T.s2),
            Text('$_score ${s('judgedThisRound')}',
                style: const TextStyle(fontSize: 15, color: T.dim)),
            const SizedBox(height: T.s6),
          ],
          RotationTransition(
            turns: Tween<double>(begin: 0, end: _target).animate(_turns),
            child: CustomPaint(
              size: const Size(230, 230),
              painter: _WheelPainter(_slices),
            ),
          ),
          const SizedBox(height: T.s6),
          GestureDetector(
            onTap: _spin.isAnimating ? null : _launch,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: T.wheel,
                borderRadius: BorderRadius.circular(T.rControl),
                boxShadow: [
                  BoxShadow(
                      color: T.wheel.withValues(alpha: 0.34),
                      blurRadius: 26,
                      spreadRadius: -4),
                ],
              ),
              child: Text(s('spin'),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      );

  Widget _round(S s) {
    final joke = _joke!;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: T.lit(T.wheel),
              padding: const EdgeInsets.all(T.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((_category ?? '').toUpperCase(),
                      style: AppType.tag(T.wheel)),
                  const SizedBox(height: T.s3),
                  Text(joke.setup,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: T.s3),
                  Text(joke.punchline, style: AppType.punchline(size: 18)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: T.s4),
        Row(
          children: [
            Expanded(child: _btn(s('meh'), T.dim, () => _judge(false))),
            const SizedBox(width: T.s3),
            Expanded(child: _btn(s('funny'), T.arena, () => _judge(true))),
          ],
        ),
      ],
    );
  }

  Widget _btn(String label, Color c, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.16),
            border: Border.all(color: c.withValues(alpha: 0.4), width: 1),
            borderRadius: BorderRadius.circular(T.rControl),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: c)),
        ),
      );
}

class _WheelPainter extends CustomPainter {
  final List<String> slices;
  _WheelPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final centre = Offset(r, r);
    final sweep = 2 * pi / slices.length;
    for (var i = 0; i < slices.length; i++) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = T.rooms[i % T.rooms.length].withValues(alpha: 0.85);
      canvas.drawArc(Rect.fromCircle(center: centre, radius: r),
          -pi / 2 + i * sweep, sweep - 0.02, true, paint);
    }
    canvas.drawCircle(centre, r * 0.24, Paint()..color = T.night);
    canvas.drawCircle(
        centre,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = T.line);
  }

  @override
  bool shouldRepaint(_WheelPainter old) => false;
}
