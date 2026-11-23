import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cocktail.dart';

/// Guarda no aparelho o que é do usuário: o bar, os favoritos, a lista de
/// compras e as receitas criadas por ele (ou geradas por IA e salvas).
class UserDataStore {
  UserDataStore(this._prefs);

  static Future<UserDataStore> open() async =>
      UserDataStore(await SharedPreferences.getInstance());

  static const _ownedKey = 'ingredientes_no_bar';
  static const _favoritesKey = 'coqueteis_favoritos';
  static const _shoppingKey = 'lista_de_compras';
  static const _recipesKey = 'receitas_do_usuario';

  final SharedPreferences _prefs;

  Set<String> readOwned() => _read(_ownedKey);
  Set<String> readFavorites() => _read(_favoritesKey);
  Set<String> readShopping() => _read(_shoppingKey);

  Future<void> saveOwned(Set<String> ids) => _save(_ownedKey, ids);
  Future<void> saveFavorites(Set<String> ids) => _save(_favoritesKey, ids);
  Future<void> saveShopping(Set<String> ids) => _save(_shoppingKey, ids);

  List<Cocktail> readRecipes() {
    final raw = _prefs.getString(_recipesKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Cocktail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveRecipes(List<Cocktail> recipes) => _prefs.setString(
    _recipesKey,
    jsonEncode(recipes.map((r) => r.toJson()).toList()),
  );

  Set<String> _read(String key) =>
      (_prefs.getStringList(key) ?? const []).toSet();

  Future<void> _save(String key, Set<String> ids) =>
      _prefs.setStringList(key, ids.toList()..sort());
}
