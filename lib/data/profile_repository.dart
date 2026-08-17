import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything the app knows about you. Local only — nothing leaves the phone.
///
/// The counters are deliberately about what you DID, not how long you stayed:
/// jokes judged, punchlines written, people made to laugh. Time spent is not
/// an achievement and we refuse to reward it.
class Profile {
  Profile._();
  static final instance = Profile._();

  final Set<String> favourites = {};
  final Map<String, bool> verdicts = {}; // jokeId -> guilty of being funny
  final Map<String, String> written = {}; // jokeId -> your own punchline
  final Set<String> seen = {};
  int points = 0;
  int laughsCaused = 0;
  int streak = 0;
  String? lastOpenDay;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    favourites.addAll(p.getStringList('favourites') ?? const []);
    seen.addAll(p.getStringList('seen') ?? const []);
    points = p.getInt('points') ?? 0;
    laughsCaused = p.getInt('laughs') ?? 0;
    streak = p.getInt('streak') ?? 0;
    lastOpenDay = p.getString('lastOpenDay');
    _decode(p.getString('verdicts'), (k, v) => verdicts[k] = v as bool);
    _decode(p.getString('written'), (k, v) => written[k] = v as String);
    await _touchStreak(p);
  }

  void _decode(String? raw, void Function(String, dynamic) put) {
    if (raw == null) return;
    try {
      (jsonDecode(raw) as Map<String, dynamic>).forEach(put);
    } catch (_) {}
  }

  /// A streak with one forgiven day per gap. Losing 200 days because of one
  /// missed evening is a punishment, and punished users delete the app.
  Future<void> _touchStreak(SharedPreferences p) async {
    final today = _dayKey(DateTime.now());
    if (lastOpenDay == today) return;
    final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
    final dayBefore = _dayKey(DateTime.now().subtract(const Duration(days: 2)));
    if (lastOpenDay == yesterday || lastOpenDay == dayBefore) {
      streak += 1;
    } else {
      streak = 1;
    }
    lastOpenDay = today;
    await p.setInt('streak', streak);
    await p.setString('lastOpenDay', today);
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('favourites', favourites.toList());
    await p.setStringList('seen', seen.take(2000).toList());
    await p.setInt('points', points);
    await p.setInt('laughs', laughsCaused);
    await p.setString('verdicts', jsonEncode(verdicts));
    await p.setString('written', jsonEncode(written));
  }

  bool isFavourite(String id) => favourites.contains(id);

  Future<void> toggleFavourite(String id) async {
    favourites.contains(id) ? favourites.remove(id) : favourites.add(id);
    await _save();
  }

  /// Fifty a day, reachable in five minutes. Past that you play for fun.
  /// Without a cap you manufacture compulsive users who end up resenting you.
  static const dailyCap = 50;

  Future<void> award(int n) async {
    points += n;
    await _save();
  }

  Future<void> recordVerdict(String jokeId, bool funny) async {
    verdicts[jokeId] = funny;
    seen.add(jokeId);
    points += 2;
    await _save();
  }

  Future<void> recordWritten(String jokeId, String text) async {
    written[jokeId] = text;
    points += 5;
    await _save();
  }

  Future<void> recordLaugh() async {
    laughsCaused += 1;
    points += 10;
    await _save();
  }

  /// Your own approval rate — honest wording matters here. Until there is a
  /// server this is your history, not a national percentage.
  int get approvalRate {
    if (verdicts.isEmpty) return 0;
    final yes = verdicts.values.where((v) => v).length;
    return (yes * 100 / verdicts.length).round();
  }
}
