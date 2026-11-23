import 'dart:convert';
import 'dart:io';

import 'package:coquetel_em_maos/app.dart';
import 'package:coquetel_em_maos/data/ai_recipe_service.dart';
import 'package:coquetel_em_maos/data/catalog_loader.dart';
import 'package:coquetel_em_maos/data/user_data_store.dart';
import 'package:coquetel_em_maos/models/catalog.dart';
import 'package:coquetel_em_maos/models/cocktail.dart';
import 'package:coquetel_em_maos/screens/ai_recipe_screen.dart';
import 'package:coquetel_em_maos/screens/recipe_editor_screen.dart';
import 'package:coquetel_em_maos/state/bar_state.dart';
import 'package:coquetel_em_maos/widgets/ai_warning.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<BarState> _state(List<String> owned) async {
  SharedPreferences.setMockInitialValues({'ingredientes_no_bar': owned});
  final catalog = Catalog.fromJsonString(
    File(catalogAssetPath).readAsStringSync(),
  );
  return BarState(catalog: catalog, store: await UserDataStore.open());
}

Widget _wrap(BarState state, Widget home) => ChangeNotifierProvider.value(
  value: state,
  child: MaterialApp(home: home),
);

void main() {
  testWidgets('IA: mostra o aviso, gera e salva a receita', (tester) async {
    final state = await _state(['cachaca', 'limao', 'acucar']);
    final service = AiRecipeService(
      baseUrl: 'https://api.exemplo',
      client: MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'nome': 'Caipira Nova',
              'descricao': 'Teste',
              'copo': 'Copo baixo',
              'ingredientes': [
                {'id': 'cachaca', 'quantidade': '60 ml'},
                {'id': 'limao', 'quantidade': '1 unidade'},
              ],
              'preparo': ['Misture tudo.'],
            }),
          ),
          200,
        ),
      ),
    );

    await tester.pumpWidget(_wrap(state, AiRecipeScreen(service: service)));
    expect(find.byType(AiWarning), findsOneWidget);

    await tester.tap(find.text('Gerar receita'));
    await tester.pumpAndSettle();

    expect(find.text('Caipira Nova'), findsOneWidget);
    expect(find.byType(AiWarning), findsOneWidget); // aviso continua na receita
    await tester.scrollUntilVisible(
      find.text('Salvar nas minhas receitas'),
      200,
    );
    await tester.tap(find.text('Salvar nas minhas receitas'));
    await tester.pump();

    expect(state.userRecipes.single.origin, CocktailOrigin.ia);
    expect(state.canMake.map((m) => m.cocktail.name), contains('Caipira Nova'));
  });

  testWidgets('IA: com menos de 2 ingredientes pede para montar o bar', (
    tester,
  ) async {
    final state = await _state(['cachaca']);
    await tester.pumpWidget(
      _wrap(
        state,
        AiRecipeScreen(service: AiRecipeService(baseUrl: 'https://x')),
      ),
    );
    expect(find.text('Poucos ingredientes'), findsOneWidget);
  });

  testWidgets('editor: cria receita com ingrediente do catálogo', (
    tester,
  ) async {
    final state = await _state([]);
    await tester.pumpWidget(_wrap(state, const RecipeEditorScreen()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome'),
      'Meu Drink',
    );
    await tester.tap(find.text('Adicionar ingrediente'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar).last, 'gin');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gin'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantidade'),
      '50 ml',
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(TextFormField, 'Modo de preparo'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Modo de preparo'),
      'Sirva com gelo.\n\nMexa.',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final recipe = state.userRecipes.single;
    expect(recipe.name, 'Meu Drink');
    expect(recipe.origin, CocktailOrigin.usuario);
    expect(recipe.items.single.ingredientId, 'gin');
    expect(recipe.items.single.amount, '50 ml');
    expect(recipe.steps, ['Sirva com gelo.', 'Mexa.']);
  });

  testWidgets('lista: filtro por base e aba minhas receitas', (tester) async {
    final state = await _state(['cachaca', 'limao', 'acucar', 'vodka']);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: state, child: const CoquetelApp()),
    );

    expect(find.text('Caipirinha'), findsOneWidget);
    expect(find.text('Caipiroska'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Vodka'));
    await tester.pump();
    expect(find.text('Caipirinha'), findsNothing);
    expect(find.text('Caipiroska'), findsOneWidget);

    await tester.dragUntilVisible(
      find.widgetWithText(ChoiceChip, 'Minhas receitas (0)'),
      find.widgetWithText(ChoiceChip, 'Posso fazer (2)'),
      const Offset(-200, 0),
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Minhas receitas (0)'));
    await tester.pump();
    expect(
      find.text('Nada encontrado'),
      findsOneWidget,
    ); // base Vodka ainda ativa
  });
}
