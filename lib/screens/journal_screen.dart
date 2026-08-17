import 'package:flutter/material.dart';
import '../data/joke_repository.dart';
import '../data/journal_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Vent, and get a punchline back. No mood score, no chart, no streak —
/// the moment we start measuring how someone feels, we become a health app
/// with all the duties that carries. This stays a place to let off steam.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _controller = TextEditingController();
  final _repo = JournalRepository.instance;
  Joke? _reply;
  bool _support = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (JournalRepository.needsSupport(text)) {
      setState(() {
        _support = true;
        _reply = null;
      });
      await _repo.add(text, null);
      _controller.clear();
      return;
    }

    final joke = _matching(text);
    await _repo.add(text, joke?.id);
    setState(() {
      _support = false;
      _reply = joke;
      _controller.clear();
    });
  }

  /// Same clustering idea as everywhere else: significant words in, matching
  /// category out, then the joke of the day from that category.
  Joke? _matching(String text) {
    const themes = <String, List<String>>{
      'work': ['boss', 'work', 'job', 'office', 'meeting', 'colleague',
        'manager', 'shift', 'email', 'overtime', 'patron', 'travail', 'bureau'],
      'money': ['money', 'rent', 'bill', 'bank', 'broke', 'price', 'expensive',
        'tax', 'argent', 'facture', 'loyer'],
      'marriage': ['wife', 'husband', 'partner', 'family', 'mother', 'father',
        'kids', 'famille', 'femme', 'mari'],
      'medical': ['doctor', 'hospital', 'sick', 'pain', 'tired', 'medecin',
        'malade', 'fatigue'],
      'tech': ['phone', 'wifi', 'internet', 'computer', 'app', 'password',
        'ordinateur', 'reseau'],
    };
    final t = text.toLowerCase();
    var best = '';
    var score = 0;
    themes.forEach((k, words) {
      final n = words.where(t.contains).length;
      if (n > score) {
        score = n;
        best = k;
      }
    });
    final repo = JokeRepository.instance;
    final pool = score == 0 ? repo.byCategory('all') : repo.byCategory(best);
    return pool.isEmpty ? null : (pool..shuffle()).first;
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);

    return ListView(
      padding: const EdgeInsets.all(T.s4),
      children: [
        Text(s('journal'), style: AppType.display(T.ink, size: 30)),
        const SizedBox(height: T.s2),
        Text(s('journalPrompt'),
            style: const TextStyle(fontSize: 14, height: 1.5, color: T.muted)),
        const SizedBox(height: T.s4),
        TextField(
          controller: _controller,
          maxLines: 4,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 16, height: 1.5, color: T.ink),
          decoration: InputDecoration(
            hintText: s('journalHint'),
            hintStyle: const TextStyle(fontSize: 15, color: T.faint),
            filled: true,
            fillColor: T.surface,
            contentPadding: const EdgeInsets.all(T.s4),
            border: _outline(T.border),
            enabledBorder: _outline(T.border),
            focusedBorder: _outline(T.sky),
          ),
        ),
        const SizedBox(height: T.s3),
        GestureDetector(
          onTap: _submit,
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: T.sky,
              borderRadius: BorderRadius.circular(T.rControl),
            ),
            child: Text(s('letItOut'),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ),
        if (_support) ...[
          const SizedBox(height: T.s4),
          _supportCard(s),
        ] else if (_reply != null) ...[
          const SizedBox(height: T.s4),
          _replyCard(s, _reply!),
        ],
        if (_repo.entries.isNotEmpty) ...[
          const SizedBox(height: T.s5),
          Text(s('yourEntries'), style: AppType.eyebrow(T.faint)),
          const SizedBox(height: T.s2),
          for (final e in _repo.entries.take(30))
            Dismissible(
              key: ValueKey(e.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsetsDirectional.only(end: T.s4),
                child: const Icon(Icons.delete_outline,
                    size: 20, color: T.coral),
              ),
              onDismissed: (_) async {
                await _repo.remove(e.id);
                if (mounted) setState(() {});
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: T.s2),
                padding: const EdgeInsets.all(T.s4),
                decoration: BoxDecoration(
                  color: T.surface,
                  border: Border.all(color: T.border, width: 1),
                  borderRadius: BorderRadius.circular(T.rCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.text,
                        style: const TextStyle(
                            fontSize: 14.5, height: 1.5, color: T.ink)),
                    const SizedBox(height: 6),
                    Text(_when(e.at),
                        style: const TextStyle(fontSize: 11, color: T.faint)),
                  ],
                ),
              ),
            ),
        ],
        const SizedBox(height: T.s6),
      ],
    );
  }

  Widget _replyCard(S s, Joke joke) {
    final accent = T.forCategory(joke.category);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: T.tint(accent),
        border: Border.all(color: accent.withValues(alpha: 0.28), width: 1),
        borderRadius: BorderRadius.circular(T.rCard),
      ),
      padding: const EdgeInsets.all(T.s4 + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s('onThatNote'), style: AppType.eyebrow(accent)),
          const SizedBox(height: T.s3),
          Text(joke.setup, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: T.s3),
          Text(joke.punchline, style: AppType.punchline(size: 18)),
        ],
      ),
    );
  }

  /// No joke here, ever. Just a plain sentence and a way to reach someone.
  Widget _supportCard(S s) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: T.surface,
          border: Border.all(color: T.sky, width: 1.5),
          borderRadius: BorderRadius.circular(T.rCard),
        ),
        padding: const EdgeInsets.all(T.s4 + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s('supportTitle'), style: AppType.punchline(size: 17)),
            const SizedBox(height: T.s2),
            Text(s('supportBody'),
                style: const TextStyle(
                    fontSize: 14.5, height: 1.6, color: T.ink)),
          ],
        ),
      );

  OutlineInputBorder _outline(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(T.rCard),
        borderSide: BorderSide(color: c, width: 1),
      );

  static String _when(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} d';
  }
}
