import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Entry {
  final String id;
  final String text;
  final String? jokeId;
  final DateTime at;
  const Entry({required this.id, required this.text, required this.at, this.jokeId});

  Map<String, dynamic> toJson() =>
      {'id': id, 'text': text, 'jokeId': jokeId, 'at': at.toIso8601String()};

  factory Entry.fromJson(Map<String, dynamic> j) => Entry(
        id: j['id'] as String,
        text: j['text'] as String,
        jokeId: j['jokeId'] as String?,
        at: DateTime.parse(j['at'] as String),
      );
}

class JournalRepository {
  JournalRepository._();
  static final instance = JournalRepository._();

  final List<Entry> entries = [];

  /// A place where people vent will, sooner or later, attract someone in real
  /// distress. Answering that with a joke would be cruel and would rightly get
  /// the app reported. When any of these appear we drop the humour entirely
  /// and offer help instead. Erring wide costs nothing.
  static const _redFlags = <String>[
    'kill myself', 'end my life', 'suicide', 'suicidal', 'want to die',
    'better off dead', 'self harm', 'self-harm', 'cut myself', 'hurt myself',
    'no reason to live', 'cant go on', "can't go on", 'give up on life',
    'me suicider', 'me tuer', 'envie de mourir', 'plus envie de vivre',
    'suicidarme', 'quiero morir', 'matarme',
    'انتحار', 'اقتل نفسي', 'أريد الموت',
  ];

  static bool needsSupport(String text) {
    final t = text.toLowerCase();
    return _redFlags.any(t.contains);
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('journal');
    if (raw == null) return;
    try {
      entries
        ..clear()
        ..addAll((jsonDecode(raw) as List)
            .map((e) => Entry.fromJson(e as Map<String, dynamic>)));
    } catch (_) {}
  }

  Future<Entry> add(String text, String? jokeId) async {
    final e = Entry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text.trim(),
      jokeId: jokeId,
      at: DateTime.now(),
    );
    entries.insert(0, e);
    final p = await SharedPreferences.getInstance();
    await p.setString('journal', jsonEncode(entries.map((x) => x.toJson()).toList()));
    return e;
  }

  Future<void> remove(String id) async {
    entries.removeWhere((e) => e.id == id);
    final p = await SharedPreferences.getInstance();
    await p.setString('journal', jsonEncode(entries.map((x) => x.toJson()).toList()));
  }
}
