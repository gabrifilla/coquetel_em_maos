/// Grupos usados para organizar os ingredientes na tela "Meu bar".
enum IngredientCategory {
  destilados('Destilados'),
  licores('Licores e aperitivos'),
  vinhos('Vinhos e espumantes'),
  misturadores('Refrigerantes e sucos'),
  frutasErvas('Frutas e ervas'),
  despensa('Despensa');

  const IngredientCategory(this.label);

  final String label;

  static IngredientCategory fromJson(String value) {
    return switch (value) {
      'destilados' => destilados,
      'licores' => licores,
      'vinhos' => vinhos,
      'misturadores' => misturadores,
      'frutas_ervas' => frutasErvas,
      'despensa' => despensa,
      _ => throw FormatException(
        'Categoria de ingrediente desconhecida: $value',
      ),
    };
  }
}

class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as String,
      name: json['nome'] as String,
      category: IngredientCategory.fromJson(json['categoria'] as String),
    );
  }

  final String id;
  final String name;
  final IngredientCategory category;
}
