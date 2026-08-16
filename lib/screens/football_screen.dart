import 'package:flutter/material.dart';
import '../data/news_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/feed_states.dart';
import '../widgets/news_row.dart';

/// Football reuses the news pipeline pointed at sports desks — same parsing,
/// same thumbnails, same source spreading. Live scores and fixtures need a
/// keyed API, so they wait for the server rather than shipping a key here.
class FootballScreen extends StatefulWidget {
  const FootballScreen({super.key});

  @override
  State<FootballScreen> createState() => _FootballScreenState();
}

class _FootballScreenState extends State<FootballScreen> {
  late Future<List<Article>> _news;

  @override
  void initState() {
    super.initState();
    _news = NewsRepository.instance.football(AppState.instance.locale);
  }

  void _reload() => setState(() => _news =
      NewsRepository.instance.football(AppState.instance.locale, refresh: true));

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    return Scaffold(
      appBar: AppBar(
        title: Text(s('football')),
        shape: const Border(bottom: BorderSide(color: T.border, width: 0.5)),
      ),
      body: RefreshIndicator(
        color: T.saffron,
        backgroundColor: T.card,
        onRefresh: () async {
          _reload();
          await _news;
        },
        child: FutureBuilder<List<Article>>(
          future: _news,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Loading(label: s('fetchingHeadlines'));
            }
            final items = snap.data ?? const <Article>[];
            if (items.isEmpty) {
              return ListView(children: [
                Failed(message: s('headlinesFailed'), onRetry: _reload),
              ]);
            }
            return ListView(
              padding: const EdgeInsets.all(T.s3),
              children: [for (final a in items) NewsRow(article: a)],
            );
          },
        ),
      ),
    );
  }
}
