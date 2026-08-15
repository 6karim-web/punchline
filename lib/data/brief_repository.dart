import '../models/models.dart';
import 'joke_repository.dart';

/// Picks the joke that comments on the day.
///
/// It does not write a joke about the news — that needs human writers, and a
/// machine-written topical joke lands flat. It matches the *theme*: markets
/// tumble, you get a money joke; a health story leads, you get a doctor joke.
/// The effect is that the punchline seems to answer the morning.
class BriefRepository {
  BriefRepository._();
  static final instance = BriefRepository._();

  /// If any headline touches these, no theme matching happens at all.
  /// A money joke on the morning of a disaster is the screenshot that ends
  /// an app. This list is not negotiable, and erring wide costs nothing.
  static const _blocked = <String>[
    'dead', 'death', 'died', 'killed', 'kills', 'killing', 'fatal',
    'victim', 'shooting', 'shot', 'stabbing', 'massacre', 'attack',
    'terror', 'bomb', 'explosion', 'war', 'invasion', 'strike kills',
    'earthquake', 'hurricane', 'wildfire', 'flood', 'tornado', 'crash',
    'suicide', 'overdose', 'abuse', 'assault', 'missing child', 'funeral',
    'mourns', 'tragedy', 'outbreak', 'famine', 'hostage', 'genocide',
  ];

  static const _themes = <String, List<String>>{
    'money': ['market', 'stocks', 'inflation', 'fed', 'economy', 'tariff',
      'jobs report', 'wall street', 'rate', 'earnings', 'bank', 'tax'],
    'work': ['layoff', 'hiring', 'union', 'workers', 'office', 'strike',
      'employees', 'labor', 'boss', 'ceo', 'resign'],
    'tech': ['ai', 'artificial intelligence', 'chip', 'apple', 'google',
      'software', 'app', 'robot', 'data', 'startup', 'openai'],
    'medical': ['health', 'hospital', 'doctor', 'vaccine', 'drug', 'fda',
      'patients', 'medicare', 'insurance'],
    'kids': ['school', 'students', 'teacher', 'college', 'campus',
      'education', 'university'],
    'animals': ['zoo', 'dog', 'cat', 'wildlife', 'bear', 'species'],
  };

  /// Returns the joke for today, and the theme it was matched on (or null).
  (Joke, String?) forHeadlines(List<Article> headlines) {
    final repo = JokeRepository.instance;
    final text = headlines.map((a) => a.title.toLowerCase()).join(' ');

    if (headlines.isEmpty || _blocked.any(text.contains)) {
      return (repo.jokeOfTheDay(), null);
    }

    var bestTheme = '';
    var bestScore = 0;
    _themes.forEach((theme, words) {
      final score = words.where(text.contains).length;
      if (score > bestScore) {
        bestScore = score;
        bestTheme = theme;
      }
    });

    if (bestScore == 0) return (repo.jokeOfTheDay(), null);

    final pool = repo.byCategory(bestTheme);
    if (pool.isEmpty) return (repo.jokeOfTheDay(), null);

    // Stable for the day, so everyone sees the same one and can share it.
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    return (pool[seed % pool.length], bestTheme);
  }
}
