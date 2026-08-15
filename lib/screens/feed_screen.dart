import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../theme/tokens.dart';
import '../widgets/ad_slot.dart';
import '../widgets/market_pulse_card.dart';
import '../widgets/news_row.dart';
import '../widgets/punchline_card.dart';
import '../widgets/streak_card.dart';

/// The home tab is a feed, not a menu of sections. Users scroll; they don't
/// choose. Which cards appear here comes from the interests they picked at
/// onboarding — the composition is the personalisation.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(T.s3),
      children: [
        PunchlineCard(joke: Sample.jokes.first),
        const SizedBox(height: T.s3),
        MarketPulseCard(
          tickers: Sample.tickers,
          headline: 'Fed minutes point to a slower pace of cuts',
        ),
        const SizedBox(height: T.s3),
        for (final a in Sample.articles) NewsRow(article: a),
        const AdSlot(placeholder: 'Open a brokerage account in five minutes'),
        const SizedBox(height: T.s3),
        const StreakCard(days: 12),
        const SizedBox(height: T.s5),
      ],
    );
  }
}
