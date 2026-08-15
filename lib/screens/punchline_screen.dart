import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/joke_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/punchline_card.dart';

class PunchlineScreen extends StatefulWidget {
  const PunchlineScreen({super.key});

  @override
  State<PunchlineScreen> createState() => _PunchlineScreenState();
}

class _PunchlineScreenState extends State<PunchlineScreen> {
  final _repo = JokeRepository.instance;
  String _category = 'all';
  bool _allowAdult = false;

  static const _labels = {
    'all': 'all',
    'work': 'Work',
    'marriage': 'Marriage',
    'money': 'Money',
    'medical': 'Doctors',
    'bar': 'Bar',
    'animals': 'Animals',
    'kids': 'Kids',
    'tech': 'Tech',
    'misc': 'Mixed',
  };

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final jokes = _repo.byCategory(_category, allowAdult: _allowAdult);

    return ListView.builder(
      padding: const EdgeInsets.all(T.s3),
      itemCount: jokes.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) return _header(context, jokes.length, s);
        final j = jokes[i - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: T.s3),
          child: PunchlineCard(
            joke: j,
            eyebrow: (_labels[j.category] ?? j.category).toUpperCase(),
            onShare: () => Share.share(j.shareText),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, int count, S s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final c in _repo.categories)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 7),
                  child: _Chip(
                    label: c == 'all' ? s('all') : (_labels[c] ?? c),
                    selected: _category == c,
                    onTap: () => setState(() => _category = c),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: T.s3),
        Row(
          children: [
            Expanded(
              child: Text('$count ${s('punchlines')}',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
            Text(s('adult'), style: Theme.of(context).textTheme.bodySmall),
            Switch(
              value: _allowAdult,
              onChanged: (v) => setState(() => _allowAdult = v),
              activeThumbColor: T.canvas,
              activeTrackColor: T.saffron,
              inactiveThumbColor: T.textMuted,
              inactiveTrackColor: T.card,
            ),
          ],
        ),
        const SizedBox(height: T.s2),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: T.s3, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? T.saffron : Colors.transparent,
            border: Border.all(
                color: selected ? T.saffron : T.borderSoft, width: 0.5),
            borderRadius: BorderRadius.circular(T.rPill),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12, color: selected ? T.canvas : T.textMuted)),
        ),
      );
}
