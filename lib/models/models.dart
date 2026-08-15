class Joke {
  final String id;
  final String title;
  final String setup;
  final String punchline;
  final String category;
  final bool adult;
  final int shares;

  const Joke({
    required this.id,
    required this.title,
    required this.setup,
    required this.punchline,
    required this.category,
    this.adult = false,
    this.shares = 0,
  });

  factory Joke.fromMap(Map<String, dynamic> m) => Joke(
        id: m['id'] as String,
        title: (m['title'] ?? '') as String,
        setup: m['setup'] as String,
        punchline: m['punchline'] as String,
        category: (m['category'] ?? 'misc') as String,
        adult: (m['rating'] ?? 'tout_public') == 'adulte',
        shares: (m['share_count'] ?? 0) as int,
      );
}

class Article {
  final String id;
  final String source;
  final String title;
  final String url;
  final DateTime publishedAt;

  const Article({
    required this.id,
    required this.source,
    required this.title,
    required this.url,
    required this.publishedAt,
  });

  String get age {
    final d = DateTime.now().difference(publishedAt);
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    return '${d.inDays} d ago';
  }
}

class Ticker {
  final String symbol;
  final double changePercent;

  const Ticker(this.symbol, this.changePercent);

  bool get isUp => changePercent >= 0;

  /// Always formatted — raw doubles leak float artifacts onto the screen.
  String get label =>
      '${isUp ? '+' : '\u2212'}${changePercent.abs().toStringAsFixed(2)}%';
}
