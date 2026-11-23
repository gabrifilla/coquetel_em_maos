import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cocktail.dart';

/// Endereço do backend que guarda a chave da IA (ver `backend/README.md`).
/// Definido na compilação: `flutter run --dart-define=AI_BACKEND_URL=https://...`
const aiBackendUrl = String.fromEnvironment('AI_BACKEND_URL');

class AiRecipeException implements Exception {
  const AiRecipeException(this.message);

  /// Mensagem pronta para mostrar ao usuário.
  final String message;

  @override
  String toString() => message;
}

/// Pede ao backend uma receita usando apenas os ingredientes informados.
class AiRecipeService {
  AiRecipeService({String baseUrl = aiBackendUrl, http.Client? client})
    : _baseUrl = baseUrl,
      _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  bool get isConfigured => _baseUrl.isNotEmpty;

  /// [ingredients] mapeia id do catálogo → nome. [wish] é um pedido livre
  /// opcional (ex.: "refrescante", "sem limão").
  Future<Cocktail> generate(
    Map<String, String> ingredients, {
    String wish = '',
  }) async {
    if (!isConfigured) {
      throw const AiRecipeException(
        'A geração por IA ainda não foi configurada neste app.',
      );
    }

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$_baseUrl/gerar-receita'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({
              'ingredientes': [
                for (final e in ingredients.entries)
                  {'id': e.key, 'nome': e.value},
              ],
              if (wish.trim().isNotEmpty) 'pedido': wish.trim(),
            }),
          )
          .timeout(const Duration(seconds: 60));
    } on Exception {
      throw const AiRecipeException(
        'Não foi possível falar com o servidor. Verifique sua internet.',
      );
    }

    if (response.statusCode == 429) {
      throw const AiRecipeException(
        'Muitos pedidos agora. Tente de novo em alguns minutos.',
      );
    }
    if (response.statusCode != 200) {
      throw const AiRecipeException(
        'A IA não conseguiu gerar uma receita. Tente novamente.',
      );
    }

    try {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return parseRecipe(json, ingredients.keys.toSet());
    } on Object {
      throw const AiRecipeException(
        'A IA respondeu algo inesperado. Tente novamente.',
      );
    }
  }

  /// Converte a resposta em [Cocktail], descartando ingredientes que o usuário
  /// não tem (a IA às vezes inventa). Lança se sobrar uma receita inútil.
  static Cocktail parseRecipe(
    Map<String, dynamic> json,
    Set<String> allowedIds,
  ) {
    final items = <RecipeItem>[];
    final seen = <String>{};
    for (final raw in json['ingredientes'] as List) {
      final item = RecipeItem.fromJson(raw as Map<String, dynamic>);
      if (allowedIds.contains(item.ingredientId) &&
          seen.add(item.ingredientId)) {
        items.add(item);
      }
    }
    final steps = (json['preparo'] as List)
        .cast<String>()
        .where((s) => s.trim().isNotEmpty)
        .toList();
    final name = (json['nome'] as String).trim();
    if (name.isEmpty || items.isEmpty || steps.isEmpty) {
      throw const FormatException('Receita incompleta');
    }
    return Cocktail(
      id: 'ia_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      description: (json['descricao'] as String? ?? '').trim(),
      glass: (json['copo'] as String? ?? '').trim(),
      items: items,
      steps: steps,
      extras: (json['extras'] as List?)?.cast<String>() ?? const [],
      origin: CocktailOrigin.ia,
    );
  }
}
