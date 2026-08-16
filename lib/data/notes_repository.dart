import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Note {
  final String id;
  final String text;
  final bool done;
  final DateTime createdAt;

  const Note({
    required this.id,
    required this.text,
    required this.done,
    required this.createdAt,
  });

  Note copyWith({String? text, bool? done}) => Note(
        id: id,
        text: text ?? this.text,
        done: done ?? this.done,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'done': done,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'] as String,
        text: j['text'] as String,
        done: j['done'] as bool,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

/// Notes live only on the device. Nothing to sync, nothing to leak, and the
/// list survives reinstalling nothing — which is the honest trade for now.
class NotesRepository {
  NotesRepository._();
  static final instance = NotesRepository._();

  static const _key = 'notes';
  List<Note> _notes = [];

  List<Note> get all => List.unmodifiable(_notes);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      _notes = (jsonDecode(raw) as List)
          .map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _notes = [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_notes.map((n) => n.toJson()).toList()));
  }

  Future<void> add(String text) async {
    if (text.trim().isEmpty) return;
    _notes.insert(
      0,
      Note(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text.trim(),
        done: false,
        createdAt: DateTime.now(),
      ),
    );
    await _save();
  }

  Future<void> toggle(String id) async {
    _notes = _notes
        .map((n) => n.id == id ? n.copyWith(done: !n.done) : n)
        .toList();
    await _save();
  }

  Future<void> remove(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _save();
  }
}
