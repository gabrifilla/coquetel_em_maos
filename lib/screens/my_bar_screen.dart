import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../state/bar_state.dart';

class MyBarScreen extends StatefulWidget {
  const MyBarScreen({super.key});

  @override
  State<MyBarScreen> createState() => _MyBarScreenState();
}

class _MyBarScreenState extends State<MyBarScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BarState>();
    final theme = Theme.of(context);
    final query = _query.trim().toLowerCase();

    final ingredients = state.catalog.ingredients
        .where((i) => query.isEmpty || i.name.toLowerCase().contains(query))
        .toList();

    final ownedCount = state.owned.length;
    final canMakeCount = state.canMake.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu bar')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              ownedCount == 0
                  ? 'Marque o que você tem em casa.'
                  : '$ownedCount ${ownedCount == 1 ? 'ingrediente' : 'ingredientes'}'
                        ' · dá para fazer $canMakeCount '
                        '${canMakeCount == 1 ? 'coquetel' : 'coquetéis'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SearchBar(
              hintText: 'Buscar ingrediente',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          if (ingredients.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Nenhum ingrediente encontrado.',
                textAlign: TextAlign.center,
              ),
            ),
          for (final category in IngredientCategory.values)
            ..._section(
              context,
              state,
              category,
              ingredients.where((i) => i.category == category).toList(),
            ),
        ],
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    BarState state,
    IngredientCategory category,
    List<Ingredient> items,
  ) {
    if (items.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(
          category.label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ingredient in items)
              FilterChip(
                label: Text(ingredient.name),
                selected: state.hasIngredient(ingredient.id),
                onSelected: (_) => state.toggleIngredient(ingredient.id),
              ),
          ],
        ),
      ),
    ];
  }
}
