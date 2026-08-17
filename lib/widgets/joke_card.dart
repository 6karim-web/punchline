import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/profile_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// The signature component: the joke arrives folded. Tap to unfold.
/// Everything else on screen stays quiet so this one object can carry the
/// brand — and it is the only animation in the app.
class JokeCard extends StatefulWidget {
  final Joke joke;
  final String? eyebrow;
  final bool startOpen;
  final VoidCallback? onChanged;

  const JokeCard({
    super.key,
    required this.joke,
    this.eyebrow,
    this.startOpen = false,
    this.onChanged,
  });

  @override
  State<JokeCard> createState() => _JokeCardState();
}

class _JokeCardState extends State<JokeCard> {
  late bool _open = widget.startOpen;

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final accent = T.forCategory(widget.joke.category);
    final fav = Profile.instance.isFavourite(widget.joke.id);

    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: T.tint(accent),
          border: Border.all(color: accent.withValues(alpha: 0.28), width: 1),
          borderRadius: BorderRadius.circular(T.rCard),
        ),
        padding: const EdgeInsets.all(T.s4 + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    (widget.eyebrow ?? widget.joke.category).toUpperCase(),
                    style: AppType.eyebrow(accent),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Profile.instance.toggleFavourite(widget.joke.id);
                    if (mounted) setState(() {});
                    widget.onChanged?.call();
                  },
                  child: Icon(fav ? Icons.favorite : Icons.favorite_border,
                      size: 19, color: fav ? T.rose : T.faint),
                ),
              ],
            ),
            const SizedBox(height: T.s3),
            Text(widget.joke.setup,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: T.s4),
            _Crease(open: _open, accent: accent),
            AnimatedSize(
              duration: T.foldDuration,
              curve: T.foldCurve,
              alignment: Alignment.topCenter,
              child: _open ? _revealed(s, accent) : _hint(s, accent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hint(S s, Color accent) => Padding(
        padding: const EdgeInsets.only(top: 11),
        child: Row(
          children: [
            Icon(Icons.keyboard_arrow_down, size: 17, color: accent),
            const SizedBox(width: 5),
            Text(s('tapForPunchline'),
                style: TextStyle(fontSize: 13, color: accent)),
          ],
        ),
      );

  Widget _revealed(S s, Color accent) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: T.s4),
          Text(widget.joke.punchline,
              style: AppType.punchline(color: T.ink, size: 19)),
          const SizedBox(height: T.s5),
          Row(
            children: [
              Expanded(
                child: _Button(
                  label: s('share'),
                  icon: Icons.ios_share,
                  color: accent,
                  onTap: () => Share.share(widget.joke.shareText),
                ),
              ),
              const SizedBox(width: T.s2),
              _Button(
                icon: Icons.sentiment_very_satisfied,
                color: accent,
                filled: false,
                onTap: () async {
                  await Profile.instance.recordLaugh();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s('laughLogged'))),
                  );
                  widget.onChanged?.call();
                },
              ),
            ],
          ),
        ],
      );
}

/// The fold. Dashed while closed, solid once opened — the small physical
/// metaphor of a note being unfolded.
class _Crease extends StatelessWidget {
  final bool open;
  final Color accent;
  const _Crease({required this.open, required this.accent});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 1,
        child: CustomPaint(
          size: const Size(double.infinity, 1),
          painter: _CreasePainter(
              open: open, color: accent.withValues(alpha: open ? 0.5 : 0.35)),
        ),
      );
}

class _CreasePainter extends CustomPainter {
  final bool open;
  final Color color;
  _CreasePainter({required this.open, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    if (open) {
      canvas.drawLine(Offset.zero, Offset(size.width, 0), p);
      return;
    }
    const dash = 3.0, gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), p);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_CreasePainter old) =>
      old.open != open || old.color != color;
}

class _Button extends StatelessWidget {
  final String? label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _Button({
    this.label,
    required this.icon,
    required this.color,
    this.filled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
              vertical: 12, horizontal: label == null ? 14 : T.s4),
          decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            border: filled
                ? null
                : Border.all(color: color.withValues(alpha: 0.4), width: 1),
            borderRadius: BorderRadius.circular(T.rControl),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: filled ? Colors.white : color),
              if (label != null) ...[
                const SizedBox(width: 7),
                Text(label!,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: filled ? Colors.white : color)),
              ],
            ],
          ),
        ),
      );
}
