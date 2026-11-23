import 'dart:convert';

import 'cocktail.dart';
import 'ingredient.dart';

/// Catálogo fixo de ingredientes e receitas que acompanha o app.
class Catalog {
  Catalog({required List<Ingredient> ingredients, required this.cocktails})
    : ingredients = List.unmodifiable(ingredients),
      _ingredientsById = {for (final i in ingredients) i.id: i};

  factory Catalog.fromJsonString(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return Catalog(
      ingredients: (json['ingredientes'] as List)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      cocktails: (json['coqueteis'] as List)
          .map((e) => Cocktail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<Ingredient> ingredients;
  final List<Cocktail> cocktails;
  final Map<String, Ingredient> _ingredientsById;

  Ingredient? ingredientById(String id) => _ingredientsById[id];

  Cocktail? cocktailById(String id) {
    for (final c in cocktails) {
      if (c.id == id) return c;
    }
    return null;
  }
}
