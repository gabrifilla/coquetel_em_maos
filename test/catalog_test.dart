import 'dart:io';

import 'package:coquetel_em_maos/data/catalog_loader.dart';
import 'package:coquetel_em_maos/models/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Catalog catalog;

  setUpAll(() {
    catalog = Catalog.fromJsonString(File(catalogAssetPath).readAsStringSync());
  });

  test('ids de ingredientes e coquetéis são únicos', () {
    final ingredientIds = catalog.ingredients.map((i) => i.id).toList();
    final cocktailIds = catalog.cocktails.map((c) => c.id).toList();
    expect(ingredientIds.toSet().length, ingredientIds.length);
    expect(cocktailIds.toSet().length, cocktailIds.length);
  });

  test('toda receita usa apenas ingredientes do catálogo', () {
    for (final cocktail in catalog.cocktails) {
      for (final item in cocktail.items) {
        expect(
          catalog.ingredientById(item.ingredientId),
          isNotNull,
          reason: '${cocktail.id} usa ${item.ingredientId}, que não existe',
        );
      }
    }
  });

  test('toda receita tem ingrediente obrigatório e modo de preparo', () {
    for (final cocktail in catalog.cocktails) {
      expect(cocktail.requiredItems, isNotEmpty, reason: cocktail.id);
      expect(cocktail.steps, isNotEmpty, reason: cocktail.id);
    }
  });

  test('todo ingrediente é usado por pelo menos uma receita', () {
    final used = {
      for (final c in catalog.cocktails) ...c.items.map((i) => i.ingredientId),
    };
    final unused = catalog.ingredients
        .map((i) => i.id)
        .where((id) => !used.contains(id));
    expect(unused, isEmpty);
  });
}
