class Joke {
  final String id;
  final String title;
  final String setup;
  final String punchline;
  final String category;
  final bool adult;

  const Joke({
    required this.id,
    required this.title,
    required this.setup,
    required this.punchline,
    required this.category,
    this.adult = false,
  });

  /// What goes to WhatsApp. The card is the brand; the text carries it.
  String get shareText => '$setup\n\n$punchline';
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
    if (d.isNegative) return 'just now';
    if (d.inMinutes < 1) return 'just now';
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

  String get label =>
      '${isUp ? '+' : '\u2212'}${changePercent.abs().toStringAsFixed(2)}%';
}
