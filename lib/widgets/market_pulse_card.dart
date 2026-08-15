import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

class MarketPulseCard extends StatelessWidget {
  final List<Ticker> tickers;
  final String? headline;

  const MarketPulseCard({super.key, required this.tickers, this.headline});

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall;
    return Container(
      decoration: BoxDecoration(
        color: T.card,
        border: Border.all(color: T.border, width: 0.5),
        borderRadius: BorderRadius.circular(T.rCard),
      ),
      padding: const EdgeInsets.symmetric(horizontal: T.s4, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Market pulse', style: small),
              Text('delayed 15 min', style: small),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final t in tickers) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.symbol, style: small),
                    const SizedBox(height: 2),
                    Text(t.label,
                        style: AppType.number(color: t.isUp ? T.up : T.down)),
                  ],
                ),
                const SizedBox(width: 20),
              ],
            ],
          ),
          if (headline != null) ...[
            const SizedBox(height: T.s3),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 11),
            Text(headline!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
