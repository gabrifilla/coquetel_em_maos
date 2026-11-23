import 'package:flutter_test/flutter_test.dart';

import '../tool/src/cocktaildb.dart';

void main() {
  group('convertMeasure', () {
    test('converte unidades americanas', () {
      expect(convertMeasure('1 1/2 oz'), '45 ml');
      expect(convertMeasure('2 oz '), '60 ml');
      expect(convertMeasure('3 cl'), '30 ml');
      expect(convertMeasure('1 tsp'), '1 colher de chá');
      expect(convertMeasure('2 tblsp'), '2 colheres de sopa');
      expect(convertMeasure('2 dashes'), '2 dashes');
      expect(convertMeasure('1/2'), '0,5 unidades');
      expect(convertMeasure('Top up with'), 'para completar');
      expect(convertMeasure(''), 'a gosto');
      expect(convertMeasure('Juice of 1'), 'Juice of 1');
    });
  });

  Map<String, dynamic> drink(
    String id,
    String name,
    List<(String, String)> ingredients,
  ) => {
    'idDrink': id,
    'strDrink': name,
    'strGlass': 'Highball glass',
    'strInstructions': 'Shake well. Strain into glass.\r\nServe.',
    'strDrinkThumb': 'https://example.com/$id.jpg',
    for (final (i, (ing, measure)) in ingredients.indexed) ...{
      'strIngredient${i + 1}': ing,
      'strMeasure${i + 1}': measure,
    },
  };

  const map = {
    'vodka': 'vodka',
    'orange juice': 'suco_laranja',
    'ice': 'extra',
    'orange': 'laranja',
    'gin': 'gin',
  };

  test('converte drinks mapeados e ignora os demais', () {
    final result = convertDrinks(
      [
        drink('1', 'Screwdriver', [
          ('Vodka', '2 oz'),
          ('Orange juice', '4 oz'),
          ('Ice', ''),
          ('Orange', 'slice'),
        ]),
        drink('2', 'Weird One', [('Vodka', '1 oz'), ('Absinthe', '1 oz')]),
        drink('3', 'Hi-Fi', [('Vodka', '1 oz'), ('Orange juice', '1 oz')]),
        drink('4', 'Only Garnish', [('Orange', '')]),
      ],
      map: map,
      existingNames: {'Hi-Fi'},
      existingIds: {'screwdriver'},
    );

    expect(result.recipes, hasLength(1));
    final r = result.recipes.single;
    expect(r['id'], 'screwdriver_2'); // id já usado no catálogo
    expect(r['nome'], 'Screwdriver');
    expect(r['ingredientes'], [
      {'id': 'vodka', 'quantidade': '60 ml'},
      {'id': 'suco_laranja', 'quantidade': '120 ml'},
      {'id': 'laranja', 'quantidade': 'slice', 'opcional': true},
    ]);
    expect(r['extras'], ['gelo']);
    expect(r['preparo'], ['Shake well.', 'Strain into glass.', 'Serve.']);
    expect(r['imagemUrl'], 'https://example.com/1.jpg');
    expect(r['traduzido'], isFalse);
    expect(result.unmapped, {'Absinthe': 1});
  });

  test('slug e normalize removem acentos', () {
    expect(slug('Piña Colada!'), 'pina_colada');
    expect(normalize('Caipirinha de Maracujá'), 'caipirinha de maracuja');
  });
}
