import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/brief_repository.dart';
import '../data/digest_repository.dart';
import '../data/news_repository.dart';
import '../data/sample_data.dart';
import '../data/weather_repository.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../screens/settings_screen.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/feed_states.dart';
import '../widgets/news_row.dart';
import '../widgets/punchline_card.dart';

/// The brief is the product; the tabs are the depth behind it.
///
/// Two minutes, four blocks, and then it ENDS. The full stop is the point:
/// a feed you can finish gives satisfaction, and satisfaction is what brings
/// someone back tomorrow. Every block is a door into its section for anyone
/// who wants more.
class BriefScreen extends StatefulWidget {
  final void Function(int tabIndex) onOpenTab;
  const BriefScreen({super.key, required this.onOpenTab});

  @override
  State<BriefScreen> createState() => _BriefScreenState();
}

class _BriefScreenState extends State<BriefScreen> {
  late Future<List<Article>> _news;
  late Future<Weather?> _weather;

  @override
  void initState() {
    super.initState();
    _news = NewsRepository.instance.general(AppState.instance.locale);
    _weather = WeatherRepository.instance.forCity(AppState.instance.city);
    AppState.instance.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => _reload();

  void _reload() {
    if (!mounted) return;
    setState(() {
      _news = NewsRepository.instance.general(AppState.instance.locale);
      _weather =
          WeatherRepository.instance.forCity(AppState.instance.city, refresh: true);
    });
  }

  String _greeting(S s) {
    final h = DateTime.now().hour;
    if (h < 12) return s('goodMorning');
    if (h < 18) return s('goodAfternoon');
    return s('goodEvening');
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    return RefreshIndicator(
      color: T.saffron,
      backgroundColor: T.card,
      onRefresh: () async {
        _reload();
        await _news;
      },
      child: ListView(
        padding: const EdgeInsets.all(T.s3),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2, bottom: T.s3),
            child: Text(_greeting(s), style: AppType.punchlineHero()),
          ),
          _weatherBlock(s),
          const SizedBox(height: T.s3),
          FutureBuilder<List<Article>>(
            future: _news,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return Loading(label: s('buildingBrief'));
              }
              final news = snap.data ?? const <Article>[];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _digest(news, s),
                  _headlines(news, s),
                  const SizedBox(height: T.s3),
                  _marketsBlock(s),
                  const SizedBox(height: T.s3),
                  _jokeBlock(news, s),
                  const SizedBox(height: T.s5),
                  _theEnd(s),
                ],
              );
            },
          ),
          const SizedBox(height: T.s5),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, {String? action, VoidCallback? onTap}) =>
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 2, bottom: T.s2),
        child: Row(
          children: [
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 11, letterSpacing: 0.9, color: T.textMuted)),
            ),
            if (action != null)
              GestureDetector(
                onTap: onTap,
                child: Text(action,
                    style: const TextStyle(fontSize: 12, color: T.saffron)),
              ),
          ],
        ),
      );

  Widget _card({required Widget child, VoidCallback? onTap}) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: T.card,
            border: Border.all(color: T.border, width: 0.5),
            borderRadius: BorderRadius.circular(T.rCard),
          ),
          padding: const EdgeInsets.all(T.s4),
          child: child,
        ),
      );

  Widget _weatherBlock(s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(s('weather'),
            action: AppState.instance.city.name,
            onTap: () => SettingsSheet.show(context)),
        FutureBuilder<Weather?>(
          future: _weather,
          builder: (context, snap) {
            final w = snap.data;
            if (snap.connectionState != ConnectionState.done) {
              return _card(
                  child: Text(s('checkingSky'),
                      style: Theme.of(context).textTheme.bodySmall));
            }
            if (w == null) {
              return _card(
                child: Text(s('weatherUnavailable'),
                    style: Theme.of(context).textTheme.bodySmall),
              );
            }
            return _card(
              child: Row(
                children: [
                  Text('${w.tempF.round()}\u00b0',
                      style: AppType.punchlineHero().copyWith(color: T.text)),
                  const SizedBox(width: T.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s(w.descriptionKey),
                            style: const TextStyle(fontSize: 15, color: T.text)),
                        const SizedBox(height: 3),
                        Text(
                          '${s('high')} ${w.highF.round()}\u00b0  '
                          '${s('low')} ${w.lowF.round()}\u00b0   '
                          '${w.rainChance}% ${s('rain')}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        FutureBuilder<Weather?>(
          future: _weather,
          builder: (context, snap) => snap.data == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsetsDirectional.only(start: 2, top: T.s2),
                  child: Text(s(snap.data!.adviceKey),
                      style: const TextStyle(fontSize: 13, color: T.textMuted)),
                ),
        ),
      ],
    );
  }

  /// The day in one sentence, plus the two stories behind it. This is the
  /// block that makes the brief feel written rather than assembled.
  Widget _digest(List<Article> news, S s) {
    final digest = DigestRepository.instance.build(news, AppState.instance.locale);
    if (digest == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(s('digest')),
        _card(
          onTap: () => widget.onOpenTab(3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(digest.sentence,
                  style: const TextStyle(
                      fontSize: 13, height: 1.5, color: T.textMuted)),
              const SizedBox(height: T.s2),
              Text(digest.topics.first,
                  style: const TextStyle(
                      fontSize: 17, height: 1.35, color: T.text)),
              if (digest.topics.length > 1) ...[
                const SizedBox(height: T.s3),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: T.s3),
                Text(s('alsoToday'),
                    style: const TextStyle(fontSize: 11, color: T.textFaint)),
                const SizedBox(height: T.s2),
                for (final t in digest.topics.skip(1))
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: T.s2),
                    child: Text('\u2022  $t',
                        style: const TextStyle(
                            fontSize: 14, height: 1.4, color: T.textMuted)),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: T.s3),
      ],
    );
  }

  Widget _headlines(List<Article> news, S s) {
    if (news.isEmpty) {
      return Failed(
          message: s('headlinesFailed'), onRetry: _reload);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(s('today'),
            action: s('allNews'), onTap: () => widget.onOpenTab(3)),
        for (final a in news.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: T.s2),
            child: _card(
              onTap: () => widget.onOpenTab(3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.source,
                            style:
                                const TextStyle(fontSize: 11, color: T.blue)),
                        const SizedBox(height: 6),
                        Text(a.title,
                            style: const TextStyle(
                                fontSize: 15, height: 1.4, color: T.text)),
                      ],
                    ),
                  ),
                  if (a.imageUrl != null) ...[
                    const SizedBox(width: T.s3),
                    Thumb(url: a.imageUrl!, size: 64),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _marketsBlock(s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(s('marketsLabel'),
            action: s('details'), onTap: () => widget.onOpenTab(2)),
        _card(
          onTap: () => widget.onOpenTab(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final t in Sample.tickers)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.symbol,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 3),
                    Text(t.label,
                        style: AppType.number(
                            color: t.isUp ? T.up : T.down, size: 16)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _jokeBlock(List<Article> news, S s) {
    final (joke, theme) = BriefRepository.instance.forHeadlines(news);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          theme == null ? s('andFinally') : s('onThatNote'),
          action: s('more'),
          onTap: () => widget.onOpenTab(1),
        ),
        PunchlineCard(
          joke: joke,
          eyebrow: s('todaysPunchline'),
          onShare: () => Share.share(joke.shareText),
        ),
      ],
    );
  }

  /// The full stop. Without it the brief is just another endless feed.
  Widget _theEnd(s) => Column(
        children: [
          Container(width: 28, height: 1, color: T.borderSoft),
          const SizedBox(height: T.s3),
          Text(s('thatsTwoMinutes'),
              style: const TextStyle(fontSize: 14, color: T.textMuted)),
          const SizedBox(height: T.s1),
          Text(s('seeYouTomorrow'),
              style: const TextStyle(fontSize: 13, color: T.textFaint)),
          const SizedBox(height: T.s4),
          Text(s('weatherBy'),
              style: const TextStyle(fontSize: 10, color: T.textFaint)),
        ],
      );

}
