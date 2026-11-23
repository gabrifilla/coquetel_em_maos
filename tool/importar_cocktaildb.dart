// Importador de receitas do TheCocktailDB (https://www.thecocktaildb.com).
//
// Uso (na raiz do projeto):
//   dart run tool/importar_cocktaildb.dart baixar
//       Baixa as receitas, converte para o formato do catálogo e grava
//       tool/saida/importados_para_revisar.json. Com GEMINI_API_KEY definida,
//       traduz copo e modo de preparo para português com o Gemini.
//   dart run tool/importar_cocktaildb.dart mesclar tool/saida/importados_para_revisar.json
//       Depois de revisar (e apagar o que não quiser), junta ao catalogo.json.
//
// Variáveis: COCKTAILDB_KEY (padrão "1", a chave de testes), GEMINI_API_KEY,
// GEMINI_MODEL (padrão gemini-2.5-flash).

import 'dart:convert';
import 'dart:io';

import 'package:coquetel_em_maos/models/catalog.dart';
import 'package:http/http.dart' as http;

import 'src/cocktaildb.dart';

const _catalogPath = 'assets/data/catalogo.json';
const _mapPath = 'tool/mapa_ingredientes.json';
const _outputPath = 'tool/saida/importados_para_revisar.json';

Future<void> main(List<String> args) async {
  switch (args) {
    case ['baixar']:
      await _download();
    case ['mesclar', final path]:
      _merge(path);
    default:
      stderr.writeln(
        'Uso: dart run tool/importar_cocktaildb.dart baixar | mesclar <arquivo>',
      );
      exitCode = 64;
  }
}

Future<void> _download() async {
  final env = Platform.environment;
  final key = env['COCKTAILDB_KEY'] ?? '1';
  final catalogJson =
      jsonDecode(File(_catalogPath).readAsStringSync()) as Map<String, dynamic>;
  final map =
      (jsonDecode(File(_mapPath).readAsStringSync()) as Map<String, dynamic>)
        ..remove('_comentario');

  final drinks = <Map<String, dynamic>>[];
  for (final letter in 'abcdefghijklmnopqrstuvwxyz0123456789'.split('')) {
    final uri = Uri.parse(
      'https://www.thecocktaildb.com/api/json/v1/$key/search.php?f=$letter',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      stderr.writeln('Falha em "$letter": HTTP ${response.statusCode}');
      continue;
    }
    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final list = body['drinks'];
    if (list is List) drinks.addAll(list.cast<Map<String, dynamic>>());
    stdout.write('.');
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    ); // não sobrecarregar a API
  }
  stdout.writeln('\n${drinks.length} receitas baixadas.');

  final result = convertDrinks(
    drinks,
    map: map.cast<String, String>(),
    existingNames: {
      for (final c in catalogJson['coqueteis'] as List) c['nome'] as String,
    },
    existingIds: {
      for (final c in catalogJson['coqueteis'] as List) c['id'] as String,
    },
  );

  final geminiKey = env['GEMINI_API_KEY'];
  if (geminiKey != null && geminiKey.isNotEmpty) {
    final model = env['GEMINI_MODEL'] ?? 'gemini-2.5-flash';
    for (final (i, recipe) in result.recipes.indexed) {
      stdout.write('\rTraduzindo ${i + 1}/${result.recipes.length}');
      try {
        await _translate(recipe, geminiKey, model);
      } on Object catch (e) {
        stderr.writeln('\nNão traduziu ${recipe['nome']}: $e');
      }
    }
    stdout.writeln();
  } else {
    stdout.writeln(
      'GEMINI_API_KEY não definida: copo e preparo ficam em inglês (traduzido: false).',
    );
  }

  File(_outputPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(result.recipes),
    );
  stdout.writeln(
    '${result.recipes.length} receitas novas gravadas em $_outputPath',
  );

  if (result.unmapped.isNotEmpty) {
    final top = result.unmapped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    stdout.writeln(
      '\nIngredientes fora do mapa (adicione em $_mapPath para importar mais):',
    );
    for (final e in top.take(30)) {
      stdout.writeln('  ${e.value.toString().padLeft(3)}  ${e.key}');
    }
  }
}

Future<void> _translate(
  Map<String, dynamic> recipe,
  String apiKey,
  String model,
) async {
  final prompt =
      'Traduza para português do Brasil esta receita de coquetel. '
      'Escreva também uma descrição curta (uma frase) do drink. '
      'Mantenha o sentido das instruções, sem inventar passos.\n\n'
      '${jsonEncode({'nome': recipe['nome'], 'copo': recipe['copo'], 'preparo': recipe['preparo']})}';
  final response = await http.post(
    Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
    ),
    headers: {'content-type': 'application/json', 'x-goog-api-key': apiKey},
    body: jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'OBJECT',
          'properties': {
            'descricao': {'type': 'STRING'},
            'copo': {'type': 'STRING'},
            'preparo': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
            },
          },
          'required': ['descricao', 'copo', 'preparo'],
        },
      },
    }),
  );
  if (response.statusCode == 429) {
    // Plano gratuito: espera e tenta de novo uma vez.
    await Future<void>.delayed(const Duration(seconds: 30));
    return _translate(recipe, apiKey, model);
  }
  if (response.statusCode != 200) throw 'HTTP ${response.statusCode}';
  final data =
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  final text =
      (data['candidates'] as List).first['content']['parts'].first['text']
          as String;
  final t = jsonDecode(text) as Map<String, dynamic>;
  recipe['descricao'] = t['descricao'];
  recipe['copo'] = t['copo'];
  recipe['preparo'] = t['preparo'];
  recipe['traduzido'] = true;
}

void _merge(String path) {
  final catalogFile = File(_catalogPath);
  final catalogJson =
      jsonDecode(catalogFile.readAsStringSync()) as Map<String, dynamic>;
  final incoming = (jsonDecode(File(path).readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  final cocktails = (catalogJson['coqueteis'] as List)
      .cast<Map<String, dynamic>>();
  final ids = {for (final c in cocktails) c['id']};

  var added = 0;
  for (final recipe in incoming) {
    if (ids.contains(recipe['id'])) {
      stderr.writeln('Pulando ${recipe['id']}: já existe no catálogo.');
      continue;
    }
    if (recipe['traduzido'] != true) {
      stderr.writeln(
        'Aviso: ${recipe['id']} não foi traduzida; confira o texto.',
      );
    }
    recipe.remove('traduzido');
    cocktails.add(recipe);
    ids.add(recipe['id']);
    added++;
  }

  // Valida o resultado inteiro antes de gravar (ingredientes existem, campos certos).
  final encoded = const JsonEncoder.withIndent('  ').convert(catalogJson);
  final catalog = Catalog.fromJsonString(encoded);
  for (final c in catalog.cocktails) {
    for (final item in c.items) {
      if (catalog.ingredientById(item.ingredientId) == null) {
        stderr.writeln(
          'Erro: ${c.id} usa ingrediente desconhecido ${item.ingredientId}. Nada foi gravado.',
        );
        exitCode = 1;
        return;
      }
    }
  }
  catalogFile.writeAsStringSync('$encoded\n');
  stdout.writeln('$added receitas adicionadas ao catálogo.');
}
