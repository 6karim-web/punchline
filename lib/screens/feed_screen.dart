import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/joke_repository.dart';
import '../data/news_repository.dart';
import '../data/sample_data.dart';
import '../models/models.dart';
import '../theme/tokens.dart';
import '../widgets/ad_slot.dart';
import '../widgets/feed_states.dart';
import '../widgets/market_pulse_card.dart';
import '../widgets/news_row.dart';
import '../widgets/punchline_card.dart';
import '../widgets/streak_card.dart';

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
    _news = NewsRepository.instance.general();
  }

  void _reload() {
    setState(() => _news = NewsRepository.instance.general(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    final joke = JokeRepository.instance.jokeOfTheDay();

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
          PunchlineCard(
            joke: joke,
            onShare: () => Share.share(joke.shareText),
          ),
          const SizedBox(height: T.s3),
          const MarketPulseCard(tickers: Sample.tickers),
          const SizedBox(height: T.s3),
          FutureBuilder<List<Article>>(
            future: _news,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Loading(label: 'Fetching headlines');
              }
              final items = snap.data ?? const <Article>[];
              if (items.isEmpty) {
                return Failed(
                  message: 'No headlines came through.\nCheck your connection.',
                  onRetry: _reload,
                );
              }
              return Column(
                children: [
                  for (final a in items.take(6)) NewsRow(article: a),
                  const AdSlot(
                      placeholder: 'Open a brokerage account in five minutes'),
                ],
              );
            },
          ),
          const SizedBox(height: T.s3),
          const StreakCard(days: 1),
          const SizedBox(height: T.s5),
        ],
      ),
    );
  }
}
