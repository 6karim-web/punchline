import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/models.dart';

/// Fetches RSS straight from the source. Good enough to see real headlines
/// in the app today; the server-side aggregator in supabase/ replaces this
/// later, because it can deduplicate across sources and cache.
class NewsRepository {
  NewsRepository._();
  static final instance = NewsRepository._();

  static const _general = <String, String>{
    'NPR': 'https://feeds.npr.org/1001/rss.xml',
    'CBS News': 'https://www.cbsnews.com/latest/rss/main',
    'Yahoo News': 'https://news.yahoo.com/rss/',
  };

  static const _markets = <String, String>{
    'CNBC': 'https://search.cnbc.com/rs/search/combinedcms/view.xml'
        '?partnerId=wrss25&id=20910258',
    'MarketWatch':
        'https://feeds.content.dowjones.io/public/rss/mw_topstories',
  };

  List<Article>? _cachedGeneral;
  List<Article>? _cachedMarkets;

  Future<List<Article>> general({bool refresh = false}) async {
    if (_cachedGeneral != null && !refresh) return _cachedGeneral!;
    return _cachedGeneral = await _fetchAll(_general);
  }

  Future<List<Article>> markets({bool refresh = false}) async {
    if (_cachedMarkets != null && !refresh) return _cachedMarkets!;
    return _cachedMarkets = await _fetchAll(_markets);
  }

  Future<List<Article>> _fetchAll(Map<String, String> feeds) async {
    final results = await Future.wait(
      feeds.entries.map((e) => _fetchOne(e.key, e.value)),
    );
    final all = results.expand((e) => e).toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    // Never two consecutive items from the same source — a feed sorted by
    // date alone shows five headlines from one outlet and reads as broken.
    final spread = <Article>[];
    final rest = [...all];
    while (rest.isNotEmpty) {
      final i = rest.indexWhere(
          (a) => spread.isEmpty || a.source != spread.last.source);
      spread.add(rest.removeAt(i == -1 ? 0 : i));
    }
    return spread.take(40).toList();
  }

  Future<List<Article>> _fetchOne(String source, String url) async {
    try {
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return const [];
      final doc = XmlDocument.parse(res.body);
      final items = doc.findAllElements('item');
      return items.take(15).map((item) {
        final title = _text(item, 'title');
        return Article(
          id: '$source-${title.hashCode}',
          source: source,
          title: title,
          url: _text(item, 'link'),
          publishedAt: _parseDate(_text(item, 'pubDate')),
        );
      }).where((a) => a.title.isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }

  static String _text(XmlElement parent, String tag) {
    final el = parent.findElements(tag);
    return el.isEmpty ? '' : el.first.innerText.trim();
  }

  static DateTime _parseDate(String raw) {
    if (raw.isEmpty) return DateTime.now();
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    final m = RegExp(r'(\d{1,2})\s+(\w{3})\s+(\d{4})\s+(\d{2}):(\d{2})')
        .firstMatch(raw);
    if (m == null) return DateTime.now();
    return DateTime.utc(
      int.parse(m.group(3)!),
      months[m.group(2)!] ?? 1,
      int.parse(m.group(1)!),
      int.parse(m.group(4)!),
      int.parse(m.group(5)!),
    ).toLocal();
  }
}
