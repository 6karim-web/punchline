import 'package:flutter/material.dart';
import '../data/cook_repository.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/feed_states.dart';

class CookScreen extends StatefulWidget {
  const CookScreen({super.key});

  @override
  State<CookScreen> createState() => _CookScreenState();
}

class _CookScreenState extends State<CookScreen> {
  String _area = 'American';
  late Future<List<Recipe>> _recipes;

  @override
  void initState() {
    super.initState();
    _recipes = CookRepository.instance.byArea(_area);
  }

  void _pick(String area) {
    setState(() {
      _area = area;
      _recipes = CookRepository.instance.byArea(area);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    return Scaffold(
      appBar: AppBar(
        title: Text(s('cook')),
        shape: const Border(bottom: BorderSide(color: T.border, width: 0.5)),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: T.s3),
              children: [
                for (final a in CookRepository.areas)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 7, top: 8),
                    child: GestureDetector(
                      onTap: () => _pick(a),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: T.s3, vertical: 6),
                        decoration: BoxDecoration(
                          color: _area == a ? T.saffron : Colors.transparent,
                          border: Border.all(
                              color: _area == a ? T.saffron : T.borderSoft,
                              width: 0.5),
                          borderRadius: BorderRadius.circular(T.rPill),
                        ),
                        child: Text(a,
                            style: TextStyle(
                                fontSize: 12,
                                color: _area == a ? T.canvas : T.textMuted)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: _recipes,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Loading(label: s('cook'));
                }
                final list = snap.data ?? const <Recipe>[];
                if (list.isEmpty) {
                  return Center(
                      child: Text(s('nothingHere'),
                          style: const TextStyle(
                              fontSize: 14, color: T.textMuted)));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(T.s3),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: T.s3,
                    mainAxisSpacing: T.s3,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, i) => _tile(list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(Recipe r) => GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => RecipeScreen(id: r.id, name: r.name)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(T.rCard),
                child: r.thumb == null
                    ? Container(color: T.card)
                    : Image.network(r.thumb!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: T.card)),
              ),
            ),
            const SizedBox(height: T.s2),
            Text(r.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, height: 1.35, color: T.text)),
          ],
        ),
      );
}

class RecipeScreen extends StatelessWidget {
  final String id;
  final String name;
  const RecipeScreen({super.key, required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    final s = S(AppState.instance.locale);
    return Scaffold(
      appBar: AppBar(
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        shape: const Border(bottom: BorderSide(color: T.border, width: 0.5)),
      ),
      body: FutureBuilder<Recipe?>(
        future: CookRepository.instance.detail(id),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Loading(label: s('cook'));
          }
          final r = snap.data;
          if (r == null) {
            return Center(
                child: Text(s('nothingHere'),
                    style: const TextStyle(fontSize: 14, color: T.textMuted)));
          }
          return ListView(
            padding: const EdgeInsets.all(T.s3),
            children: [
              if (r.thumb != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(T.rCard),
                  child: Image.network(r.thumb!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),
              const SizedBox(height: T.s4),
              _label(s('ingredients')),
              for (final i in r.ingredients)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 6),
                  child: Text('\u2022  $i',
                      style: const TextStyle(
                          fontSize: 14, height: 1.45, color: T.text)),
                ),
              const SizedBox(height: T.s4),
              _label(s('steps')),
              Text(r.instructions,
                  style: const TextStyle(
                      fontSize: 15, height: 1.6, color: T.text)),
              const SizedBox(height: T.s5),
            ],
          );
        },
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsetsDirectional.only(bottom: T.s2),
        child: Text(t,
            style: const TextStyle(
                fontSize: 11, letterSpacing: 0.9, color: T.saffron)),
      );
}
