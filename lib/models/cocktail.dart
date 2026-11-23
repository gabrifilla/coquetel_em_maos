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

  Map<String, dynamic> toJson() => {
    'id': ingredientId,
    'quantidade': amount,
    if (optional) 'opcional': true,
  };
}

/// De onde veio a receita.
enum CocktailOrigin {
  catalogo,
  usuario,

  /// Gerada por inteligência artificial: o app sempre avisa que pode não ficar perfeita.
  ia;

  static CocktailOrigin fromJson(String? value) =>
      values.firstWhere((o) => o.name == value, orElse: () => catalogo);
}

class Cocktail {
  const Cocktail({
    required this.id,
    required this.name,
    required this.description,
    required this.glass,
    required this.items,
    required this.steps,
    this.extras = const [],
    this.origin = CocktailOrigin.catalogo,
    this.imageUrl,
    this.imagePath,
  });

  factory Cocktail.fromJson(Map<String, dynamic> json) {
    return Cocktail(
      id: json['id'] as String,
      name: json['nome'] as String,
      description: json['descricao'] as String? ?? '',
      glass: json['copo'] as String? ?? '',
      items: (json['ingredientes'] as List)
          .map((e) => RecipeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['preparo'] as List).cast<String>(),
      extras: (json['extras'] as List?)?.cast<String>() ?? const [],
      origin: CocktailOrigin.fromJson(json['origem'] as String?),
      imageUrl: json['imagemUrl'] as String?,
      imagePath: json['imagemArquivo'] as String?,
    );
  }

  final String id;
  final String name;
  final String description;
  final String glass;
  final List<RecipeItem> items;
  final List<String> steps;

  /// Itens fora do catálogo que não contam para "posso fazer" (ex.: gelo, canela).
  final List<String> extras;

  final CocktailOrigin origin;

  /// Foto vinda da internet (receitas importadas).
  final String? imageUrl;

  /// Foto salva no aparelho (receitas do usuário).
  final String? imagePath;

  /// Receitas que o usuário pode editar e excluir.
  bool get isUserRecipe => origin != CocktailOrigin.catalogo;

  Iterable<RecipeItem> get requiredItems => items.where((i) => !i.optional);

  bool uses(String ingredientId) =>
      items.any((i) => i.ingredientId == ingredientId);

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': name,
    'descricao': description,
    'copo': glass,
    'ingredientes': items.map((i) => i.toJson()).toList(),
    'preparo': steps,
    if (extras.isNotEmpty) 'extras': extras,
    'origem': origin.name,
    if (imageUrl != null) 'imagemUrl': imageUrl,
    if (imagePath != null) 'imagemArquivo': imagePath,
  };
}
