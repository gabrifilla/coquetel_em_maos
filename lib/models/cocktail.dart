/// Um ingrediente dentro de uma receita.
class RecipeItem {
  const RecipeItem({
    required this.ingredientId,
    required this.amount,
    this.optional = false,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      ingredientId: json['id'] as String,
      amount: json['quantidade'] as String,
      optional: json['opcional'] as bool? ?? false,
    );
  }

  final String ingredientId;
  final String amount;

  /// Ingredientes opcionais (guarnição, borda de sal...) não impedem o preparo.
  final bool optional;
}

class Cocktail {
  const Cocktail({
    required this.id,
    required this.name,
    required this.description,
    required this.glass,
    required this.items,
    required this.steps,
  });

  factory Cocktail.fromJson(Map<String, dynamic> json) {
    return Cocktail(
      id: json['id'] as String,
      name: json['nome'] as String,
      description: json['descricao'] as String,
      glass: json['copo'] as String,
      items: (json['ingredientes'] as List)
          .map((e) => RecipeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['preparo'] as List).cast<String>(),
    );
  }

  final String id;
  final String name;
  final String description;
  final String glass;
  final List<RecipeItem> items;
  final List<String> steps;

  Iterable<RecipeItem> get requiredItems => items.where((i) => !i.optional);
}
