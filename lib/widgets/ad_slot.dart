import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Deliberately second-class: no fill, dimmer text, always labelled.
/// An honestly-marked ad is tolerated; a disguised one costs you the review.
/// Swap the child for AdWidget(BannerAd) when AdMob is wired up.
class AdSlot extends StatelessWidget {
  final String placeholder;
  const AdSlot({super.key, this.placeholder = 'Ad slot'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: T.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: T.borderSoft, width: 0.5),
              borderRadius: BorderRadius.circular(T.rPill),
            ),
            child: const Text('Sponsored',
                style: TextStyle(fontSize: 11, color: T.textFaint)),
          ),
          const SizedBox(height: T.s2),
          Text(placeholder,
              style: const TextStyle(
                  fontSize: 14, height: 1.45, color: Color(0xFFA8AEB9))),
        ],
      ),
    );
  }
}
