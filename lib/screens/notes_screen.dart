import 'package:flutter/material.dart';
import '../data/notes_repository.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _repo = NotesRepository.instance;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    await _repo.add(text);
    _controller.clear();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    final notes = _repo.all;

    return Scaffold(
      appBar: AppBar(
        title: Text(s('notes')),
        shape: const Border(bottom: BorderSide(color: T.border, width: 0.5)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(T.s3),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 15, color: T.text),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _add(),
                    decoration: InputDecoration(
                      hintText: s('addNote'),
                      hintStyle:
                          const TextStyle(fontSize: 15, color: T.textFaint),
                      filled: true,
                      fillColor: T.card,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: T.s4, vertical: T.s3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(T.rControl),
                        borderSide:
                            const BorderSide(color: T.border, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(T.rControl),
                        borderSide:
                            const BorderSide(color: T.border, width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(T.rControl),
                        borderSide:
                            const BorderSide(color: T.saffron, width: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: T.s2),
                IconButton(
                  onPressed: _add,
                  icon: const Icon(Icons.add, color: T.canvas),
                  style: IconButton.styleFrom(backgroundColor: T.saffron),
                ),
              ],
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Text(s('noNotes'),
                        style: const TextStyle(
                            fontSize: 14, color: T.textMuted)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: T.s3),
                    itemCount: notes.length,
                    itemBuilder: (context, i) {
                      final n = notes[i];
                      return Dismissible(
                        key: ValueKey(n.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: AlignmentDirectional.centerEnd,
                          padding:
                              const EdgeInsetsDirectional.only(end: T.s4),
                          child: const Icon(Icons.delete_outline,
                              color: T.down, size: 20),
                        ),
                        onDismissed: (_) async {
                          await _repo.remove(n.id);
                          if (mounted) setState(() {});
                        },
                        child: InkWell(
                          onTap: () async {
                            await _repo.toggle(n.id);
                            if (mounted) setState(() {});
                          },
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: T.s3),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: T.border, width: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  n.done
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  size: 20,
                                  color: n.done ? T.saffron : T.textFaint,
                                ),
                                const SizedBox(width: T.s3),
                                Expanded(
                                  child: Text(
                                    n.text,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.4,
                                      color: n.done ? T.textFaint : T.text,
                                      decoration: n.done
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: T.textFaint,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
