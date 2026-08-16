import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/tokens.dart';

/// News is a link you skim, not an object you keep — a hairline, never a card.
/// The thumbnail sits at the end so the headline still starts on the reading
/// edge, which flips correctly in Arabic.
class NewsRow extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;

  const NewsRow({super.key, required this.article, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
            vertical: 13, horizontal: 2),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: T.border, width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: T.blueTint,
                      borderRadius: BorderRadius.circular(T.rPill),
                    ),
                    child: Text(article.source,
                        style: const TextStyle(fontSize: 11, color: T.blue)),
                  ),
                  const SizedBox(height: T.s2),
                  Text(article.title,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  Text(article.age,
                      style:
                          const TextStyle(fontSize: 11, color: T.textFaint)),
                ],
              ),
            ),
            if (article.imageUrl != null) ...[
              const SizedBox(width: T.s3),
              Thumb(url: article.imageUrl!, size: 72),
            ],
          ],
        ),
      ),
    );
  }
}

/// Thumbnails come from other people's servers, so every one of them is a
/// potential broken link. Fail to a quiet placeholder, never to a red error.
class Thumb extends StatelessWidget {
  final String url;
  final double size;
  const Thumb({super.key, required this.url, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(T.rControl),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _blank(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _blank(),
      ),
    );
  }

  Widget _blank() => Container(
        width: size,
        height: size,
        color: T.card,
        child: const Icon(Icons.image_outlined, size: 18, color: T.textFaint),
      );
}
