import 'package:flutter/material.dart';
import '../data/joke_repository.dart';
import '../data/profile_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/joke_card.dart';

/// The Museum. Not a list — wings, each with a curator's label.
///
/// The collections are built from what the visitor has actually done, so the
/// building fills up as they play. An empty wing is shown with its condition
/// rather than hidden: knowing what earns you a room is the invitation.
class MuseumGame extends StatefulWidget {
  const MuseumGame({super.key});

  @override
  State<MuseumGame> createState() => _MuseumGameState();
}

class _MuseumGameState extends State<MuseumGame> {
  int _wing = 0;

  List<Joke> _collection(int index) {
    final repo = JokeRepository.instance;
    final p = Profile.instance;
    final all = repo.byCategory('all', allowAdult: true);
    switch (index) {
      case 0: // acquired: your favourites
        return all.where((j) => p.isFavourite(j.id)).toList();
      case 1: // convicted: judged funny
        return all.where((j) => p.verdicts[j.id] == true).toList();
      case 2: // the vault: acquitted, kept for the record
        return all.where((j) => p.verdicts[j.id] == false).toList();
      case 3: // miniatures: the shortest in the collection
        final sorted = [...all]
          ..sort((a, b) =>
              (a.setup.length + a.punchline.length)
                  .compareTo(b.setup.length + b.punchline.length));
        return sorted.take(20).toList();
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final wings = [
      (s('wingFavourites'), s('wingFavouritesHow'), T.decoder),
      (s('wingConvicted'), s('wingConvictedHow'), T.arena),
      (s('wingVault'), s('wingVaultHow'), T.dim),
      (s('wingMiniatures'), s('wingMiniaturesHow'), T.museum),
    ];
    final items = _collection(_wing);
    final (title, how, colour) = wings[_wing];

    return Scaffold(
      appBar: AppBar(title: Text(s('roomMuseum'))),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: T.s4),
              itemCount: wings.length,
              itemBuilder: (context, i) {
                final selected = i == _wing;
                final c = wings[i].$3;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8, top: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _wing = i),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: selected
                            ? c.withValues(alpha: 0.18)
                            : Colors.transparent,
                        border: Border.all(
                            color: selected ? c : T.line, width: 1),
                        borderRadius: BorderRadius.circular(T.rPill),
                      ),
                      child: Text(wings[i].$1,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: selected ? c : T.dim)),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(T.s6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s('emptyWing'),
                              style: AppType.punchline(size: 18)),
                          const SizedBox(height: T.s3),
                          Text(how,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 14, height: 1.5, color: T.dim)),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(T.s4),
                    itemCount: items.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: T.s3),
                          child: Text(
                              '$title  ·  ${items.length}',
                              style: AppType.tag(colour)),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: T.s3),
                        child: JokeCard(
                          key: ValueKey(items[i - 1].id),
                          joke: items[i - 1],
                          onChanged: () => setState(() {}),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
