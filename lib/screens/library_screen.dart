import 'package:flutter/material.dart';
import '../data/joke_repository.dart';
import '../data/profile_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/joke_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _repo = JokeRepository.instance;
  final _search = TextEditingController();
  String _category = 'all';
  bool _favouritesOnly = false;
  bool _allowAdult = false;

  static const _labels = {
    'all': 'All', 'work': 'Work', 'marriage': 'Marriage', 'money': 'Money',
    'medical': 'Doctors', 'bar': 'Bar', 'animals': 'Animals', 'kids': 'Kids',
    'tech': 'Tech', 'misc': 'Mixed',
  };

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Joke> get _results {
    var list = _repo.byCategory(_category, allowAdult: _allowAdult);
    if (_favouritesOnly) {
      list = list.where((j) => Profile.instance.isFavourite(j.id)).toList();
    }
    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((j) =>
              j.setup.toLowerCase().contains(q) ||
              j.punchline.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final results = _results;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(T.s4, T.s4, T.s4, T.s3),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 15, color: T.ink),
            decoration: InputDecoration(
              hintText: s('searchJokes'),
              hintStyle: const TextStyle(fontSize: 15, color: T.faint),
              prefixIcon: const Icon(Icons.search, size: 20, color: T.faint),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18, color: T.faint),
                      onPressed: () => setState(() => _search.clear()),
                    ),
              filled: true,
              fillColor: T.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              border: _outline(T.border),
              enabledBorder: _outline(T.border),
              focusedBorder: _outline(T.coral),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: T.s4),
            children: [
              _chip(
                label: s('favourites'),
                selected: _favouritesOnly,
                color: T.rose,
                onTap: () =>
                    setState(() => _favouritesOnly = !_favouritesOnly),
              ),
              for (final c in _repo.categories)
                _chip(
                  label: c == 'all' ? s('all') : (_labels[c] ?? c),
                  selected: _category == c,
                  color: c == 'all' ? T.ink : T.forCategory(c),
                  onTap: () => setState(() => _category = c),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(T.s4, T.s3, T.s4, 0),
          child: Row(
            children: [
              Expanded(
                child: Text('${results.length} ${s('punchlines')}',
                    style: const TextStyle(fontSize: 12.5, color: T.muted)),
              ),
              Text(s('adult'),
                  style: const TextStyle(fontSize: 12.5, color: T.muted)),
              Switch(
                value: _allowAdult,
                onChanged: (v) => setState(() => _allowAdult = v),
                activeThumbColor: Colors.white,
                activeTrackColor: T.coral,
              ),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(T.s6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s('nothingFound'),
                            style: AppType.punchline(size: 18)),
                        const SizedBox(height: T.s2),
                        Text(s('tryAnother'),
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(fontSize: 14, color: T.muted)),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(T.s4),
                  itemCount: results.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: T.s3),
                    child: JokeCard(
                      key: ValueKey(results[i].id),
                      joke: results[i],
                      onChanged: () => setState(() {}),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  OutlineInputBorder _outline(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(T.rControl),
        borderSide: BorderSide(color: c, width: 1),
      );

  Widget _chip({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) =>
      Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: T.s3 + 2),
            decoration: BoxDecoration(
              color: selected ? color : T.surface,
              border: Border.all(
                  color: selected ? color : T.border, width: 1),
              borderRadius: BorderRadius.circular(T.rPill),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? Colors.white : T.muted)),
          ),
        ),
      );
}
