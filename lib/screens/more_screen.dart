import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import 'cook_screen.dart';
import 'football_screen.dart';
import 'forecast_screen.dart';
import 'notes_screen.dart';
import 'prayer_screen.dart';
import 'settings_screen.dart';

/// The hub. Everything the brief does not surface lives here, one tap deep.
/// Sections are ordered by how often people actually reach for them, not by
/// how proud we are of them.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);

    return ListView(
      padding: const EdgeInsets.all(T.s3),
      children: [
        _grid(context, [
          _Item(Icons.mosque_outlined, s('prayer'), T.violet,
              () => const PrayerScreen()),
          _Item(Icons.thermostat, s('forecast'), T.blue,
              () => const ForecastScreen()),
          _Item(Icons.sticky_note_2_outlined, s('notes'), T.saffron,
              () => const NotesScreen()),
          _Item(Icons.restaurant_outlined, s('cook'), T.saffron,
              () => const CookScreen()),
          _Item(Icons.sports_soccer, s('football'), T.up,
              () => const FootballScreen()),
          _Item(Icons.menu_book_outlined, s('books'), T.blue, null),
        ]),
        const SizedBox(height: T.s5),
        _sectionLabel(s('support')),
        _link(
          icon: Icons.music_note_outlined,
          label: s('followTikTok'),
          onTap: () => _open('https://www.tiktok.com/'),
        ),
        _link(
          icon: Icons.coffee_outlined,
          label: s('tipUs'),
          onTap: () => _open('https://ko-fi.com/'),
        ),
        _link(
          icon: Icons.mail_outline,
          label: s('contactUs'),
          onTap: () => _open('mailto:hello@example.com?subject=Punchline'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: T.s3, horizontal: 2),
          child: Text(s('supportBlurb'),
              style: const TextStyle(
                  fontSize: 12, height: 1.5, color: T.textFaint)),
        ),
        const SizedBox(height: T.s4),
        _link(
          icon: Icons.tune,
          label: s('settings'),
          onTap: () => SettingsSheet.show(context),
        ),
        const SizedBox(height: T.s5),
      ],
    );
  }

  Widget _grid(BuildContext context, List<_Item> items) => GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: T.s3,
        mainAxisSpacing: T.s3,
        childAspectRatio: 1.0,
        children: [
          for (final item in items)
            GestureDetector(
              onTap: item.builder == null
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => item.builder!()),
                      ),
              child: Opacity(
                opacity: item.builder == null ? 0.4 : 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: T.card,
                    border: Border.all(color: T.border, width: 0.5),
                    borderRadius: BorderRadius.circular(T.rCard),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 24, color: item.tint),
                      const SizedBox(height: T.s2),
                      Text(item.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: T.text)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 2, bottom: T.s2),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11, letterSpacing: 0.9, color: T.textMuted)),
      );

  Widget _link({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 2),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: T.border, width: 0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 19, color: T.textMuted),
              const SizedBox(width: T.s3),
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontSize: 15, color: T.text)),
              ),
              const Icon(Icons.chevron_right, size: 18, color: T.textFaint),
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

class _Item {
  final IconData icon;
  final String label;
  final Color tint;
  final Widget Function()? builder;
  const _Item(this.icon, this.label, this.tint, this.builder);
}
