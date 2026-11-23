import 'package:shared_preferences/shared_preferences.dart';

/// Guarda no aparelho o que é do usuário: o bar, os favoritos e a lista de compras.
class UserDataStore {
  UserDataStore(this._prefs);

  static Future<UserDataStore> open() async =>
      UserDataStore(await SharedPreferences.getInstance());

  static const _ownedKey = 'ingredientes_no_bar';
  static const _favoritesKey = 'coqueteis_favoritos';
  static const _shoppingKey = 'lista_de_compras';

  final SharedPreferences _prefs;

  Set<String> readOwned() => _read(_ownedKey);
  Set<String> readFavorites() => _read(_favoritesKey);
  Set<String> readShopping() => _read(_shoppingKey);

  Future<void> saveOwned(Set<String> ids) => _save(_ownedKey, ids);
  Future<void> saveFavorites(Set<String> ids) => _save(_favoritesKey, ids);
  Future<void> saveShopping(Set<String> ids) => _save(_shoppingKey, ids);

  Set<String> _read(String key) =>
      (_prefs.getStringList(key) ?? const []).toSet();

  Future<void> _save(String key, Set<String> ids) =>
      _prefs.setStringList(key, ids.toList()..sort());
}
