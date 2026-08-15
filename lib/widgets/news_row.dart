import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/tokens.dart';

/// News is a link you skim, not an object you keep — so it gets a hairline,
/// never a card. That distinction is what stops the feed becoming a grid of
/// identical rectangles.
class NewsRow extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;

  const NewsRow({super.key, required this.article, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 2),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: T.border, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: T.blueTint,
                borderRadius: BorderRadius.circular(T.rPill),
              ),
              child: Text(
                article.source,
                style: const TextStyle(fontSize: 11, color: T.blue),
              ),
            ),
            const SizedBox(height: T.s2),
            Text(article.title,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 5),
            Text(article.age,
                style: const TextStyle(fontSize: 11, color: T.textFaint)),
          ],
        ),
      ),
    );
  }
}
