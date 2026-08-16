import 'dart:convert';
import 'package:http/http.dart' as http;

/// Recipes from TheMealDB — free, no key, no quota to babysit.
/// The catalogue is English-only; that is a real limitation for the other
/// three languages and the reason to move to our own recipes later.
class Recipe {
  final String id;
  final String name;
  final String area;
  final String category;
  final String? thumb;
  final String instructions;
  final List<String> ingredients;
  final String? youtube;

  const Recipe({
    required this.id,
    required this.name,
    required this.area,
    required this.category,
    required this.instructions,
    required this.ingredients,
    this.thumb,
    this.youtube,
  });

  factory Recipe.fromJson(Map<String, dynamic> j) {
    final items = <String>[];
    for (var i = 1; i <= 20; i++) {
      final ing = (j['strIngredient$i'] ?? '').toString().trim();
      final measure = (j['strMeasure$i'] ?? '').toString().trim();
      if (ing.isEmpty) continue;
      items.add(measure.isEmpty ? ing : '$measure $ing');
    }
    return Recipe(
      id: j['idMeal'] as String,
      name: (j['strMeal'] ?? '') as String,
      area: (j['strArea'] ?? '') as String,
      category: (j['strCategory'] ?? '') as String,
      thumb: j['strMealThumb'] as String?,
      instructions: ((j['strInstructions'] ?? '') as String).trim(),
      ingredients: items,
      youtube: (j['strYoutube'] as String?)?.isEmpty ?? true
          ? null
          : j['strYoutube'] as String,
    );
  }
}

class CookRepository {
  CookRepository._();
  static final instance = CookRepository._();

  static const base = 'https://www.themealdb.com/api/json/v1/1';

  static const areas = <String>[
    'American', 'British', 'Chinese', 'Egyptian', 'French', 'Greek',
    'Indian', 'Italian', 'Japanese', 'Mexican', 'Moroccan', 'Spanish',
    'Thai', 'Tunisian', 'Turkish', 'Vietnamese',
  ];

  final _byArea = <String, List<Recipe>>{};
  final _details = <String, Recipe>{};

  Future<List<Recipe>> byArea(String area) async {
    if (_byArea.containsKey(area)) return _byArea[area]!;
    try {
      final res = await http
          .get(Uri.parse('$base/filter.php?a=$area'))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return const [];
      final meals = (jsonDecode(res.body)['meals'] as List?) ?? const [];
      return _byArea[area] = meals
          .map((m) => Recipe(
                id: m['idMeal'] as String,
                name: m['strMeal'] as String,
                area: area,
                category: '',
                thumb: m['strMealThumb'] as String?,
                instructions: '',
                ingredients: const [],
              ))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// The list endpoint returns names only, so the full recipe is a second
  /// call made once the user actually opens one.
  Future<Recipe?> detail(String id) async {
    if (_details.containsKey(id)) return _details[id];
    try {
      final res = await http
          .get(Uri.parse('$base/lookup.php?i=$id'))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final meals = (jsonDecode(res.body)['meals'] as List?) ?? const [];
      if (meals.isEmpty) return null;
      return _details[id] = Recipe.fromJson(meals.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
