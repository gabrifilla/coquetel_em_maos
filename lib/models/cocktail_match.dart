import 'cocktail.dart';

/// Quanto falta para preparar um coquetel com o que o usuário tem.
class CocktailMatch {
  const CocktailMatch(this.cocktail, this.missingIds);

  /// Compara a receita com os ingredientes que o usuário tem.
  factory CocktailMatch.evaluate(Cocktail cocktail, Set<String> owned) {
    final missing = cocktail.requiredItems
        .map((i) => i.ingredientId)
        .where((id) => !owned.contains(id))
        .toList();
    return CocktailMatch(cocktail, missing);
  }

  /// Até quantos ingredientes faltando um coquetel ainda aparece como "falta pouco".
  static const almostThreshold = 2;

  final Cocktail cocktail;

  /// Ingredientes obrigatórios que o usuário ainda não tem.
  final List<String> missingIds;

  bool get canMake => missingIds.isEmpty;

  /// Falta pouco: faltam até [almostThreshold] ingredientes e o usuário já tem
  /// pelo menos um dos obrigatórios (senão, com o bar vazio, todo coquetel de
  /// dois ingredientes apareceria aqui).
  bool get isAlmost =>
      missingIds.isNotEmpty &&
      missingIds.length <= almostThreshold &&
      missingIds.length < cocktail.requiredItems.length;
}
