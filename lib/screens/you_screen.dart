import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/joke_repository.dart';
import '../data/profile_repository.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'settings_screen.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final p = Profile.instance;

    return ListView(
      padding: const EdgeInsets.all(T.s4),
      children: [
        Text(s('you'), style: AppType.display(T.ink, size: 30)),
        const SizedBox(height: T.s5),
        Row(
          children: [
            Expanded(child: _stat('${p.points}', s('points'), T.violet)),
            const SizedBox(width: T.s3),
            Expanded(child: _stat('${p.streak}', s('dayStreak'), T.coral)),
          ],
        ),
        const SizedBox(height: T.s3),
        Row(
          children: [
            Expanded(child: _stat('${p.laughsCaused}', s('laughs'), T.sun)),
            const SizedBox(width: T.s3),
            Expanded(child: _stat('${p.verdicts.length}', s('judged'), T.mint)),
          ],
        ),
        const SizedBox(height: T.s3),
        Row(
          children: [
            Expanded(
                child: _stat('${p.favourites.length}', s('favourites'), T.rose)),
            const SizedBox(width: T.s3),
            Expanded(
                child: _stat('${p.written.length}', s('written'), T.sky)),
          ],
        ),
        if (p.written.isNotEmpty) ...[
          const SizedBox(height: T.s5),
          Text(s('yourPunchlines'), style: AppType.eyebrow(T.faint)),
          const SizedBox(height: T.s2),
          for (final entry in p.written.entries.toList().reversed.take(20))
            _written(entry.key, entry.value),
        ],
        const SizedBox(height: T.s5),
        Text(s('support'), style: AppType.eyebrow(T.faint)),
        const SizedBox(height: T.s2),
        _link(Icons.music_note_outlined, s('followTikTok'),
            () => _open('https://www.tiktok.com/')),
        _link(Icons.coffee_outlined, s('tipUs'),
            () => _open('https://ko-fi.com/')),
        _link(Icons.mail_outline, s('contactUs'),
            () => _open('mailto:hello@example.com?subject=Punchline')),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: T.s3),
          child: Text(s('supportBlurb'),
              style: const TextStyle(fontSize: 12.5, height: 1.5, color: T.faint)),
        ),
        const SizedBox(height: T.s3),
        _link(Icons.tune, s('settings'), () => SettingsSheet.show(context)),
        const SizedBox(height: T.s6),
      ],
    );
  }

  Widget _stat(String value, String label, Color color) => Container(
        decoration: BoxDecoration(
          color: T.tint(color),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
          borderRadius: BorderRadius.circular(T.rCard),
        ),
        padding: const EdgeInsets.symmetric(vertical: T.s4),
        child: Column(
          children: [
            Text(value, style: AppType.number(color: color, size: 24)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: T.muted)),
          ],
        ),
      );

  Widget _written(String jokeId, String text) {
    final joke = JokeRepository.instance.byId(jokeId);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: T.s2),
      padding: const EdgeInsets.all(T.s4),
      decoration: BoxDecoration(
        color: T.surface,
        border: Border.all(color: T.border, width: 1),
        borderRadius: BorderRadius.circular(T.rCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (joke != null) ...[
            Text(joke.setup,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: T.muted)),
            const SizedBox(height: 6),
          ],
          Text(text, style: AppType.punchline(size: 16)),
        ],
      ),
    );
  }

  Widget _link(IconData icon, String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: T.border, width: 1)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 19, color: T.muted),
              const SizedBox(width: T.s3),
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontSize: 15, color: T.ink)),
              ),
              const Icon(Icons.chevron_right, size: 18, color: T.faint),
            ],
          ),
        ),
      );

  static Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
