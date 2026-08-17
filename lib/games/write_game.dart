import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/joke_repository.dart';
import '../data/profile_repository.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Write the punchline. The one game where the player can be funny, which is
/// why it is the one that makes people come back and invite friends.
///
/// It is also the only game that CREATES content instead of consuming it:
/// every round adds a new ending to the collection.
class WriteGame extends StatefulWidget {
  const WriteGame({super.key});

  @override
  State<WriteGame> createState() => _WriteGameState();
}

class _WriteGameState extends State<WriteGame> {
  final _controller = TextEditingController();
  Joke? _joke;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _next();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    setState(() {
      _joke = JokeRepository.instance.next();
      _revealed = false;
      _controller.clear();
    });
  }

  Future<void> _reveal() async {
    if (_controller.text.trim().isEmpty || _joke == null) return;
    await Profile.instance.recordWritten(_joke!.id, _controller.text.trim());
    setState(() => _revealed = true);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final joke = _joke;
    final accent = joke == null ? T.violet : T.forCategory(joke.category);

    return Scaffold(
      appBar: AppBar(title: Text(s('writeGame'))),
      body: joke == null
          ? Center(child: Text(s('nothingHere')))
          : ListView(
              padding: const EdgeInsets.all(T.s4),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: T.tint(accent),
                    border: Border.all(
                        color: accent.withValues(alpha: 0.28), width: 1),
                    borderRadius: BorderRadius.circular(T.rCard),
                  ),
                  padding: const EdgeInsets.all(T.s5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s('yourTurn'), style: AppType.eyebrow(accent)),
                      const SizedBox(height: T.s3),
                      Text(joke.setup,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
                const SizedBox(height: T.s4),
                TextField(
                  controller: _controller,
                  enabled: !_revealed,
                  maxLines: 3,
                  minLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppType.punchline(size: 17),
                  decoration: InputDecoration(
                    hintText: s('writeYourEnding'),
                    hintStyle: const TextStyle(fontSize: 16, color: T.faint),
                    filled: true,
                    fillColor: T.surface,
                    contentPadding: const EdgeInsets.all(T.s4),
                    border: _outline(T.border),
                    enabledBorder: _outline(T.border),
                    focusedBorder: _outline(accent),
                    disabledBorder: _outline(T.borderSoft),
                  ),
                ),
                const SizedBox(height: T.s4),
                if (!_revealed)
                  _wide(s('showTheReal'), accent, _reveal)
                else ...[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: T.surface,
                      border: Border.all(color: T.border, width: 1),
                      borderRadius: BorderRadius.circular(T.rCard),
                    ),
                    padding: const EdgeInsets.all(T.s4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s('theOriginal'), style: AppType.eyebrow(T.faint)),
                        const SizedBox(height: T.s2),
                        Text(joke.punchline,
                            style: AppType.punchline(size: 18)),
                      ],
                    ),
                  ),
                  const SizedBox(height: T.s3),
                  Text(s('yoursIsBetter'),
                      style: const TextStyle(fontSize: 13, color: T.muted)),
                  const SizedBox(height: T.s4),
                  Row(
                    children: [
                      Expanded(
                        child: _wide(s('share'), accent, () {
                          Share.share(
                              '${joke.setup}\n\n${_controller.text.trim()}');
                        }),
                      ),
                      const SizedBox(width: T.s3),
                      Expanded(
                        child: _wide(s('nextOne'), T.muted, _next,
                            outlined: true),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: T.s5),
              ],
            ),
    );
  }

  OutlineInputBorder _outline(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(T.rCard),
        borderSide: BorderSide(color: c, width: 1),
      );

  Widget _wide(String label, Color color, VoidCallback onTap,
          {bool outlined = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color,
            border: outlined ? Border.all(color: T.border, width: 1) : null,
            borderRadius: BorderRadius.circular(T.rControl),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: outlined ? T.muted : Colors.white)),
        ),
      );
}
