import 'package:flutter/material.dart';
import '../data/news_repository.dart';
import '../data/sample_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/feed_states.dart';
import '../widgets/news_row.dart';

/// We report, we never recommend. No rankings, no signals, no "hot picks".
class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  late Future<List<Article>> _news;

  @override
  void initState() {
    super.initState();
    _news = NewsRepository.instance.markets();
  }

  void _reload() {
    setState(() => _news = NewsRepository.instance.markets(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              for (final t in Sample.tickers) ...[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: T.card,
                      border: Border.all(color: T.border, width: 0.5),
                      borderRadius: BorderRadius.circular(T.rCard),
                    ),
                    padding: const EdgeInsets.all(T.s3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.symbol,
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 3),
                        Text(t.label,
                            style: AppType.number(
                                color: t.isUp ? T.up : T.down, size: 17)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: T.s2),
              ],
            ],
          ),
          const SizedBox(height: T.s3),
          FutureBuilder<List<Article>>(
            future: _news,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Loading(label: 'Fetching market news');
              }
              final items = snap.data ?? const <Article>[];
              if (items.isEmpty) {
                return Failed(
                  message: 'No market news came through.\n'
                      'Check your connection.',
                  onRetry: _reload,
                );
              }
              return Column(
                children: [for (final a in items) NewsRow(article: a)],
              );
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'For informational purposes only. Not investment advice. '
            'Quotes are sample data in this build.',
            style: TextStyle(fontSize: 11, height: 1.5, color: T.textFaint),
          ),
          const SizedBox(height: T.s5),
        ],
      ),
    );
  }
}
