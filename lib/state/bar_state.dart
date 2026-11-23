import 'package:flutter/foundation.dart';

import '../data/user_data_store.dart';
import '../models/catalog.dart';
import '../models/cocktail.dart';
import '../models/cocktail_match.dart';
import '../models/ingredient.dart';

/// Estado do app: catálogo + o que o usuário tem, favoritou e precisa comprar.
class BarState extends ChangeNotifier {
  BarState({required this.catalog, required UserDataStore store})
    : _store = store,
      _owned = _onlyKnown(store.readOwned(), catalog.ingredientById),
      _shopping = _onlyKnown(store.readShopping(), catalog.ingredientById),
      _userRecipes = store.readRecipes(),
      _favorites = store.readFavorites() {
    _favorites.removeWhere((id) => cocktailById(id) == null);
    _recompute();
  }

  final Catalog catalog;
  final UserDataStore _store;

  final Set<String> _owned;
  final Set<String> _favorites;
  final Set<String> _shopping;
  final List<Cocktail> _userRecipes;

  List<CocktailMatch> _matches = const [];

  Set<String> get owned => Set.unmodifiable(_owned);
  Set<String> get favorites => Set.unmodifiable(_favorites);
  Set<String> get shopping => Set.unmodifiable(_shopping);

  bool hasIngredient(String id) => _owned.contains(id);
  bool isFavorite(String cocktailId) => _favorites.contains(cocktailId);
  bool isInShoppingList(String ingredientId) =>
      _shopping.contains(ingredientId);

  /// Receitas do catálogo + as criadas pelo usuário.
  List<Cocktail> get allCocktails => [...catalog.cocktails, ..._userRecipes];

  List<Cocktail> get userRecipes => List.unmodifiable(_userRecipes);

  Cocktail? cocktailById(String id) {
    for (final c in _userRecipes) {
      if (c.id == id) return c;
    }
    return catalog.cocktailById(id);
  }

  /// Destilados que aparecem em pelo menos uma receita, para o filtro por base.
  List<Ingredient> get baseSpirits {
    final used = {
      for (final c in allCocktails) ...c.items.map((i) => i.ingredientId),
    };
    return catalog.ingredients
        .where(
          (i) =>
              i.category == IngredientCategory.destilados &&
              used.contains(i.id),
        )
        .toList();
  }

  /// Todos os coquetéis, do mais fácil de fazer (menos faltando) ao mais difícil.
  List<CocktailMatch> get matches => _matches;

  List<CocktailMatch> get canMake => _matches.where((m) => m.canMake).toList();
  List<CocktailMatch> get almost => _matches.where((m) => m.isAlmost).toList();

  List<CocktailMatch> get favoriteMatches =>
      _matches.where((m) => _favorites.contains(m.cocktail.id)).toList();

  CocktailMatch matchFor(Cocktail cocktail) =>
      CocktailMatch.evaluate(cocktail, _owned);

  /// Nome de um ingrediente para mostrar na tela.
  String ingredientName(String id) => catalog.ingredientById(id)?.name ?? id;

  List<Ingredient> get shoppingIngredients =>
      _shopping.map(catalog.ingredientById).whereType<Ingredient>().toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  /// Quantos coquetéis a mais ficam possíveis se o usuário comprar este ingrediente.
  int unlocksIfBought(String ingredientId) => _matches
      .where(
        (m) => m.missingIds.length == 1 && m.missingIds.first == ingredientId,
      )
      .length;

  void toggleIngredient(String id) {
    if (!_owned.remove(id)) {
      _owned.add(id);
      _shopping.remove(id);
      _store.saveShopping(_shopping);
    }
    _store.saveOwned(_owned);
    _recompute();
    notifyListeners();
  }

  void toggleFavorite(String cocktailId) {
    if (!_favorites.remove(cocktailId)) _favorites.add(cocktailId);
    _store.saveFavorites(_favorites);
    notifyListeners();
  }

  void addToShopping(Iterable<String> ingredientIds) {
    _shopping.addAll(ingredientIds.where((id) => !_owned.contains(id)));
    _store.saveShopping(_shopping);
    notifyListeners();
  }

  void removeFromShopping(String ingredientId) {
    _shopping.remove(ingredientId);
    _store.saveShopping(_shopping);
    notifyListeners();
  }

  /// Marca um item da lista de compras como comprado: sai da lista e vai para o bar.
  void markBought(String ingredientId) {
    _shopping.remove(ingredientId);
    _owned.add(ingredientId);
    _store.saveShopping(_shopping);
    _store.saveOwned(_owned);
    _recompute();
    notifyListeners();
  }

  /// Cria ou atualiza uma receita do usuário (mesmo id = atualiza).
  void saveRecipe(Cocktail recipe) {
    final index = _userRecipes.indexWhere((r) => r.id == recipe.id);
    if (index >= 0) {
      _userRecipes[index] = recipe;
    } else {
      _userRecipes.add(recipe);
    }
    _store.saveRecipes(_userRecipes);
    _recompute();
    notifyListeners();
  }

  void deleteRecipe(String id) {
    _userRecipes.removeWhere((r) => r.id == id);
    _favorites.remove(id);
    _store.saveRecipes(_userRecipes);
    _store.saveFavorites(_favorites);
    _recompute();
    notifyListeners();
  }

  void clearShopping() {
    _shopping.clear();
    _store.saveShopping(_shopping);
    notifyListeners();
  }

  void _recompute() {
    _matches =
        allCocktails.map((c) => CocktailMatch.evaluate(c, _owned)).toList()
          ..sort((a, b) {
            final byMissing = a.missingIds.length.compareTo(
              b.missingIds.length,
            );
            return byMissing != 0
                ? byMissing
                : a.cocktail.name.compareTo(b.cocktail.name);
          });
  }

  /// Ignora ids salvos que não existem mais no catálogo (ex.: receita removida).
  static Set<String> _onlyKnown(
    Set<String> ids,
    Object? Function(String) lookup,
  ) => ids.where((id) => lookup(id) != null).toSet();
}
