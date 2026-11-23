import 'dart:convert';

import 'package:coquetel_em_maos/data/ai_recipe_service.dart';
import 'package:coquetel_em_maos/models/cocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _owned = {
  'cachaca': 'Cachaça',
  'limao': 'Limão taiti',
  'acucar': 'Açúcar',
};

Map<String, dynamic> _recipe({List<Map<String, dynamic>>? ingredients}) => {
  'nome': 'Caipirinha da Casa',
  'descricao': 'Uma caipirinha.',
  'copo': 'Copo baixo',
  'ingredientes':
      ingredients ??
      [
        {'id': 'cachaca', 'quantidade': '60 ml'},
        {'id': 'limao', 'quantidade': '1 unidade'},
      ],
  'extras': ['gelo'],
  'preparo': ['Macere o limão.', 'Adicione gelo e cachaça.'],
};

AiRecipeService _service(http.Response Function(http.Request) handler) =>
    AiRecipeService(
      baseUrl: 'https://api.exemplo',
      client: MockClient((req) async => handler(req)),
    );

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test(
    'envia ingredientes e pedido, devolve receita marcada como IA',
    () async {
      late Map<String, dynamic> sent;
      final service = _service((req) {
        expect(req.url.toString(), 'https://api.exemplo/gerar-receita');
        sent = jsonDecode(req.body) as Map<String, dynamic>;
        return _json(_recipe());
      });

      final recipe = await service.generate(_owned, wish: ' refrescante ');

      expect(sent['pedido'], 'refrescante');
      expect((sent['ingredientes'] as List).map((i) => i['id']), [
        'cachaca',
        'limao',
        'acucar',
      ]);
      expect(recipe.origin, CocktailOrigin.ia);
      expect(recipe.name, 'Caipirinha da Casa');
      expect(recipe.extras, ['gelo']);
      expect(recipe.id, startsWith('ia_'));
    },
  );

  test('descarta ingredientes que o usuário não tem', () async {
    final service = _service(
      (_) => _json(
        _recipe(
          ingredients: [
            {'id': 'cachaca', 'quantidade': '60 ml'},
            {'id': 'vodka', 'quantidade': '30 ml'},
          ],
        ),
      ),
    );
    final recipe = await service.generate(_owned);
    expect(recipe.items.map((i) => i.ingredientId), ['cachaca']);
  });

  test('erros viram mensagens amigáveis', () async {
    expect(
      () => _service((_) => _json({'erro': 'x'}, 429)).generate(_owned),
      throwsA(
        isA<AiRecipeException>().having(
          (e) => e.message,
          'message',
          contains('Muitos pedidos'),
        ),
      ),
    );
    expect(
      () => _service(
        (_) => _json({'nome': 'X', 'ingredientes': [], 'preparo': []}),
      ).generate(_owned),
      throwsA(isA<AiRecipeException>()),
    );
    expect(
      () => AiRecipeService(baseUrl: '').generate(_owned),
      throwsA(
        isA<AiRecipeException>().having(
          (e) => e.message,
          'message',
          contains('configurada'),
        ),
      ),
    );
  });
}
