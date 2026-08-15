import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'dashed_line.dart';

/// The signature component. Everything else in the app stays quiet so this
/// one object can carry the brand. It is also the only animation we ship.
class PunchlineCard extends StatefulWidget {
  final Joke joke;
  final String eyebrow;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const PunchlineCard({
    super.key,
    required this.joke,
    this.eyebrow = "TODAY'S PUNCHLINE",
    this.onShare,
    this.onSave,
  });

  @override
  State<PunchlineCard> createState() => _PunchlineCardState();
}

class _PunchlineCardState extends State<PunchlineCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _open ? 'Fold the punchline' : 'Reveal the punchline',
      child: GestureDetector(
        onTap: () => setState(() => _open = !_open),
        child: Container(
          decoration: BoxDecoration(
            color: T.card,
            border: Border.all(color: T.border, width: 0.5),
            borderRadius: BorderRadius.circular(T.rCard),
          ),
          padding: const EdgeInsets.all(T.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.eyebrow, style: AppType.eyebrow()),
              const SizedBox(height: T.s2 + 1),
              Text(
                widget.joke.setup,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: T.s4),
              DashedLine(solid: _open),
              const SizedBox(height: 11),
              AnimatedSize(
                duration: T.foldDuration,
                curve: T.foldCurve,
                alignment: Alignment.topCenter,
                child: _open ? _revealed(context) : _hint(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hint(BuildContext context) => Row(
        children: [
          const Icon(Icons.keyboard_arrow_down, size: 16, color: T.textMuted),
          const SizedBox(width: T.s1 + 2),
          Text('Tap for the punchline',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      );

  Widget _revealed(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.joke.punchline, style: AppType.punchline()),
          const SizedBox(height: T.s4 + 2),
          Row(
            children: [
              Expanded(
                child: _Action(
                  label: 'Share',
                  filled: true,
                  onTap: widget.onShare,
                ),
              ),
              const SizedBox(width: T.s2),
              _Action(icon: Icons.favorite_border, onTap: widget.onSave),
            ],
          ),
        ],
      );
}

class _Action extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool filled;
  final VoidCallback? onTap;

  const _Action({this.label, this.icon, this.filled = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(T.rControl),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: label == null ? 13 : T.s3,
        ),
        decoration: BoxDecoration(
          color: filled ? T.saffron : Colors.transparent,
          border: filled ? null : Border.all(color: T.borderSoft, width: 0.5),
          borderRadius: BorderRadius.circular(T.rControl),
        ),
        child: label != null
            ? Text(
                label!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: filled ? T.canvas : T.text,
                ),
              )
            : Icon(icon, size: 16, color: T.text),
      ),
    );
  }
}
