import '../l10n/app_locale.dart';
import '../l10n/strings.dart';
import '../models/models.dart';

/// Writes the morning summary without an LLM.
///
/// The idea: when five newsrooms independently lead with the same story,
/// that convergence IS the importance signal — more reliable than any
/// editorial guess. We cluster headlines by shared significant words, rank
/// clusters by how many distinct outlets carry them, and compose a sentence.
///
/// The server-side LLM version replaces this later. It stays cheap because
/// the digest is computed once per day per language, not per user.
class Digest {
  final String sentence;
  final List<String> topics;
  final int storyCount;
  const Digest(this.sentence, this.topics, this.storyCount);
}

class DigestRepository {
  DigestRepository._();
  static final instance = DigestRepository._();

  static const _stop = <String>{
    'the', 'a', 'an', 'and', 'or', 'but', 'of', 'to', 'in', 'on', 'for',
    'with', 'at', 'by', 'from', 'as', 'is', 'are', 'was', 'were', 'be',
    'been', 'it', 'its', 'this', 'that', 'his', 'her', 'their', 'they',
    'he', 'she', 'you', 'we', 'not', 'after', 'over', 'new', 'say',
    'says', 'said', 'will', 'has', 'have', 'more', 'than', 'about',
    'into', 'what', 'who', 'how', 'why', 'when', 'where', 'can', 'could',
    'would', 'may', 'one', 'two', 'first', 'last', 'amid', 'out', 'up',
    'down', 'off', 'your', 'el', 'la', 'los', 'las', 'un', 'una', 'de',
    'del', 'y', 'o', 'en', 'con', 'por', 'para', 'que', 'se', 'su', 'sus',
    'al', 'lo', 'es', 'son', 'como', 'mas', 'pero', 'sobre', 'le', 'les',
    'des', 'du', 'une', 'et', 'ou', 'dans', 'avec', 'pour', 'par', 'sur',
    'qui', 'ne', 'pas', 'ses', 'aux', 'est', 'sont', 'plus', 'apres',
    'cette', 'في', 'من', 'على', 'الى', 'عن', 'مع', 'هذا', 'هذه', 'التي',
    'الذي', 'بعد', 'قبل', 'بين',
  };

  Digest? build(List<Article> articles, AppLocale locale) {
    if (articles.length < 4) return null;
    final s = S(locale);

    // 1. Reduce each headline to its significant words.
    final words = <Article, Set<String>>{};
    for (final a in articles.take(30)) {
      words[a] = a.title
          .toLowerCase()
          .replaceAll(RegExp(r"[^\p{L}\p{N}\s]", unicode: true), ' ')
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 3 && !_stop.contains(w))
          .toSet();
    }

    // 2. Cluster: two headlines belong together if they share two or more
    //    significant words. Crude, but it catches the day's big story.
    final clusters = <List<Article>>[];
    final placed = <Article>{};
    for (final a in words.keys) {
      if (placed.contains(a)) continue;
      final group = <Article>[a];
      placed.add(a);
      for (final b in words.keys) {
        if (placed.contains(b)) continue;
        if (words[a]!.intersection(words[b]!).length >= 2) {
          group.add(b);
          placed.add(b);
        }
      }
      clusters.add(group);
    }

    // 3. Rank by how many DISTINCT outlets carry the story. One newsroom
    //    publishing five angles is not the same as five newsrooms agreeing.
    clusters.sort((a, b) {
      final da = a.map((x) => x.source).toSet().length;
      final db = b.map((x) => x.source).toSet().length;
      return db != da ? db.compareTo(da) : b.length.compareTo(a.length);
    });

    final topics = clusters
        .take(3)
        .map((c) => c.first.title)
        .toList();
    if (topics.isEmpty) return null;

    final lead = clusters.first;
    final outlets = lead.map((x) => x.source).toSet().length;
    final sentence = outlets >= 3
        ? '${s('everyoneLeadsWith')} ${_short(lead.first.title)}'
        : '${s('storiesThisMorning')} ${articles.length}';

    return Digest(sentence, topics, articles.length);
  }

  static String _short(String title) {
    final cut = title.split(RegExp(r'[:\u2014\u2013|]')).first.trim();
    return cut.length > 70 ? '${cut.substring(0, 67)}...' : cut;
  }
}
