import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../theme/tokens.dart';
import '../widgets/punchline_card.dart';

class PunchlineScreen extends StatefulWidget {
  const PunchlineScreen({super.key});

  @override
  State<PunchlineScreen> createState() => _PunchlineScreenState();
}

class _PunchlineScreenState extends State<PunchlineScreen> {
  static const _categories = ['All', 'Work', 'Marriage', 'Money', 'Animals'];
  String _selected = 'All';

  @override
  Widget build(BuildContext context) {
    final jokes = _selected == 'All'
        ? Sample.jokes
        : Sample.jokes
            .where((j) => j.category == _selected.toLowerCase())
            .toList();

    return ListView(
      padding: const EdgeInsets.all(T.s3),
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final c in _categories)
              GestureDetector(
                onTap: () => setState(() => _selected = c),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: T.s3, vertical: 5),
                  decoration: BoxDecoration(
                    color: _selected == c ? T.saffron : Colors.transparent,
                    border: Border.all(
                      color: _selected == c ? T.saffron : T.borderSoft,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(T.rPill),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      fontSize: 12,
                      color: _selected == c ? T.canvas : T.textMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: T.s3),
        if (jokes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: T.s6),
            child: Column(
              children: [
                const Text('No punchlines here yet',
                    style: TextStyle(fontSize: 16, color: T.text)),
                const SizedBox(height: T.s2),
                Text('Try another category.',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          )
        else
          for (final j in jokes) ...[
            PunchlineCard(joke: j, eyebrow: j.category.toUpperCase()),
            const SizedBox(height: T.s3),
          ],
      ],
    );
  }
}
