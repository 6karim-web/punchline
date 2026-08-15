import 'package:flutter/material.dart';
import '../data/news_repository.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme/tokens.dart';
import '../widgets/ad_slot.dart';
import '../widgets/feed_states.dart';
import '../widgets/news_row.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<Article>> _news;

  @override
  void initState() {
    super.initState();
    _news = NewsRepository.instance.general(AppState.instance.locale);
    AppState.instance.addListener(_reload);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() =>
        _news = NewsRepository.instance.general(AppState.instance.locale));
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
          FutureBuilder<List<Article>>(
            future: _news,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return Loading(label: s('fetchingHeadlines'));
              }
              final items = snap.data ?? const <Article>[];
              if (items.isEmpty) {
                return Failed(
                  message: s('headlinesFailed'), onRetry: _reload,
                );
              }
              return Column(
                children: [
                  for (final a in items) NewsRow(article: a),
                  const AdSlot(
                      placeholder: 'Open a brokerage account in five minutes'),
                ],
              );
            },
          ),
          const SizedBox(height: T.s5),
        ],
      ),
    );
  }
}
