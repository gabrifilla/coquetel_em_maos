import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../state/bar_state.dart';
import '../theme/party_theme.dart';

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
            child: _Summary(ownedCount: ownedCount, canMakeCount: canMakeCount),
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
          '${_emoji[category]}  ${category.label}',
          style: Theme.of(context).textTheme.titleMedium,
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
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  state.toggleIngredient(ingredient.id);
                },
              ),
          ],
        ),
      ),
    ];
  }
}

const _emoji = {
  IngredientCategory.destilados: '🥃',
  IngredientCategory.licores: '🍒',
  IngredientCategory.vinhos: '🥂',
  IngredientCategory.misturadores: '🧃',
  IngredientCategory.frutasErvas: '🍋',
  IngredientCategory.despensa: '🧂',
};

class _Summary extends StatelessWidget {
  const _Summary({required this.ownedCount, required this.canMakeCount});

  final int ownedCount;
  final int canMakeCount;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (ownedCount == 0) {
      return Text(
        'Marque o que você tem em casa e veja a mágica acontecer ✨',
        style: text.bodyLarge?.copyWith(color: Party.textMuted),
      );
    }
    Widget stat(String value, String label, Color color) => Expanded(
      child: Column(
        children: [
          Text(value, style: text.headlineMedium?.copyWith(color: color)),
          Text(label, style: text.bodyMedium?.copyWith(color: Party.textMuted)),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: Party.headerGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          stat(
            '$ownedCount',
            ownedCount == 1 ? 'ingrediente' : 'ingredientes',
            Party.pistachio,
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          stat(
            '$canMakeCount',
            canMakeCount == 1 ? 'drink possível' : 'drinks possíveis',
            Party.champagne,
          ),
        ],
      ),
    );
  }
}
