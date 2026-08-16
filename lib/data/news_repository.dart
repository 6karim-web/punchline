import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../l10n/app_locale.dart';
import '../models/models.dart';

/// Feeds are chosen per language from primary sources — the newsrooms
/// themselves, not an aggregator. Removing the middleman is what makes the
/// sourcing reliable; Google News only republishes these same outlets.
class NewsRepository {
  NewsRepository._();
  static final instance = NewsRepository._();

  static const _general = <String, Map<String, String>>{
    'en': {
      'NPR': 'https://feeds.npr.org/1001/rss.xml',
      'CBS News': 'https://www.cbsnews.com/latest/rss/main',
      'Yahoo News': 'https://news.yahoo.com/rss/',
    },
    'es': {
      'BBC Mundo': 'https://feeds.bbci.co.uk/mundo/rss.xml',
      'El Pais': 'https://feeds.elpais.com/mrss-s/pages/ep/site/elpais.com/portada',
      'DW Espanol': 'https://rss.dw.com/rdf/rss-sp-all',
    },
    'fr': {
      'France 24': 'https://www.france24.com/fr/rss',
      'Le Monde': 'https://www.lemonde.fr/rss/une.xml',
      'RFI': 'https://www.rfi.fr/fr/rss',
    },
    'ar': {
      'BBC Arabic': 'https://feeds.bbci.co.uk/arabic/rss.xml',
      'France 24': 'https://www.france24.com/ar/rss',
      'DW Arabic': 'https://rss.dw.com/rdf/rss-ar-all',
    },
  };

  static const _markets = <String, Map<String, String>>{
    'en': {
      'CNBC': 'https://search.cnbc.com/rs/search/combinedcms/view.xml'
          '?partnerId=wrss25&id=20910258',
      'MarketWatch':
          'https://feeds.content.dowjones.io/public/rss/mw_topstories',
    },
    'es': {
      'Expansion': 'https://e00-expansion.uecdn.es/rss/economia.xml',
      'BBC Mundo': 'https://feeds.bbci.co.uk/mundo/economia/rss.xml',
    },
    'fr': {
      'Les Echos': 'https://services.lesechos.fr/rss/les-echos-economie.xml',
      'France 24': 'https://www.france24.com/fr/economie/rss',
    },
    'ar': {
      'BBC Arabic': 'https://feeds.bbci.co.uk/arabic/business/rss.xml',
      'France 24': 'https://www.france24.com/ar/economie/rss',
    },
  };

  static const _football = <String, Map<String, String>>{
    'en': {
      'ESPN': 'https://www.espn.com/espn/rss/soccer/news',
      'Sky Sports': 'https://feeds.skynews.com/feeds/rss/sports.xml',
    },
    'es': {
      'Marca': 'https://e00-marca.uecdn.es/rss/futbol/primera-division.xml',
      'AS': 'https://as.com/rss/futbol/primera.xml',
    },
    'fr': {
      'L Equipe': 'https://www.lequipe.fr/rss/actu_rss_Football.xml',
      'France 24': 'https://www.france24.com/fr/sports/rss',
    },
    'ar': {
      'BBC Arabic': 'https://feeds.bbci.co.uk/arabic/sports/rss.xml',
      'France 24': 'https://www.france24.com/ar/sports/rss',
    },
  };

  final _cache = <String, List<Article>>{};

  Future<List<Article>> general(AppLocale l, {bool refresh = false}) =>
      _get('g-${l.code}', _general[l.code] ?? _general['en']!, refresh);

  Future<List<Article>> markets(AppLocale l, {bool refresh = false}) =>
      _get('m-${l.code}', _markets[l.code] ?? _markets['en']!, refresh);

  Future<List<Article>> football(AppLocale l, {bool refresh = false}) =>
      _get('f-${l.code}', _football[l.code] ?? _football['en']!, refresh);

  Future<List<Article>> _get(
      String key, Map<String, String> feeds, bool refresh) async {
    if (_cache.containsKey(key) && !refresh) return _cache[key]!;
    return _cache[key] = await _fetchAll(feeds);
  }

  Future<List<Article>> _fetchAll(Map<String, String> feeds) async {
    final results = await Future.wait(
        feeds.entries.map((e) => _fetchOne(e.key, e.value)));
    final all = results.expand((e) => e).toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    // Never two consecutive items from one outlet: a feed sorted by date
    // alone shows five headlines from the same source and reads as broken.
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
      final res =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return const [];
      final doc = XmlDocument.parse(res.body);
      final items = doc.findAllElements('item');
      return items
          .take(15)
          .map((item) {
            final title = _text(item, 'title');
            return Article(
              id: '$source-${title.hashCode}',
              source: source,
              title: title,
              url: _text(item, 'link'),
              imageUrl: _image(item),
              publishedAt: _parseDate(_text(item, 'pubDate')),
            );
          })
          .where((a) => a.title.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Every newsroom hides its thumbnail somewhere different. Four places to
  /// look, in order of how clean the result usually is.
  static String? _image(XmlElement item) {
    for (final tag in ['media:thumbnail', 'media:content']) {
      final el = item.findElements(tag);
      if (el.isNotEmpty) {
        final url = el.first.getAttribute('url');
        if (url != null && url.startsWith('http')) return url;
      }
    }
    final enc = item.findElements('enclosure');
    if (enc.isNotEmpty) {
      final url = enc.first.getAttribute('url');
      final type = enc.first.getAttribute('type') ?? '';
      if (url != null && (type.startsWith('image') || _looksImage(url))) {
        return url;
      }
    }
    // Last resort: the first <img> buried in the HTML description.
    final desc = _text(item, 'description');
    final m = RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(desc);
    final url = m?.group(1);
    return (url != null && url.startsWith('http')) ? url : null;
  }

  static bool _looksImage(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.jpg') || u.endsWith('.jpeg') ||
        u.endsWith('.png') || u.endsWith('.webp');
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
