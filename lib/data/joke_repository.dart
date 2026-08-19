import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../l10n/app_locale.dart';
import '../models/models.dart';

/// Loads the bundled joke collection once, then serves it without repeats.
/// No network, no backend — the whole book ships inside the app.
class JokeRepository {
  JokeRepository._();
  static final instance = JokeRepository._();

  List<Joke> _all = const [];
  final Set<String> _seen = {};
  final _random = Random();
  String? _loadedCode;

  /// One catalogue per language. These are not translations of each other —
  /// a joke that lands in French dies word-for-word in English, so each
  /// language owns its own book. Missing catalogues fall back to English
  /// rather than showing an empty library.
  static const _assets = <String, String>{
    'en': 'assets/jokes.json',
    'fr': 'assets/jokes_fr.json',
  };

  Future<void> load(AppLocale locale) async {
    final path = _assets[locale.code] ?? _assets['en']!;
    if (_loadedCode == path) return;
    _loadedCode = path;
    _seen.clear();
    final raw = await rootBundle.loadString(path);
    final list = jsonDecode(raw) as List<dynamic>;
    _all = list
        .map((e) => Joke(
              id: e['id'] as String,
              title: e['title'] as String,
              setup: e['setup'] as String,
              punchline: e['punchline'] as String,
              category: e['category'] as String,
              adult: e['adult'] as bool,
            ))
        .toList();
  }

  List<String> get categories {
    final set = _all.where((j) => !j.adult).map((j) => j.category).toSet();
    final sorted = set.toList()..sort();
    return ['all', ...sorted];
  }

  List<Joke> byCategory(String category, {bool allowAdult = false}) {
    return _all
        .where((j) => allowAdult || !j.adult)
        .where((j) => category == 'all' || j.category == category)
        .toList();
  }

  /// The joke of the day is stable for a given date — everyone opening the
  /// app on the same day gets the same one, which is what makes it shareable.
  Joke jokeOfTheDay([DateTime? now]) {
    final clean = _all.where((j) => !j.adult).toList();
    final date = now ?? DateTime.now();
    final index = (date.year * 10000 + date.month * 100 + date.day) % clean.length;
    return clean[index];
  }

  /// Never serves the same joke twice until the pool is exhausted.
  Joke? next({String category = 'all', bool allowAdult = false}) {
    final pool = byCategory(category, allowAdult: allowAdult);
    if (pool.isEmpty) return null;
    final unseen = pool.where((j) => !_seen.contains(j.id)).toList();
    if (unseen.isEmpty) {
      _seen.removeWhere((id) => pool.any((j) => j.id == id));
      return pool[_random.nextInt(pool.length)];
    }
    final pick = unseen[_random.nextInt(unseen.length)];
    _seen.add(pick.id);
    return pick;
  }

  Joke? byId(String id) {
    for (final j in _all) {
      if (j.id == id) return j;
    }
    return null;
  }

  int get total => _all.where((j) => !j.adult).length;
}
