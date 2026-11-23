import 'package:coquetel_em_maos/data/user_data_store.dart';
import 'package:coquetel_em_maos/models/catalog.dart';
import 'package:coquetel_em_maos/models/cocktail.dart';
import 'package:coquetel_em_maos/models/ingredient.dart';
import 'package:coquetel_em_maos/state/bar_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Ingredient _ing(String id) =>
    Ingredient(id: id, name: id, category: IngredientCategory.despensa);

Cocktail _cocktail(
  String id,
  List<String> required, {
  List<String> optional = const [],
}) => Cocktail(
  id: id,
  name: id,
  description: '',
  glass: '',
  steps: const ['misture'],
  items: [
    for (final i in required) RecipeItem(ingredientId: i, amount: '1'),
    for (final i in optional)
      RecipeItem(ingredientId: i, amount: '1', optional: true),
  ],
);

final _catalog = Catalog(
  ingredients: [
    'cachaca',
    'limao',
    'acucar',
    'vodka',
    'gin',
    'tonica',
    'sal',
  ].map(_ing).toList(),
  cocktails: [
    _cocktail('caipirinha', ['cachaca', 'limao', 'acucar']),
    _cocktail('caipiroska', ['vodka', 'limao', 'acucar']),
    _cocktail('gin_tonica', ['gin', 'tonica'], optional: ['limao']),
    _cocktail(
      'margarita_de_mentira',
      ['vodka', 'gin', 'tonica'],
      optional: ['sal'],
    ),
  ],
);

Future<BarState> _state([Map<String, Object> saved = const {}]) async {
  SharedPreferences.setMockInitialValues(saved);
  return BarState(catalog: _catalog, store: await UserDataStore.open());
}

List<String> _ids(Iterable<dynamic> matches) =>
    matches.map((m) => m.cocktail.id as String).toList();

void main() {
  test('sem ingredientes, nada pode ser feito', () async {
    final state = await _state();
    expect(state.canMake, isEmpty);
    expect(state.almost, isEmpty);
  });

  test('separa o que dá para fazer do que falta pouco', () async {
    final state = await _state();
    for (final id in ['cachaca', 'limao', 'acucar', 'gin']) {
      state.toggleIngredient(id);
    }
    expect(_ids(state.canMake), ['caipirinha']);
    // caipiroska e gin tônica: falta 1; margarita: faltam 2.
    expect(_ids(state.almost), [
      'caipiroska',
      'gin_tonica',
      'margarita_de_mentira',
    ]);
    expect(state.matches.first.cocktail.id, 'caipirinha');
  });

  test(
    'só sugere "falta pouco" se o usuário já tem algum ingrediente da receita',
    () async {
      final state = await _state();
      state.toggleIngredient('cachaca');
      expect(_ids(state.almost), ['caipirinha']);
    },
  );

  test('ingrediente opcional não impede o preparo', () async {
    final state = await _state();
    state.toggleIngredient('gin');
    state.toggleIngredient('tonica');
    expect(_ids(state.canMake), ['gin_tonica']);
  });

  test('comprar um item tira da lista e coloca no bar', () async {
    final state = await _state();
    state.addToShopping(['gin', 'tonica']);
    expect(state.shopping, {'gin', 'tonica'});
    expect(state.unlocksIfBought('gin'), 0);

    state.markBought('gin');
    expect(state.shopping, {'tonica'});
    expect(state.hasIngredient('gin'), isTrue);
    expect(state.unlocksIfBought('tonica'), 1);
  });

  test('não adiciona à lista algo que já está no bar', () async {
    final state = await _state();
    state.toggleIngredient('gin');
    state.addToShopping(['gin', 'tonica']);
    expect(state.shopping, {'tonica'});
  });

  test('salva e recarrega bar, favoritos e lista de compras', () async {
    final state = await _state();
    state.toggleIngredient('cachaca');
    state.toggleFavorite('caipirinha');
    state.addToShopping(['limao']);
    await Future<void>.delayed(Duration.zero);

    final reloaded = BarState(
      catalog: _catalog,
      store: await UserDataStore.open(),
    );
    expect(reloaded.owned, {'cachaca'});
    expect(reloaded.favorites, {'caipirinha'});
    expect(reloaded.shopping, {'limao'});
  });

  test('ignora ids salvos que não existem mais no catálogo', () async {
    final state = await _state({
      'ingredientes_no_bar': ['cachaca', 'absinto'],
      'coqueteis_favoritos': ['receita_removida'],
    });
    expect(state.owned, {'cachaca'});
    expect(state.favorites, isEmpty);
  });
}
