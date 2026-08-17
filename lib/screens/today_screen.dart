import 'package:flutter/material.dart';
import '../data/joke_repository.dart';
import '../data/profile_repository.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/joke_card.dart';

/// Today is short and it ENDS. A feed you can finish gives satisfaction, and
/// satisfaction is what brings someone back tomorrow.
class TodayScreen extends StatefulWidget {
  final void Function(int) onOpenTab;
  const TodayScreen({super.key, required this.onOpenTab});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final p = Profile.instance;
    final joke = JokeRepository.instance.jokeOfTheDay();

    return ListView(
      padding: const EdgeInsets.all(T.s4),
      children: [
        Text(_greeting(s), style: AppType.display(T.ink, size: 30)),
        const SizedBox(height: T.s2),
        Text(s('oneJokeADay'),
            style: const TextStyle(fontSize: 14, color: T.muted)),
        const SizedBox(height: T.s5),
        JokeCard(
          joke: joke,
          eyebrow: s('todaysPunchline'),
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: T.s5),
        Row(
          children: [
            Expanded(
                child: _stat('${p.streak}', s('dayStreak'), T.coral)),
            const SizedBox(width: T.s3),
            Expanded(
                child: _stat('${p.laughsCaused}', s('laughs'), T.sun)),
            const SizedBox(width: T.s3),
            Expanded(child: _stat('${p.points}', s('points'), T.violet)),
          ],
        ),
        const SizedBox(height: T.s5),
        _cta(s('playAGame'), s('gamesBlurb'), T.mint,
            () => widget.onOpenTab(2)),
        const SizedBox(height: T.s3),
        _cta(s('ventIt'), s('journalBlurb'), T.sky,
            () => widget.onOpenTab(3)),
        const SizedBox(height: T.s6),
        Center(
          child: Column(
            children: [
              Container(width: 28, height: 1, color: T.border),
              const SizedBox(height: T.s3),
              Text(s('thatsIt'),
                  style: const TextStyle(fontSize: 14, color: T.muted)),
              const SizedBox(height: 2),
              Text(s('seeYouTomorrow'),
                  style: const TextStyle(fontSize: 13, color: T.faint)),
            ],
          ),
        ),
        const SizedBox(height: T.s6),
      ],
    );
  }

  String _greeting(S s) {
    final h = DateTime.now().hour;
    if (h < 12) return s('goodMorning');
    if (h < 18) return s('goodAfternoon');
    return s('goodEvening');
  }

  Widget _stat(String value, String label, Color color) => Container(
        decoration: BoxDecoration(
          color: T.tint(color),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
          borderRadius: BorderRadius.circular(T.rCard),
        ),
        padding: const EdgeInsets.symmetric(vertical: T.s4, horizontal: T.s2),
        child: Column(
          children: [
            Text(value, style: AppType.number(color: color, size: 22)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: T.muted)),
          ],
        ),
      );

  Widget _cta(String title, String blurb, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: T.surface,
            border: Border.all(color: T.border, width: 1),
            borderRadius: BorderRadius.circular(T.rCard),
          ),
          padding: const EdgeInsets.all(T.s4),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: T.tint(color),
                  borderRadius: BorderRadius.circular(T.rControl),
                ),
                child: Icon(Icons.arrow_forward, size: 18, color: color),
              ),
              const SizedBox(width: T.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: T.ink)),
                    const SizedBox(height: 2),
                    Text(blurb,
                        style: const TextStyle(fontSize: 12.5, color: T.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
