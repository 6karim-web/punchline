import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/models.dart';

/// Loads the bundled joke collection once, then serves it without repeats.
/// No network, no backend — the whole book ships inside the app.
class JokeRepository {
  JokeRepository._();
  static final instance = JokeRepository._();

  List<Joke> _all = const [];
  final Set<String> _seen = {};
  final _random = Random();
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/jokes.json');
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
    _loaded = true;
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

  int get total => _all.where((j) => !j.adult).length;
}
