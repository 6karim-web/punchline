import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/news_row.dart';

/// We report, we never recommend. No rankings, no signals, no "hot picks" —
/// that line is what keeps this a news feature rather than investment advice.
class MarketsScreen extends StatelessWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
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
        for (final a in Sample.articles) NewsRow(article: a),
        const SizedBox(height: 14),
        const Text(
          'For informational purposes only. Not investment advice. '
          'Quotes delayed 15 minutes.',
          style: TextStyle(fontSize: 11, height: 1.5, color: T.textFaint),
        ),
        const SizedBox(height: T.s5),
      ],
    );
  }
}
